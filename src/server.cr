require "socket"
require "./scene"

server = TCPServer.new("127.0.0.1", ARGV.first.to_i)
puts "open"

loop do
  server.accept do |client|
    puts "incoming"
    data = client.gets("\r\n")
    unless data.nil?
      puts "Got #{data.size} bytes"
      scene = Scene.from_json(data)
      scene.render("scene.png")
    end
  end
end
