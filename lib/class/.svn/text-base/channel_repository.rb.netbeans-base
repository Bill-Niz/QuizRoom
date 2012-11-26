# To change this template, choose Tools | Templates
# and open the template in the editor.
$:.unshift File.join(File.dirname(__FILE__),'..','class')
load "repository.rb"


class ChannelRepository < Repository
  def initialize
    super
    @chan
    
    
  end
  
  
  
  #
  #
  #
  def getChannelById(id)
    puts "Chan_repository : GetchannelById(#{id})"
   
    
    @contents.each() { |i|
      
      return i  if "#{i.getId}" == "#{id}".strip
       
     
    }
   puts "Nill"
   return nil
  end
end
