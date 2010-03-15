require 'rubygems'
require 'sinatra'
require 'json'
get '/' do
  "Hello world"
end

post '/gh-post-recieve/' do
  push = JSON.parse(params[:payload])
  "I got some JSON: #{push.inspect}"
end 
