# frozen_string_literal: true
module FlexCommerce
  module Payments
    #
    # The Payment Processor
    #
    # This service is used to contain the entire payment process when using
    # a payment gateway - e.g. paypal
    #
    # In its simplest form it will authorise the payment and create an
    # order in a self contained, idempotent process.
    #
    #  == Middleware
    #
    #  The provided payment process {PaymentProcess} has the ability to add middleware in 2 places -
    # before and after the order is created.
    #
    #  Middleware is a standard service with a defined interface.
    #  The interface contains payment_process and state as keyword args
    #  It is the responsibility of each piece of middleware to do its job only once,
    #  using the payment_process as persistent storage
    #  and the state as an OpenStruct which each middleware can use to read / write to / from.
    #
    class PaymentProcessor
      STATUS_SUCCESS = "success"
      STATUS_STARTED = "in_progress"
      STATUS_INVALID = "invalid"
      DEFAULT_STACK = ["apply_promotions", "auth", "create_order"].freeze

      # @param [PaymentProcess] payment_process The payment_process used to contain the whole process
      def initialize(payment_process:)
        self.payment_process = payment_process
        self.stack = DEFAULT_STACK.dup.map { |process| service_class_for_process(process) }
        add_additional_processes_middleware
        add_post_processes_middleware
        self.state = OpenStruct.new(status: STATUS_STARTED, message: STATUS_STARTED)
      end

      #
      # Processes the payment
      #
      def call
        catch(:abort) do
          init_reporting
          run_stack
          payment_process.update_attributes status: STATUS_SUCCESS,
                                            progress_percent_complete: 100,
                                            progress_i18n_token: "success"
        end
      rescue => ex
        payment_process.process_retry(ex)
        raise ex
      end

      private

      def init_reporting
        report_progress(0) if payment_process.retry_count.zero?
      end

      def run_stack
        stack.each_with_index do |middleware, idx|
          middleware.new(payment_process: payment_process, state: state).call
          report_progress(idx + 1)
        end
      end

      def add_additional_processes_middleware
        idx = stack.find_index(::Payments::PaymentProcess::Middleware::CreateOrder)
        payment_process.additional_processes.reverse.each do |process|
          service_class = service_class_for_process(process)
          raise "Process #{process} is not defined in the application" if service_class.nil?
          stack.insert(idx, service_class)
        end
      end

      def add_post_processes_middleware
        idx = stack.find_index(::Payments::PaymentProcess::Middleware::CreateOrder)
        payment_process.post_processes.reverse.each do |process|
          service_class = service_class_for_process(process)
          raise "Process #{process} is not defined in the application" if service_class.nil?
          stack.insert(idx + 1, service_class)
        end
      end

      def report_progress(idx)
        percent_complete = ((idx.to_f / stack.length.to_f) * 100).ceil.to_i
        update_progress(state.message, percent_complete)
      end

      def update_progress(msg, percent_complete)
        # Do not save the record as other changes are happening as well so go straight to the DB
        # so that other processes can read the progress from the database table.
        payment_process.update_columns progress_percent_complete: percent_complete,
                                      progress_i18n_token: msg,
                                      status: state.status
      end

      def service_class_for_process(process)
        "::Payments::PaymentProcess::Middleware::#{process.camelize}".safe_constantize
      end

      attr_accessor :payment_process, :stack, :state
    end
  end
end
