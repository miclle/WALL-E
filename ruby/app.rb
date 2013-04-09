require 'sinatra'
# require 'sinatra/reloader'

require './system'

get '/' do
  'Hello World!----'
end

get '/system' do
  # Cpu.info
  System.cpu
end