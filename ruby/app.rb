require 'sinatra'
require 'sinatra/reloader'
require 'json'

require './system'

configure do
  set :bind, '0.0.0.0'
  set :port, 3000
end

get '/' do
  'Hello World!----'
end

get '/system' do
  content_type :json
  { memory: System.memory }.to_json
end
