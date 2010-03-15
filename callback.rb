require 'rubygems'
require 'sinatra'
require 'cgi'
require 'json'
require 'httparty'

class StatusNet
  include HTTParty
  base_uri "artha42.status.net/api"
  basic_auth "artha42","42athra"
  def self.update(message)
    self.post('/statuses/update.json',:query=>{:status=>message})
  end
end

post '/gh-post-recieve/' do
  payload = JSON.parse(params[:payload])
  repo=payload["repository"]
  message=""
  if(payload["commits"].count>1)
    before=payload["before"]
    after=payload["after"]
    old_url=CGI.escape("#{repo["url"]}/compare/#{before}...#{after}")
    short_url=HTTParty.get("http://is.gd/api.php",:query=>{:longurl=>old_url})
    message="recieved a bunch of commits to #{repo["name"]} via #github #{short_url}"
  else
    commit=payload["commits"][0]
    old_url=CGI.escape(commit["url"])
    short_url=HTTParty.get("http://is.gd/api.php",:query=>{:longurl=>old_url})
    author=commit["author"]["name"]
    message="#{author} pushed a change to #{repo["name"]} via #github #{short_url}"
  end
  StatusNet.update(message)
end
