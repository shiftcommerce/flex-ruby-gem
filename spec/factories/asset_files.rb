FactoryBot.define do
  klass = Struct.new(:name, :asset_folder_id, :file_content_filename, :file_content_size, :file_content_content_type, :image_width, :image_height, :reference)
  factory :asset_file, class: klass do
    sequence(:name)             { |n| "asset file name-#{n}" }
    asset_folder_id             { Faker::Number.number(2) }
    sequence(:file_content_filename)  { |n| "asset_file_name_#{n}.png" }
    file_content_size           { 106 }
    file_content_content_type   { "image/png" }
    image_width                 { Faker::Number.number(4) }
    image_height                { Faker::Number.number(4) }
    reference                   { "#{Faker::Code.isbn}-#{Time.now.nsec}" }
  end
end