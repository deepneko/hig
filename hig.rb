# -*- coding: utf-8 -*-
require 'rubygems'
require 'cinch'
require 'socket'
require 'slop'

opts = Slop.parse do
  on :s, :irc_host=, '127.0.0.1'
  on :p, :irc_port=, 16667
  on :n, :nickname=, "hishow_"
  on :c, :channel=, "#hixi-test"
  on :l, :local_port=, 4444
  on :h, :remote_host=, '127.0.0.1'
  on :r, :remote_port=, 4445
end

client = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
c_sockaddr = Socket.sockaddr_in(opts[:remote_port].to_i, opts[:remote_host])

bot = Cinch::Bot.new do
  configure do |c|
    c.server = opts[:irc_host]
    c.port = opts[:irc_port].to_i
    c.nick = opts[:nickname]
    c.realname = opts[:nickname]
    c.user = opts[:nickname]
    c.channels = [opts[:channel]]
    c.reconnect = true
  end
  
  on :message do |m|
    unless m.user == opts[:nickname]
      buf = "(#{m.user}) #{m.message}"
      client.puts(buf)
    end
  end

  on :kick do |m|
    bot.quit if m.user == opts[:nickname]
    bot.irc.start
  end
end

t = Thread.new do
  begin
    p "try connect"
    client.connect(c_sockaddr)
  rescue Errno::ECONNREFUSED
    sleep 30
    client.close
    client = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
    c_sockaddr = Socket.sockaddr_in(opts[:remote_port].to_i, opts[:remote_host])
    retry
  end
  bot.start
end
t.run

server = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
sockaddr = Socket.sockaddr_in(opts[:local_port].to_i, "127.0.0.1")
server.bind(sockaddr)
server.listen(5)
while true
  sock, sockaddr = server.accept

  while buf = sock.gets
    bot.irc.send("PRIVMSG #{opts[:channel]} :#{buf}")
  end

  sock.close
end
