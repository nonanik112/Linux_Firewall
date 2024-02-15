#!/usr/bin/env ruby

require "socket"
require "ipaddr"

class AdvancedFirewall
  def initialize
    @allowed_ports = [80, 443]
    @allowed_ip_ranges = [IPAddr.new('192.168.1.69')]
  end

  def run
    server = TCPServer.new('0.0.0.0', 8080)
    
    loop do
        client = server.accept
        remote_ip = client.peeraddr[3]

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

  def blocked?(remote_ip)
     return true if !@allowed_ip_ranges.any? { |range| range.include?(remote_ip)}

     false
  end
end


# Firewall Start
firewall = AdvancedFirewall.new
firewall.run