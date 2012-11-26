# To change this template, choose Tools | Templates
# and open the template in the editor.
load "module/content_changed.rb"
load "thread_repository.rb"
load "channel.rb"
require 'openssl'
require "socket"

class ChatServer
  include ContentChanged
  
  def initialize(port)
    puts File.dirname(__FILE__)
    puts "Init Chat Server....."
    @port = port
    @userList = UserRepository.new
    @userList.addContentChangedListener(self)
    
    @channelList = ChannelRepository.new
    @channelList.addContentChangedListener(self)
    
    @quizChannelList = ChannelRepository.new
    @quizChannelList.addContentChangedListener(self)
    
    @threads = ThreadRepository.new
    @threads.addContentChangedListener(self)
    @mysqlHelper = MysqlHelper.new
    puts "Init Chat Server socket....."
    @server = @server = TCPServer.open(@port)
    puts "Init Chat Server socket.....Done"
    @ssl_context = OpenSSL::SSL::SSLContext.new()
    puts "Init Chat Server loadind certificate....."
    @ssl_context.cert = OpenSSL::X509::Certificate.new(File.open(File.join(File.dirname(__FILE__),"../ssl/server.crt")))
    puts "Init Chat Server loadind certificate.....done1"
    @ssl_context.key = OpenSSL::PKey::RSA.new(File.open(File.join(File.dirname(__FILE__),"../ssl/server.key")))
    puts "Init Chat Server loadind certificate.....done2"
    puts "Init Chat Server socket ssl....."
    @ssl_socket = OpenSSL::SSL::SSLServer.new(@server, @ssl_context)
    puts "Init Chat Server socket ssl.....Done"
    self.loadChannelList
    run()
    
  end
  
  #
  #
  #
  def run
   
   loop {
     begin
       puts "Init Chat Server.....Done!"
       puts "Chat Server Started at #{Time.now} on Port : #{@port}"
      @threads.add(Thread.new(@ssl_socket.accept,@userList) { |socket, userList|
          puts "Log: Connection from #{socket.peeraddr[2]} at
          #{socket.peeraddr[3]}"
          user = User.new(socket,self)
          userList.add(user)
          user.run
      
    })
    rescue OpenSSL::SSL::SSLError => e
      puts " #{e.to_s} "
      retry
    rescue
      puts "Unknown Error"
      retry
     end
}
  end
  #
  #
  #
  def loadChannelList
    puts "Loading channel..."
    chanL = @mysqlHelper.getChannelList
    puts "Loading channel... mysql #{chanL}"
    chanL.each { |item|
      
      channel = Channel.new(item["name"], item["id"], item["type"],self)
      @channelList.add(channel)
      
    }
    puts "Loading channel.... Done! => #{@channelList}"
    
  end
  #
  #
  #
  def sendToUser(fromIdUser,toIdUser,msg)
    @userList.getUserById(toIdUser).receiveFromUser(fromIdUser, msg) 
  end
  #
  # User Join a channel
  #
  def joinChannel(user,idChannel)
    
    @channelList.getChannelById(idChannel).join(user)
    puts "Server joinned!"
  end
  #
  # User quit a channel
  #
  def quitChannel(user,idChannel)
    
     @channelList.getChannelById(idChannel).remove(user)
  end
  
  #
  # Send data the channel from an user
  #
  def sendToChannel(fromIdUser,toIdChannel,msg,name)
    puts "sendto"
     @channelList.getChannelById(toIdChannel).send(fromIdUser, msg,name)
    puts "sendToChannel"
  end
  
  #
  # Send data the channel from an user
  #
  def sendToQuizChannel(fromIdUser,toIdChannel,msg)
    @channelList.getChannelById(toIdChannel).sendToBot(fromIdUser, msg)
  end
  
  #
  # Disconnect user from the server:
  # Remove from all channel
  # Remove from User list
  #
  #
  def disconnectUser(user)
    @userList.remove(user)
     @channelList.getcontents.each { |chan| 
    
      if(chan.isIn(user))
        chan.remove(user)
      end
    } 
  end
  #
  #
  #
  def onContentChanged(source,data)
    
    case source
    when @userList
      puts "user Added \n"
    when @channelList
      puts "Channel Added : #{data.to_s}"
    when @threads
      puts "Tread Added"
    when @quizChannelList
    else
      puts "Unknow Source!"
    end
    
  end
  #
  #
  #
  def onContentAdded(source,data)
    
    case source
    when @userList
      puts "#{data.to_s} : Join the Server !"
    when @channelList
      puts "ChannelList Added : #{data}"
    when @threads
      puts "New client Connected ! : #{data.to_s}"
    when @quizChannelList
    else
      puts "Unknow Source!"
    end
    
  end
  #
  #
  #
  def onContentRemoved(source,data)
    
    case source
    when @userList
      puts "#{data.to_s} : Quit the Server !"
    when @channelList
    when @threads
      puts "New client Disconnected ! : #{data.to_s}"
      
    when @quizChannelList
    else
      puts "Unknow Source!"
    end
    
  end
  
end
