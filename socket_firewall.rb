#!/usr/bin/env ruby

require "socket"

class SimpleFirewall
  def initialize
    @allowed_ports = [80, 443]
  end

  def run
    server = TCPServer.new('0.0.0.0', 8080)
    loop do
        client = server.accept
        request = client.gets

      if blocked?(request)
        client.puts 'HTTP/1.1 403 Forbidden'
        client.puts 'Content-Type: text/plain'
        client.puts ''
        client.puts 'Access Forbidden'
      else
        client.puts 'HTTP/1.1 200 OK'
        client.puts 'Content-Type: text/plain'
        client.puts ''
        client.puts 'Selam Dünyalı'
      end

    client.close
    end
  end

  def blocked?(request)
    uri = request.split[1]

    path == '/secure'
  end
end


# Firewall Start
firewall = SimpleFirewall.new
firewall.run