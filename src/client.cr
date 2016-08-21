require "socket"

servers = [
  {"127.0.0.1", 3001}
]

json = File.read(ARGV.first)

servers.each do |host, port|
  TCPSocket.open(host, port) do |socket|
		puts "Sending to #{host}:#{port}"
    socket.puts json
  end
end
