#!/usr/bin/env ruby
require 'webrick'
require 'webrick/https'
require 'openssl'

private_key_file = File.expand_path(File.join(File.dirname(__FILE__), "..", "ssl", "server.key"))
cert_file = File.expand_path(File.join(File.dirname(__FILE__), "..", "ssl", "server.crt"))

pkey = OpenSSL::PKey::RSA.new(File.read(private_key_file))
cert = OpenSSL::X509::Certificate.new(File.read(cert_file))

pid_file = ENV["PID_FILE"]

s = WEBrick::HTTPServer.new(
  :Port => (ENV['SSL_TEST_PORT'] || 8443),
  :Logger => WEBrick::Log::new(nil, WEBrick::Log::ERROR),
  :DocumentRoot => File.join(File.dirname(__FILE__)),
  :ServerType => WEBrick::Daemon,
  :SSLEnable => true,
  :SSLVerifyClient => OpenSSL::SSL::VERIFY_NONE,
  :SSLCertificate => cert,
  :SSLPrivateKey => pkey,
  :SSLCertName => [ [ "CN",WEBrick::Utils::getservername ] ],
  :StartCallback => proc { File.open(pid_file, "w") { |f| f.write $$.to_s }}
)
s.mount_proc("/") { |req,resp| resp.body = "hello world" }
trap("INT"){ s.shutdown }
s.start
