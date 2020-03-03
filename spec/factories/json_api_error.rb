#
# Used to create an "error" for a json-api response
#
# An error is simply an object containing the details of an error
#
# @param [String] status The http status code
# @param [String] title A short, human-readable summary of the problem
# @param [String] detail A human-readable explanation specific to this occurrence of the problem
# @param [Hash] meta A meta object containing non-standard meta-information about the error.
FactoryBot.define do
  factory :json_api_error, class: JsonStruct do
    status "500"
    title "Something went wrong"
    detail "Something went wrong because something else caused it to go wrong"
    meta {
      {
        stack_trace: [
          "/full/path/to/file_1.rb:587 method()",
          "/full/path/to/file_2.rb:588 method()",
          "/full/path/to/file_3.rb:589 method()",
          "/full/path/to/file_4.rb:590 method()",
          "/full/path/to/file_5.rb:591 method()"
        ]
      }
    }
  end
end
