# To change this template, choose Tools | Templates
# and open the template in the editor.
load "module/content_changed.rb"
load "bot.rb"
class Channel
  include ContentChanged
  
  def initialize(name="",id="",type="",chatServer=nil)
    @userList = UserRepository.new
    @userIdList = Array.new
    @chatServer = chatServer
    @name = name
    @id = id
    @type = type
    @userList.addContentChangedListener(self)
    @mysqlHelper = MysqlHelper.new#(MysqlHelper::DB_ADRESS,"root","root",MysqlHelper::DB_NAME)
    @numUser = 0
    @BOT
    #init()
  end
  
  #
  # Init some stuff of the channel
  #
  def init
      puts "Loading Bot..."
      @BOT = Bot.new(self)
      puts "Loading Bot... Done!"
  end
  
  #
  #
  #
  def getType()
    @type
  end
  
  #
  # Return the list of user in the channel
  #
  def getUserList
    @userList
  end
  
  #
  # Return the bot of the server
  # 
  def getBot
    @BOT
  end
  
  #
  # Return the name of the channel
  #
  def getName
    @name
  end
  
  #
  # Return the id of the channel
  #
  def getId
    @id
  end
  #
  # Add user in the channel
  #
  def join(user)
    
    
    @mysqlHelper.insertConUser(user.getI,@id)
    @userList.add(user)
    @userIdList << user.getI
    
   # @userList.getcontents.each { |users| 
      
   #   users.userChangeFromChannel("204", @id, user.getId)
   # }
    
     
    
  end
  #
  # Remove user from the channel
  #
  def remove(user)
    puts "Channel : removing user....!"
    if(self.isIn(user))
      @mysqlHelper.deleteDisConUser(user.getI, @id)
      puts "Channel : removing user from chan list....!"
      @userList.remove(user)
      puts "Channel : removing user from chan list....!Done"
      @userList.getcontents.each { |users|
        users.userChangeFromChannel("205", @id, user.getId)
      }
    end
    
    
  end
  #
  # Send message to all users in this channel
  #
  def send(fromIdUser,msg,name)
    #TODO : add exception for the sender!
    puts "Channel : send()"
    @userList.getcontents.each { |user| 
    
      user.receiveFromChannel(@id, fromIdUser, msg,name)
      
    }
  end
  #
  # Send message to Bot
  #
  def sendToBot(fromIdUser,msg)
    @BOT.receive_answer(msg, getUserById(fromIdUser))
  end
  
  #
  #
  #
  def getUserById(id)
    @userList.getcontents.each { |user| 
    
      return user if("#{user.getId}" == id)
        
       
    }
    return nil
  end
  
  #
  # Check if an user is in the channel
  #
  def isIn(user)
    
    
    @userList.getcontents.each { |users| 
    
      return true if(user == users)
       
      
    }
    
    return false
  end
  #
  #
  #
  def onContentChanged(source,data)
    
  end
  #
  #
  #
  def onContentAdded(source,data)
    @numUser  = @numUser + 1
    @BOT.userConnected(data)
    if @numUser == 1
      @BOT.channelIsEmpty=false
    end
    
  end
  #
  #
  #
  def onContentRemoved(souce,data)
    @numUser  = @numUser - 1
    @BOT.userDisConnected(data)
    if @numUser == 0
      @BOT.channelIsEmpty=true
    end
    
  end
  #
  #
  #
  def to_s
    "Channel : Name = #{@name} Id = #{@id} type: #{@type}"
  end
end
