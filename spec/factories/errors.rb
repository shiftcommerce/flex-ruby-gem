FactoryBot.define do
  factory :error_exception, class: JsonStruct do
    errors do
      build_list :json_api_error, 1,
            status: "500",
            title: "Method missing _some_method in some_file.rb:587",
            detail: "The details of the error\nwith crs\nin\nit",
            meta: {
                stack_trace: [
                    "/full/path/to/file_1.rb:587 method()",
                    "/full/path/to/file_2.rb:588 method()",
                    "/full/path/to/file_3.rb:589 method()",
                    "/full/path/to/file_4.rb:590 method()",
                    "/full/path/to/file_5.rb:591 method()"
                ]
            }
    end

  end
end