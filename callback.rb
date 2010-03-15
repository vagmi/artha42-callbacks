require 'rubygems'
require 'sinatra'
require 'cgi'
require 'json'
require 'httparty'
use_in_file_templates!

get '/test' do 
  @content=File.read("/home/vagmi/work/response.json")
  erb :index
end

class StatusNet
  include HTTParty
  base_uri "artha42.status.net/api"
  #TODO: Read this from the database
  basic_auth "artha42","24ahtra"
  def self.update(message)
    self.post('/statuses/update.json',:query=>{:status=>message})
  end
end

post '/gh-post-receive/' do
  payload = JSON.parse(params[:payload])
  repo=payload["repository"]
  message=""
  if(payload["commits"].length>1)
    before=payload["before"]
    after=payload["after"]
    old_url="#{repo["url"]}/compare/#{before}...#{after}"
    short_url=HTTParty.get("http://is.gd/api.php",:query=>{:longurl=>old_url})
    message="recieved a bunch of commits to ##{repo["name"]} via #github #{short_url}"
  else
    commit=payload["commits"][0]
    old_url=commit["url"]
    short_url=HTTParty.get("http://is.gd/api.php",:query=>{:longurl=>old_url})
    author=commit["author"]["name"]
    message="#{author} pushed a change to ##{repo["name"]} via #github #{short_url}"
  end
  StatusNet.update(message)
end

__END__

@@index
<html>
  <head>
    <title>Test json post</title>
  </head>
  <body>
  <form action="/gh-post-receive/" method="post">
    <textarea name="payload">
    <%=@content%>
    </textarea>
    <input type="submit" value="post"/>
  </form>
  </body>
</html>
