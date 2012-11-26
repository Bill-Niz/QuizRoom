# To change this template, choose Tools | Templates
# and open the template in the editor.

class Bot
    TIME_BETWEEN_QUESTIONS = 5
    TIME_QUESTIONS = 10
    
    POINT_FIRST = 5
    POINT_SECOND = 3
    POINT_THIRD = 2
    POINT_OTHER = 1
  
  def initialize(channel)
   
    @channel = channel
    @mainThread
    @waitUSerThread
    @channelIsEmpty = true
    @canRecieveAnswer = false
    
    @currentQuestion ="2+1+1*0 = ?"
    @currentAnswer  = "3"
    @currentQuestionId = 0
    @TimeElapsed = 0
    
    @userPos = 1
   
    init()
    
  end
  
  #
  #
  #
  def init()
    puts "Bot Init Thread..."
    if @channel.getType == 1
      initBotThread()
    end
    puts "Bot Init Thread... Done!"
  end
  
  #
  # Start bot main thread
  #
  def initBotThread
    @mainThread = Thread.new(arg) { |args| 
    
      loop do
        while !@channelIsEmpty
          restoreVariable
          defineQuestion()
          
          start_time = Time.now
          
          sendWait(TIME_BETWEEN_QUESTIONS)
          
          elapsed = Time.now - start_time
          sleep([ TIME_BETWEEN_QUESTIONS - elapsed, 0].max)
          
          @canRecieveAnswer = true
          sendQuestion()
          @TimeElapsed = Time.now
          startTimer(TIME_QUESTIONS)
          
          @canRecieveAnswer = false
          from_user.receiveFromQuizChannel(@channel.getId, "Time up !")
          
    
        end
      end
    }
    
  end
  
  #
  #
  #
  def sendQuestion()
    @channel.getUserList.each { |user|
      if user.ready?
        user.receiveQuestion(@channel.getId, @currentQuestion)
      end
      
    }
  end
  #
  #
  #
  def receive_answer(answer,from_user)
    
    if @canRecieveAnswer
      Thread.new(answer,from_user) { |ans,user|  
        checkAnswer(ans,user)
      }
      
    end
    
  end
  
  #
  #
  #
  def checkAnswer(answer,from_user)
    if (@currentAnswer.include? answer)
      elapsed = Time.now - @TimeElapsed
      from_user.receiveFromQuizChannel(@channel.getId, "Correct!")
      updatePoint(from_user,elapsed,@userPos)
      @userPos = @userPos + 1
    else
      from_user.receiveFromQuizChannel(@channel.getId, "Not Correct!")
    end
  end
  
  #
  #
  #
  def calculatePoint(userpos)
    #TODO make Point
    case userpos
    when 1
      POINT_FIRST 
    when 2
      POINT_SECOND 
    when 3
      POINT_THIRD 
    else 
      POINT_OTHER
    end
   end
  
  #
  #
  #
  def updatePoint(from_user,elapsed,userpos)
    point = calculatePoint(userpos)
    #TODO updatdePoint
    #TODO update question stat
    
  end
  
  #
  #
  #
  
  def restoreVariable
    @currentQuestion ="2+1+1*0 = ?"
    @currentAnswer  = "3"
    @currentQuestionId = 0
    @TimeElapsed = 0
    
    @userPos = 1
  end
  #
  #
  #
  def sendWait(second)
    @channel.getUserList.each { |user|
      user.waitFor(second)
      
    }
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
  def startTimer(second)
     sleep(second)
  end
  
  #
  # Stop bot main thread
  #
  def pauseBotThread
    if !@mainThread.stop?
      @mainThread.stop
    end
  end
  
  #
  # Start Bot Thread
  #
  def startBotThread
    if @mainThread.stop?
      @mainThread.run
    end
  end
  
  #
  #
  #
  def checkIfempty
    if(@channelIsEmpty)
      
    end
  end
  
  #
  #
  #
  def processQuiz
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
  #
  #
  def defineQuestion
    #TODO implement question
    @mysqlHelper = MysqlHelper.new
    q = @mysqlHelper.getQuestion
    @currentQuestion = q["question"]
    @currentAnswer  =  q["answer"]
    @currentQuestionId = q["id"]
    
  end
  
  #
  # Notify BOT that an use connection
  #
  def userConnected (user)
    
  end
  #
  # Notify BOT that an use disconnection
  #
  def userDisConnected (user)
    
  end
  #
  # Notify BOT that there is no user
  #
  def channelIsEmpty=(value)
    @channelIsEmpty = value
  end
  
end
