require 'active_support/all'

def init
  # overwrite the swagger index.html distributable with a custom one
  Templates::Engine.with_serializer('api.md', options.serializer) do
    erb :markdown
  end
end