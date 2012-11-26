# To change this template, choose Tools | Templates
# and open the template in the editor.

class QuizUser
  def initialize(user)
    @user = user
    @ready=false
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
end
