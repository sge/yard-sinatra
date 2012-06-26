# Define custom tags

YARD::Tags::Library.define_tag("Request", :request)
YARD::Tags::Library.define_tag("Response", :response)
YARD::Tags::Library.define_tag("Response Fields", :response_field, :with_types_and_name)
YARD::Tags::Library.define_tag("Request Fields", :request_field, :with_types_and_name)
YARD::Tags::Library.define_tag("Headers", :header, :with_name)
YARD::Tags::Library.define_tag("Response codes", :response_code, :with_name)
YARD::Tags::Library.define_tag("Image", :image)
YARD::Tags::Library.define_tag("Overall", :overall)

YARD::Tags::Library.define_tag("Data Hash", :data,:with_options)
