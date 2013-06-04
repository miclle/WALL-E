require 'sinatra'
require 'sinatra/reloader'
require 'json'

require './system'

configure do
  set :bind, '0.0.0.0'
  set :port, 3456
end

get '/' do
  # 'Hello World!----'
  # File.read(File.join('public', 'index.html'))
  # send_file File.join(settings.public_folder, 'index.html')
  erb :index
end

get '/system' do
  content_type :json

  {
    stat:    System.stat,
    cpu_temperature:  System.cpu_temperature,
    memory:  System.memory
  }.to_json
end
