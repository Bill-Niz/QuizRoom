# To change this template, choose Tools | Templates
# and open the template in the editor.
$:.unshift File.join(File.dirname(__FILE__),'..','class')


##
#
# Data format
# 
# Reception
# 100/  : Code for User manager
# 200/  : Code for Chat manager
# 300  : Code for Quiz manage
# 
# Reponse
# 400/ : OK
# 500/ : NOK
#
#
#
##

class User
  
  NOK_UNKNOWN_COMMAND = "520/Unknown command"
  OK_LOGGEG = "410/Authentication successful"
  NOK_BAD_LOGGING = "510/Bad UUID"
  OK = "400/OK"
  NOK = "500/NOK"
  
  def initialize(socket,chatServer)
    @uuid = ""
    @id = ""
    @userInfo = Hash.new
    @socket = socket
    @chatServer = chatServer
    @mysqlHelper = MysqlHelper.new
    @ready=false
    @connected = true
    @logged = false         # => know if user is authentified
    @isActive = true       # => user connected but the app is in background
    
  #  @thread = repeat_every(5) do
  #@socket.puts(Time.now.ctime)
#end  
    
  end
  
  def repeat_every(interval)
  Thread.new do
    loop do
      start_time = Time.now
      yield
      elapsed = Time.now - start_time
      sleep([interval - elapsed, 0].max)
    end
  end
end
  
  #
  # Loop listening for incomming data
  #
  def run 
    while self.connected?
      line = @socket.gets unless @socket.closed?
      if(line == nil)
        @connected = false
        @chatServer.disconnectUser(self)
        @socket.close
        
        break
      else
        Thread.new do
          processIncomingData(line)
          puts line
        end
        
      end
    end
    puts "Connection Closed!"
  end
  #
  # Parsing the incomming data
  #
  def processIncomingData(data)
    
    puts "-->>SOCK = : #{data}"
    begin
      dataArray = data.split('/')
      case dataArray[0][0].chr
        
        
        
        
      when '1'                # => User Manager
        
        case dataArray[0]
          
        when '100'          # => 100 ==> Quitting
          puts "Send App Quitting.."
          
        when '101'          # => 101 => Set id
          puts "Send Auth..."
          setId(dataArray[1].strip)
          
        when '110'          # => 110 => Set user inactive
           puts "Send is offline..."
          @isActive = false
          
        when '111'          # => 111 => Set user active
           puts "Send is online..."
          @isActive = true
          
        else
          send(NOK_UNKNOWN_COMMAND)
        end
        
        
        
        
        
      when '2'                # => Chat Manager
        
         case dataArray[0]
        # Send message to user
        when '200'
          @chatServer.sendToUser(@id, dataArray[1], dataArray[2].strip)
          
          # Send message to channel
        when '201'
          puts "Send to channel"
          @chatServer.sendToChannel(@id, dataArray[1], dataArray[2].strip," #{@userInfo["Last name"]} #{@userInfo["Name"][0].chr}.")
          
          # Join a channel
        when '202'
          @chatServer.joinChannel(self, dataArray[1].strip)
          
          # Quit a channel
        when '203'
          @chatServer.quitChannel(self, dataArray[1].strip)
          
         else
           send(NOK_UNKNOWN_COMMAND)
        end
        
        
        
        
        
        
        
      when '3'                # => Quiz Manager
        
         case dataArray[0]
           #Answer to a question 300/idchannel/answer
        when '300'
          @chatServer.sendToQuizChannel(@id, dataArray[1], dataArray[2].strip)
        when '301'
          @chatServer
        when '302'
          @chatServer
         else
           send(NOK_UNKNOWN_COMMAND)
        end
        
      else
         send(NOK_UNKNOWN_COMMAND)
      end
      
      
     
    end
  end
  
  #
  # Check if the client is still connected
  #
  def connected?
    @connected && !(@socket.closed?) 
  end
  #
  #Check if the client isLogged
  #
  #
  def isLogged?
    @logged
  end
  ##
  #
  # Check if the client is active
  ##
  def isActive?
    @isActive
  end
  #
  # Check if when can send data to client
  #
  def isSendAble?
    self.connected? && self.isActive?
  end
  
  #
  # Send data to the client
  #
  def send(data)
    if self.isSendAble?
      @socket.puts(data + " \n")
      @socket.flush
      puts "sended...--> #{data}"
    end
  end
  
  #
  # receive message from other user
  #
  def receiveFromUser(fromId,msg)
    d = "210/#{fromId}/#{msg}"
    self.send(d)
  end
  #
  # receive message from other user in the channe l
  #
  def receiveFromChannel(fromIdChan,fromIdUser,msg,name)
    dataMsg = "220/#{fromIdChan}/#{fromIdUser}/#{msg}/#{name}"
    self.send(dataMsg)
  end
  #
  # Receive message from the channel
  # if an user join or quit the channel
  # code : 204 => Joinning channel
  # code : 205 => Quitting channel
  #
  def userChangeFromChannel(code,fromidchan,fromid)
    puts "User : useChanFromchannel"
    dataMsg = "#{code}/#{fromidchan}/#{fromid}"
    self.send(dataMsg)
    
  end
  #
  # Get the user uuid
  #
  def getId
    return @uuid
  end
  #
  # Get the user id
  #
  def getI
    return @id
  end
  #
  #
  #
  def setId(value)
    puts "Set value #{value}"
    id = @mysqlHelper.isInDB(MysqlHelper::USER_TABLE, "uuid", value)
    unless id
      then
      self.send(NOK_BAD_LOGGING)
    else
      @uuid = value
      @id = id
      @logged =true
      @userInfo = @mysqlHelper.getUserInfo(@id)
      self.send(OK_LOGGEG)
    end
    
  end
  
  
  ###################
  #                 #
  #  Quiz handling  #
  #                 #
  ###################
  
  
  #
  # receive message from other user in the channel
  #
  def receiveFromQuizChannel(fromIdChan,msg)
    dataMsg = "320/#{fromIdChan}/#{msg}"
    self.send(dataMsg)
  end
  
  #
  # receive question 
  #
  def receiveQuestion(fromIdChan,msg)
    dataMsg = "330/#{fromIdChan}/#{msg}"
    self.send(dataMsg)
  end
  
  #
  # receive answser
  #
  def receiveAnswer(fromIdChan,msg)
    dataMsg = "331/#{fromIdChan}/#{msg}"
    self.send(dataMsg)
  end
  
  #
  #
  #
  def ready?
    @ready
  end
  
  #
  #
  #
  def ready=(value)
    @ready=value
  end
  
  #
  #
  #
  def waitFor(second)
    #TODO Send to user waitting request
    Thread.new do
      sleep(second)
      yield
    end
  end
  
  #
  #
  #
  def makeReadyAfter(second)
    t = waitFor(second) do
      @ready = true
    end
  end

  
  private :processIncomingData
  
  
end
