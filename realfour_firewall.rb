#!/usr/bin/env ruby

require 'socket'
require 'ipaddr'
require 'yaml'
require 'open3'

class AdvancedFirewall
  def initialize(config_file = 'firewall_config.yml')
    load_configuration(config_file)
    @allowed_services = ['ssh', 'dns', 'web']

    # Ek özellikler
    @block_copy_paste = true
    @block_external_connections = true
    @block_cookies = true
    @dynamic_ports_enabled = true  # Dinamik port yönetimi etkinleştirildi
    @ssl_tls_control_enabled = true  # SSL/TLS kontrol etkinleştirildi
    @advanced_logging_enabled = true  # Gelişmiş günlükleme etkinleştirildi
    @ip_reputation_check_enabled = true  # IP reputasyon kontrolü etkinleştirildi
    @automatic_update_enabled = true  # Otomatik güncelleme etkinleştirildi
  end

  def run
    server = TCPServer.new('0.0.0.0', @config['server_port'])

    loop do
      client = server.accept
      remote_ip = client.peeraddr[3]
      remote_port = client.peeraddr[1]
      remote_mac = get_remote_mac_address(client)

      if blocked?(remote_ip, remote_port, remote_mac)
        log("Blocked connection from #{remote_ip}:#{remote_port} (#{remote_mac})")
        client.puts 'HTTP/1.1 403 Forbidden'
        client.puts 'Content-Type: text/plain'
        client.puts ''
        client.puts 'Access Forbidden'
      else
        log("Accepted connection from #{remote_ip}:#{remote_port} (#{remote_mac})")
        handle_request(client)
      end

      client.close
    end
  end

  def blocked?(remote_ip, remote_port, remote_mac)
    return true if !@allowed_ip_ranges.any? { |range| range.include?(remote_ip) }
    return true if !@allowed_ports.include?(remote_port)
    return true if !@allowed_mac_addresses.include?(remote_mac)
    return true if @block_copy_paste && clipboard_used?(remote_ip)
    return true if @block_external_connections && external_connection_attempt?(remote_ip)
    return true if @block_cookies && cookie_used?(remote_ip)
    return true if @dynamic_ports_enabled && !dynamic_port_allowed?(remote_port)
    return true if @ssl_tls_control_enabled && !ssl_tls_allowed?(remote_port)
    return true if @ip_reputation_check_enabled && !ip_reputation_ok?(remote_ip)
    return true if @automatic_update_enabled && needs_update?

    false
  end

  def handle_request(client)

    case request
    when /GET /
      send_get_response(client)
    when /POST /
      send_post_response(client)
    else
      send_default_response(client)
    end
    
    client.puts 'HTTP/1.1 200 OK'
    client.puts 'Content-Type: text/plain'
    client.puts ''
    client.puts 'Hello, World!'
  end


  def send_get_response(client)
    client.puts 'HTTP/1.1 200 OK'
    client.puts 'Content-Type: text/plain'
    client.puts ''
    client.puts 'GET request handled: Hello, World!'
  end
  
  def send_post_response(client)
    client.puts 'HTTP/1.1 200 OK'
    client.puts 'Content-Type: text/plain'
    client.puts ''
    client.puts 'POST request handled: Hello, World!'
  end
  
  def send_default_response(client)
    client.puts 'HTTP/1.1 404 Not Found'
    client.puts 'Content-Type: text/plain'
    client.puts ''
    client.puts '404 - Not Found'
  end

  def get_remote_mac_address(client)
    remote_ip = client.peeraddr[3]
  
    # Sistem komutu ile arp tablosunu kontrol etme (Linux için)
    # Bu işlem platforma özgüdür ve güvenlik riskleri içerebilir.
    command = "arp -a #{remote_ip}"
    _, output, _ = Open3.capture3(command)
  
    mac_address = extract_mac_from_output(output)
  
    # Eğer mac_address boşsa, varsayılan bir değer döndür
    mac_address.empty? ? '00:11:22:33:44:55' : mac_address
  end
  
  
  def extract_mac_from_output(output)
    # arp çıktısından MAC adresini çıkarmak için basit bir örnek
    # Gerçek bir uygulama için daha karmaşık bir ayrıştırma stratejisi gerekebilir
    mac_match = output.match(/([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})/)
    mac_match ? mac_match[0] : ''
  end

 

  private

  def load_configuration(config_file)
    # Yapılandırma dosyasını yükleyen metod.
    @config = YAML.load_file(config_file)
  rescue StandardError => e
    puts "Error loading configuration file: #{e.message}"
    exit
  end

end

# Güvenlik duvarını başlat
firewall = AdvancedFirewall.new
firewall.run
