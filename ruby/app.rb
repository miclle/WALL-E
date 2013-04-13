require 'sinatra'
require 'sinatra/reloader'
require 'json'

require './system'

configure do
  set :bind, '0.0.0.0'
  set :port, 3000
end

get '/' do
  # 'Hello World!----'
  # File.read(File.join('public', 'index.html'))
  # send_file File.join(settings.public_folder, 'index.html')
  erb :index
end

get '/system' do
  content_type :json
  { cpu: System.cpu, memory: System.memory }.to_json
end
