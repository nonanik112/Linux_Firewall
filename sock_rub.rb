require "socket"
require "rubyfu"
require "net/http"


hostname = "meyerangel.com"
port = 2000 

if ARGV.size < 2 
  puts "[+] ruby #{hostname} [IP ADDRESS ] [PAYLOAD] [PORT]"
  exit 0
else
    hostname, payload, port = ARGV
end

uri = URI.parse("http://#{hostname}/artists.php?")
uri.query = URI.query + "&#{payload}"
http = Net::HTTP.new(hostname, port)
request = Net::HTTP::GET.new(uri.request_uri)

response = http.request(request)

puts response..body