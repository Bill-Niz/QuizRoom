# To change this template, choose Tools | Templates
# and open the template in the editor.
# To change this template, choose Tools | Templates
# and open the template in the editor.

#!/usr/bin/ruby



require 'socket'
require 'openssl'


class Client
  def initialize host, port
    @host = host
    @port = port
    @socket = TCPSocket.new(@host, @port)

    @ssl_context = OpenSSL::SSL::SSLContext.new()

    @ssl_context.cert = OpenSSL::X509::Certificate.new(File.open("../lib/ssl/server.crt"))

    @ssl_context.key = OpenSSL::PKey::RSA.new(File.open("../lib/ssl/server.key"))

    @ssl_socket = OpenSSL::SSL::SSLSocket.new(@socket, @ssl_context)

    @ssl_socket.sync_close = true
    
    @ssl_socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)

    @ssl_socket.connect
    console
    run
    
    
  end
  
  def console()
    ts = Thread.new() { 
    
      while true
        line = gets.chomp
        sendRequest(line)
        puts line
      end
      
    }
    ts.join
  end
  
  def run
   t =  Thread.new() {  
      while true
      line = @ssl_socket.gets
      puts line
     
    end
        @ssl_socket.close
    puts "Connection Closed!"
    }
    t.join
  end
  
  #Send request to the server
  def sendRequest(request)
    @ssl_socket.puts(request+" \n")
    @ssl_socket.flush
    puts "sended..."
  end
  
end
c = Client.new("91.121.203.55", 55555)