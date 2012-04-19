# -*- coding: utf-8 -*-
require 'rubygems'
require 'cinch'
require 'socket'
require 'slop'

opts = Slop.parse do
  on :s, :server=, '127.0.0.1'
  on :p, :port=, 16667
  on :g, :gw_port=, 4444
  on :n, :nickname=, "hishow_"
  on :c, :channel=, "#hixi-test"
  on :r, :remote=, "127.0.0.1:4567"
end

bot = Cinch::Bot.new do
  configure do |c|
    c.server = opts[:server]
    c.port = opts[:port].to_i
    c.nick = opts[:nickname]
    c.realname = opts[:nickname]
    c.user = opts[:nickname]
    c.channels = [opts[:channel]]
  end
  
  on :message do |m|
    unless m.user == opts[:nickname]
      `curl -d "text=(#{m.user}) #{m.message}" http://#{opts[:remote]}/`
      #posts.insert(:time => m.time, :user => "#{m.user}", :text => "#{m.message}")
    end
  end
end

t = Thread.new do
  bot.start
end
t.run

server = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
sockaddr = Socket.sockaddr_in(opts[:gw_port].to_i, "127.0.0.1")
server.bind(sockaddr)
server.listen(5)
while true
  sock, sockaddr = server.accept

  while buf = sock.gets
    bot.irc.send("PRIVMSG #{opts[:channel]} :#{buf}")
  end

  sock.close
end
