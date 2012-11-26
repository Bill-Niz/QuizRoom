# To change this template, choose Tools | Templates
# and open the template in the editor.
require "dbi"
require 'rubygems'
require 'active_support/all'
require 'iconv'


class MysqlHelper
  DB_NAME = "QuizRoom"  # => Data base Name
  USER_TABLE = "user"   # => User table name in DB
  USER_LIST_IN_CHAN_TABBLE = "listUserChannel"
  QUESTION_TABLE = "question"
  CHANNEL_TABLE = "channel"
  RECOVERY_TABLE = "recovery"
  CATEGORIES_TABLE= "categories"
  LIST_USER_CHANNEL_TABLE = "listUserChannel"
  LOG_TABLE = "serverLog"
  CLIENT_DB_USER = "root"
  CLIENT_DB_PASSWORD ="root" #"USVtPeTbMsxEcMmn"
  DB_ADRESS = "localhost"
  
  def initialize(host=DB_ADRESS,user=CLIENT_DB_USER,password=CLIENT_DB_PASSWORD,db=DB_NAME)
    @host = host
    @user = user
    @password = password
    @dataBase = db
    @dbh
    @connected = false
    
  end
  
  
  ##
  #
  # Connection to the DB server
  #
  ##
  def connect
    
    if !self.connected?
   
     # connect to the MySQL server
     
     @dbh = DBI.connect("DBI:Mysql:#{@dataBase}:#{@host}", 
	                    "#{@user}", "#{@password}")
                    
     @connected=true
    
  end
  end
  
  ##
  #
  # Check if we are connected to the  DB server
  #
  ##
  def connected?
    @connected
  end
  
  
  ##
  #
  #Check if a data is in DB
  #
  # - table : the table where data is
  # - column : the column name to checke
  # - dataToCheck : the data that have to be compared
  #
  ##
  def isInDB(table,column,dataToCheck)
    
    begin
    
    query = "SELECT * FROM `#{table}` WHERE `#{column}` = ?"
     
    self.connect unless self.connected?  # => connect to the DB server if not connected
    
    sth = @dbh.prepare(query)
    
    sth.execute(dataToCheck)
  
    isIn=false
     sth.fetch() { |row|  
       
       
       isIn=row[0]
     }
    
    sth.finish
    
    rescue DBI::DatabaseError => e
     puts "------isInDB(#{table},#{column},#{dataToCheck})" 
     puts "An error occurred"
     puts "Error code:    #{e.err}"
     puts "Error message: #{e.errstr}"
     @dbh.rollback
    rescue Exception => e  
      puts "isindb(#{dataToCheck}):error!!! -> : #{e.to_s}"
    
    ensure
     # disconnect from server
     @dbh.disconnect if @connected
     @connected=false
    end
    return isIn
      
  end
  #
  #
  #
  def to_utf8 string
    Iconv.iconv('UTF-8','ISO-8859-1', string)[0]
  end
  
  #
  #
  # Inster user into the DB
  ##
  def insertUser(email,password,lastname,firstname,birthdate,uuid,fbid,access_token,access_token_expiration)
    begin
    success= false
    query = "INSERT INTO `#{DB_NAME}`.`#{USER_TABLE}` (`email`, `password`, `last_name`, 
                                            `first_name`, `birthdate`, `uuid`,
                                            `facebook_id`, `access_token`, 
                                            `access_token_expiration`) 
                                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)"
    
    self.connect unless self.connected?  # => connect to the DB server if not connected
    sth =@dbh.prepare(query)
    sth.execute(email,password,lastname,firstname,birthdate,uuid,fbid,access_token,access_token_expiration)
    sth.finish
    @dbh.commit
   
    success = true
    rescue DBI::DatabaseError => e
      
      puts "-----insertUser"
     puts "An error occurred"
     puts "Error code:    #{e.err}"
     puts "Error message: #{e.errstr}"
     @dbh.rollback
     rescue Exception => e  
      puts "insertusert:error!!! -> #{e.to_s}"
    ensure
     # disconnect from server
     @dbh.disconnect if @connected
     @connected=false
    end
    
    return success
    
  end
  
  
  #######################################################
  #                                                     #
  #                   CHAT HANDLING                     #
  #                                                     # 
  #######################################################
  
  
  
  #
  #
  # Return the channels list
  #
  def getChannelList
    begin
    channelList = []
      query = "SELECT * FROM `#{CHANNEL_TABLE}`"
    
    self.connect unless self.connected?  # => connect to the DB server if not connected
    
    sth = @dbh.prepare(query)
    
    sth.execute()
    
     sth.fetch { |row|  
       channelList << Hash["id" => row[0], "name" =>  to_utf8(row[1]), "type" => row[2]]
     } 
      
    
    sth.finish
    
    rescue DBI::DatabaseError => e
     
      puts "-------getChannelList(#{type})"
     puts "An error occurred"
     puts "Error code:    #{e.err}"
     puts "Error message: #{e.errstr}"
     @dbh.rollback
    rescue Exception => e  
      puts "getchanlist:error!!! -> : #{e.to_s}"
    
    ensure
     # disconnect from server
     @dbh.disconnect if @connected
     @connected=false
    end
   
    return channelList
  end
  
  #
  #
  # Return the channels list
  #
  def getChannelListByType(type)
    begin
    channelList = []
      query = "SELECT * FROM `#{CHANNEL_TABLE}` where `channelType_id_channelType` = #{type}"
    
    self.connect unless self.connected?  # => connect to the DB server if not connected
    
    sth = @dbh.prepare(query)
    
    sth.execute()
    
     sth.fetch { |row|  
       channelList << Hash["id" => row[0], "name" =>  to_utf8(row[1]), "type" => row[2],"category" =>to_utf8(row[3]),"image" =>to_utf8(row[4]) ]
     } 
      
    
    sth.finish
    
    rescue DBI::DatabaseError => e
     
      puts "-------getChannelList(#{type})"
     puts "An error occurred"
     puts "Error code:    #{e.err}"
     puts "Error message: #{e.errstr}"
     @dbh.rollback
    rescue Exception => e  
      puts "getchanlist:error!!! -> : #{e.to_s}"
    
    ensure
     # disconnect from server
     @dbh.disconnect if @connected
     @connected=false
    end
   
    return channelList
  end
  
  
  #
  # Return the channels list
  #
  def getUserListInchannel(idChan)
    begin
    userlList = []
    query = "SELECT id_user,last_name,first_name,profile_img FROM `#{USER_TABLE}` 
             INNER JOIN #{USER_LIST_IN_CHAN_TABBLE} 
                  ON #{USER_TABLE}.id_user = #{USER_LIST_IN_CHAN_TABBLE}.user_id_user 
                  WHERE #{USER_LIST_IN_CHAN_TABBLE}.channel_id_channel  = #{idChan}"
    
    self.connect unless self.connected?  # => connect to the DB server if not connected
    
    sth = @dbh.prepare(query)
    
    sth.execute()
    
     sth.fetch { |row|  
       userlList << Hash["id_user" => row[0],
                          "last_name" =>  to_utf8(row[1]),
                          "first_name" =>  to_utf8(row[2]),
                          "img_url" =>  row[3]
                          ]
     } 
      
    
    sth.finish
    
    rescue DBI::DatabaseError => e
      
      puts "--------getUserListInchannel(#{idChan})"
     puts "An error occurred"
     puts "Error code:    #{e.err}"
     puts "Error message: #{e.errstr}"
     @dbh.rollback
    rescue Exception => e  
      puts "getchanin:error!!! -> : #{e.to_s}"
    
    ensure
     # disconnect from server
     @dbh.disconnect if @connected
     @connected=false
    end
    return userlList
  end
  
  #
  # Insert Connected user in to channel
  #
  def insertConUser(idUser,idChannel)
    
    begin
      query = "INSERT INTO `#{DB_NAME}`.`#{USER_LIST_IN_CHAN_TABBLE}` (`user_id_user`, `channel_id_channel`) 
                                                                       VALUES (?, ?)"
    
    self.connect unless self.connected?  # => connect to the DB server if not connected
    
    sth = @dbh.prepare(query)
   
      sth.execute(idUser,idChannel)
    sth.finish
    rescue DBI::DatabaseError => e
      
      puts "-----insertConUser(#{idUser},#{idChannel})"
     puts "An error occurred"
     puts "Error code:    #{e.err}"
     puts "Error message: #{e.errstr}"
     @dbh.rollback
    rescue Exception => e  
      puts "error!!! -> : #{e.to_s}"
    
    ensure
     # disconnect from server
     @dbh.disconnect if @connected
     @connected=false
    end
  end
  #
  # delete disconnected user in to channel
  #
  def deleteDisConUser(idUser,idChannel)
    puts "Mysql_helper : Deletinuser in db"
    begin
      query = "DELETE FROM `#{DB_NAME}`.`#{USER_LIST_IN_CHAN_TABBLE}` WHERE `#{USER_LIST_IN_CHAN_TABBLE}`.`user_id_user` = ? AND `#{USER_LIST_IN_CHAN_TABBLE}`.`channel_id_channel` = ?"
      queryReset = "ALTER TABLE #{USER_LIST_IN_CHAN_TABBLE} AUTO_INCREMENT = 1"
      self.connect unless self.connected?  # => connect to the DB server if not connected
      sth = @dbh.prepare(query)
      sth.execute(idUser,idChannel)
      sth = @dbh.prepare(queryReset)
      sth.execute
      
    sth.finish
    rescue DBI::DatabaseError => e
      
      puts "----deleteDisConUser(#{idUser},#{idChannel})"
     puts "An error occurred"
     puts "Error code:    #{e.err}"
     puts "Error message: #{e.errstr}"
     @dbh.rollback
    rescue Exception => e  
      puts "error!!! -> : #{e.to_s}"
    
    ensure
     # disconnect from server
     @dbh.disconnect if @connected
     @connected=false
    end
    puts "Mysql_helper : Deletinuser in db ... Done!"
      
  end
  
  #####################################################
  #                                                   #
  #                   USER HANDLE                     #
  #                                                   # 
  #####################################################
  
  #
  # Update user info with column name / data
  #
  def updateUserInfo(uuid,colname,info)
    
    begin
      query = "UPDATE  `#{DB_NAME}`.`#{USER_TABLE}` SET  `#{colname}`  =  ? WHERE  `user`.`uuid` = ?;"
      self.connect unless self.connected?  # => connect to the DB server if not connected
      sth = @dbh.prepare(query)
      sth.execute(info,uuid)
      puts info
     
      
    sth.finish
    rescue DBI::DatabaseError => e
      
      
     puts "#{caller[0]}"
     puts "------updateUserInfo(#{uuid},#{colname},#{info})"
     puts "An error occurred"
     puts "Error code:    #{e.err}"
     puts "Error message: #{e.errstr}"
     @dbh.rollback
    rescue Exception => e  
      puts "error!!! -> : #{e.to_s}"
    
    ensure
     # disconnect from server
     @dbh.disconnect if @connected
     @connected=false
    end
    
      
  end
  
  
  #
  #
  #
  def getUserGeoc
    begin
    userDataGeoLoc = []
    query = "SELECT `id_user`, `uuid`, `last_name`,`first_name`,`longitude`, `latitude` FROM `#{DB_NAME}`.`#{USER_TABLE}`
    WHERE `longitude` IS NOT NULL AND `latitude` IS NOT NULL"
    
    self.connect unless self.connected?  # => connect to the DB server if not connected
    
    sth = @dbh.prepare(query)
    
    sth.execute()
    
     sth.fetch { |row|  
       userDataGeoLoc << Hash["id_user" => row[0],
                          "uuid" => row[1],
                          "last_name" =>  to_utf8(row[2]),
                          "first_name" =>  to_utf8(row[3]),
                          "longitude" =>  row[4],
                          "latitude" =>  row[5]
                          ]
     } 
      
    
    sth.finish
    
    rescue DBI::DatabaseError => e
      
      puts "--------getUserListInchannel(#{idChan})"
     puts "An error occurred"
     puts "Error code:    #{e.err}"
     puts "Error message: #{e.errstr}"
     @dbh.rollback
    rescue Exception => e  
      puts "getchanin:error!!! -> : #{e.to_s}"
    
    ensure
     # disconnect from server
     @dbh.disconnect if @connected
     @connected=false
    end
    return userDataGeoLoc
  end
  
  
  
  
  #
  #
  # Try to login an user with login and password
  # 
  # Return : UUID of the user Or FALSE
  #
  #
  def getUserInfo(idUser)
    
    begin
    
    query = "SELECT last_name,first_name,email,birthdate,facebook_id FROM `#{USER_TABLE}` WHERE `id_user` = ?"
     
    self.connect unless self.connected?  # => connect to the DB server if not connected
    
    sth = @dbh.prepare(query)
    
    sth.execute(idUser)
    count=0
    userinf=false
    sth.fetch() { |row|  
      userinf = Hash[ "Name" => self.to_utf8(row[0]),
                      "Last name" => self.to_utf8(row[1]),
                      "E-mail" => row[2]
                      #"Birthdate" => row[3]
                      ]
     } 
     
    sth.finish
    
    rescue DBI::DatabaseError => e
     
     puts "------getUserInfo(#{idUser})"
     puts "An error occurred"
     puts "Error code:    #{e.err}"
     puts "Error message: #{e.errstr}"
     @dbh.rollback
    rescue Exception => e  
      puts "error!!! -> : #{e.to_s}"
    
    ensure
     # disconnect from server
     @dbh.disconnect if @connected
     @connected=false
    end
    return userinf
      
  end
  
  
  #
  #
  # Try to login an user with login and password
  # 
  # Return : UUID of the user Or FALSE
  #
  #
  def loginNormal(userInfo)
    
    begin
    
    query = "SELECT uuid,id_user FROM `#{USER_TABLE}` WHERE `email` = ? AND `password` = ?"
     
    self.connect unless self.connected?  # => connect to the DB server if not connected
    
    sth = @dbh.prepare(query)
    
    sth.execute(userInfo["email"],userInfo["password"])
    count=0
    isIn=false
    sth.fetch() { |row|  
       isIn=Hash["uuid" => row[0],
                 "id_user" => row[1]
       ]
     } 
     
    sth.finish
    
    rescue DBI::DatabaseError => e
      
     puts "-----loginNormal(userInfo)"
     puts "An error occurred"
     puts "Error code:    #{e.err}"
     puts "Error message: #{e.errstr}"
     @dbh.rollback
    rescue Exception => e  
      puts "loginno:error!!! -> : #{e.to_s}"
    
    ensure
     # disconnect from server
     @dbh.disconnect if @connected
     @connected=false
    end
    return isIn
      
  end
  
  
  
  ##
  #
  # Try to login with facebook
  #
  ##
  def loginFacebook(userInfo)
    
    begin
    
    query = "SELECT uuid,id_user FROM `#{USER_TABLE}` WHERE `facebook_id` = ?"
     
    self.connect unless self.connected?  # => connect to the DB server if not connected
    
    sth = @dbh.prepare(query)
    
    sth.execute(userInfo["faceboo_id"])
    count=0
    isIn=false
    sth.fetch() { |row|  
       isIn=Hash["uuid" => row[0],
                 "id_user" => row[1]
       ]
     } 
     
    sth.finish
    
    rescue DBI::DatabaseError => e
      
      puts "------loginFacebook(userInfo)"
     puts "An error occurred"
     puts "Error code:    #{e.err}"
     puts "Error message: #{e.errstr}"
     @dbh.rollback
    rescue Exception => e  
      puts "logginfb:error!!! -> : #{e.to_s}"
    
    ensure
     # disconnect from server
     @dbh.disconnect if @connected
     @connected=false
    end
    return isIn
      
  end
  #
  # Check the validity of uuid with access token
  #
  #
  def validAccessToken(accessInfo)
    
    begin
    
    query = "SELECT uuid FROM `#{USER_TABLE}` WHERE `uuid` = ? AND `access_token_expiration` > NOW()"
     
    self.connect unless self.connected?  # => connect to the DB server if not connected
    
    sth = @dbh.prepare(query)
    
    sth.execute(accessInfo["uuid"])
    count=0
    isIn=false
    sth.fetch() { |row|  
       isIn=row[0]
     } 
    sth.finish
    
    rescue DBI::DatabaseError => e
      
      puts "---validAccessToken(#{accessInfo})"
     puts "An error occurred"
     puts "Error code:    #{e.err}"
     puts "Error message: #{e.errstr}"
     @dbh.rollback
    rescue Exception => e  
      puts "validoken:error!!! -> : #{e.to_s}"
    
    ensure
     # disconnect from server
     @dbh.disconnect if @connected
     @connected=false
    end
    return isIn
      
  end
  
  #
  #
  #
  # Check the validity of uuid with access token
  #
  #
  def validRecoveryToken(token)
    
    begin
    
    query = "SELECT user_id_user FROM `#{RECOVERY_TABLE}` WHERE `token` = ?  AND `expiration_token` > NOW()"
     
    self.connect unless self.connected?  # => connect to the DB server if not connected
    
    sth = @dbh.prepare(query)
    
    sth.execute(token)
    isIn=false
    sth.fetch() { |row|  
       isIn=row[0]
     } 
     
    sth.finish
    
    rescue DBI::DatabaseError => e
      
      puts "------validRecoveryToken(#{token})"
     puts "An error occurred"
     puts "Error code:    #{e.err}"
     puts "Error message: #{e.errstr}"
     @dbh.rollback
    rescue Exception => e  
      puts "error!!! -> : #{e.to_s}"
    
    ensure
     # disconnect from server
     @dbh.disconnect if @connected
     @connected=false
    end
    return isIn
      
  end
  
  #
  # Update user  password
  #
  def updatePassword(iduser,psw)
    
    begin
      query = "UPDATE  `#{DB_NAME}`.`#{USER_TABLE}` SET  `password`  =  ? WHERE  `user`.`id_user` = ?;"
      self.connect unless self.connected?  # => connect to the DB server if not connected
      sth = @dbh.prepare(query)
      sth.execute(psw,iduser)
     
      
    sth.finish
    rescue DBI::DatabaseError => e
      
      puts "------updatePassword(#{iduser},#{psw})"
     puts "An error occurred"
     puts "Error code:    #{e.err}"
     puts "Error message: #{e.errstr}"
     @dbh.rollback
    rescue Exception => e  
      puts "error!!! -> : #{e.to_s}"
    
    ensure
     # disconnect from server
     @dbh.disconnect if @connected
     @connected=false
    end
    
      
  end
  
  #
  #
  #
  #
  # delete token from recovery password
  #
  def deleteRecoveryPasswordToken(token)
    
    begin
      query = "DELETE FROM `#{DB_NAME}`.`#{RECOVERY_TABLE}` WHERE `#{TOKEN_TABLE}`.`token` = ?"
      queryReset = "ALTER TABLE #{RECOVERY_TABLE} AUTO_INCREMENT = 1"
      self.connect unless self.connected?  # => connect to the DB server if not connected
      sth = @dbh.prepare(query)
      sth.execute(token)
      sth = @dbh.prepare(queryReset)
      sth.execute
      
    sth.finish
    rescue DBI::DatabaseError => e
      
      puts "----deleteRecoveryPasswordToken(#{token})"
     puts "An error occurred"
     puts "Error code:    #{e.err}"
     puts "Error message: #{e.errstr}"
     @dbh.rollback
    rescue Exception => e  
      puts "error!!! -> : #{e.to_s}"
    
    ensure
     # disconnect from server
     @dbh.disconnect if @connected
     @connected=false
    end
    
      
  end
  
  #####################################################
  #                                                   #
  #                   LOG HANDLER                     #
  #                                                   # 
  #####################################################
  
  #
  #
  #
  def log(uuid,ipsource,request,responseTime,responseSize)
    begin
      query = "INSERT INTO `#{DB_NAME}`.`#{LOG_TABLE}` (`uuid`, `ip_address`,`request`,`response_time`,`response_data_size`) 
                                                                       VALUES (?, ?, ?, ?, ?)"
    
    self.connect unless self.connected?  # => connect to the DB server if not connected
    
    sth = @dbh.prepare(query)

    sth.execute(uuid,ipsource,request,responseTime,responseSize)
    sth.finish
    rescue DBI::DatabaseError => e
     
     puts "------log(uuid,ipsource,request,responseTime,responseSize)"
     puts "An error occurred"
     puts "Error code:    #{e.err}"
     puts "Error message: #{e.errstr}"
     @dbh.rollback
    rescue Exception => e  
      puts "error!!! -> : #{e.to_s}"
    
    ensure
     # disconnect from server
     @dbh.disconnect if @connected
     @connected=false
    end
  end
  
  
  #######################################################################
  #                                                                     #
  #                    QUIZ HANDLING                                    #         
  #                                                                     #
  #######################################################################
  
  
  #
  # get random question
  #
  def getQuestion()
     
    begin
    
      queryOffSet = "SELECT FLOOR(RAND() * COUNT(*)) AS `offset` FROM `#{QUESTION_TABLE}` "
      offset=0
      query = "SELECT * FROM `#{QUESTION_TABLE}` LIMIT #{offset}, 1 "
     
      self.connect unless self.connected?  # => connect to the DB server if not connected
    
    sth = @dbh.prepare(queryOffSet)
    sth.execute()
    
    sth.fetch() { |row|  
       offset = row[0]
     }
     
     sth = @dbh.prepare(queryOffSet)
     sth.execute()
     qst = qst=Hash["id" => 0,
                "question" => "2+1+1*0 = ?",
                "answer" => "3"
       ]
      sth.fetch() { |row|  
       qst=Hash["id" => row[0],
                "question" => row[1],
                "answer" => row[2]
       ]
     }
     
    sth.finish
    
    rescue DBI::DatabaseError => e
      
     puts "------getQuestion()"
     puts "An error occurred"
     puts "Error code:    #{e.err}"
     puts "Error message: #{e.errstr}"
     @dbh.rollback
    rescue Exception => e  
      puts "logginfb:error!!! -> : #{e.to_s}"
    
    ensure
     # disconnect from server
     @dbh.disconnect if @connected
     @connected=false
    end
    return qst
      
  end
  
  
end
