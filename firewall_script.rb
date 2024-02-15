#!/usr/bin/env ruby

require "open3"

def run_command(command)
  Open3.capture3(command)
end


ef setup_firewall
  run_command("iptables -P INPUT DROP")
  run_command("iptables -P FORWARD DROP")
  run_command("iptables -P OUTPUT ACCEPT")

  run_command("iptables -A INPUT -i lo -j ACCEPT")
  run_command("iptables -A OUTPUT -o lo -j ACCEPT")

  run_command("iptables -A INPUT -p tcp --dport 22 -j ACCEPT")

  run_command("iptables -A INPUT -p icmp -j ACCEPT")
  run_command("iptables -A OUTPUT -p icmp -j ACCEPT")

  run_command("iptables -A INPUT -p tcp --dport 80 -j ACCEPT")
  run_command("iptables -A INPUT -p tcp --dport 443 -j ACCEPT")

  run_command("iptables -A OUTPUT -p udp --dport 53 -j ACCEPT")

  run_command("iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT")
  run_command("iptables -A OUTPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT")

  run_command("iptables -N LOGGING")
  run_command("iptables -A INPUT -j LOGGING")
  run_command("iptables -A LOGGING -m limit --limit 2/min -j LOG --log-prefix 'IPTables-Dropped: ' --log-level 7")
  run_command("iptables -A LOGGING -j DROP")

  # Port Knocking
  run_command("iptables -A INPUT -p tcp --dport 1001 -m recent --name KNOCK1 --set -j DROP")
  run_command("iptables -A INPUT -p tcp --dport 1002 -m recent --name KNOCK1 --rcheck -j DROP")
  run_command("iptables -A INPUT -p tcp --dport 1002 -m recent --name KNOCK2 --set -j DROP")
  run_command("iptables -A INPUT -p tcp --dport 1003 -m recent --name KNOCK2 --rcheck -j DROP")
  run_command("iptables -A INPUT -p tcp --dport 22 -m recent --name KNOCK3 --set -j DROP")
  run_command("iptables -A INPUT -p tcp --dport 22 -m recent --name KNOCK3 --rcheck -j ACCEPT")

  # Geoblocking
  run_command("iptables -A INPUT -m geoip --src-cc US -j DROP")

  # Dinamik kurallar
  run_command("iptables -A INPUT -p tcp --dport 8080 -m time --timestart 08:00 --timestop 18:00 -j ACCEPT")

  # Fail2Ban entegrasyonu
  run_command("iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --set")
  run_command("iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 3 -j DROP")

  # Rate Limiting
  run_command("iptables -A INPUT -m recent --name RATE_LIMIT --set")
  run_command("iptables -A INPUT -m recent --name RATE_LIMIT --update --seconds 600 --hitcount 30 -j DROP")
end

setup_firewall

run_command("systemctl enable --now firewall.service")