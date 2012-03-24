module Model
  def self.connect(session)
  end

  def self.say(text)
    begin
      sock = TCPSocket.open($const.GW_SERVER, $const.GW_PORT)
      p sock
    rescue
      puts "socket.open failed : #$!\n"
    else
      sock.write(text)
      sock.close
    end
  end
end
