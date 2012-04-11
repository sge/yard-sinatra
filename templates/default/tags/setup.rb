def init
  super
  sections[:index].push(:header)
  sections[:index].push(:request)
  sections[:index].push(:request_field)
  sections[:index].push(:response)
  sections[:index].push(:response_field)
  sections[:index].push(:response_code)
end

def param
  super or tag(:param) if object.type == :route
end

def header
  generic_tag :header
end

def request_field
  generic_tag :request_field
end

def response_field
  generic_tag :response_field
end

def response_code
  generic_tag :response_code
end

def generic_tag(name, opts = {})
  return unless object.has_tag?(name)
  @no_names = true if opts[:no_names]
  @no_types = true if opts[:no_types]
  @name = name
  out = erb('generic_tag')
  @no_names, @no_types = nil, nil
  out
end
