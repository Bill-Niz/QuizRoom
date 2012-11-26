# To change this template, choose Tools | Templates
# and open the template in the editor.
$:.unshift File.join(File.dirname(__FILE__),'..','class')
load "repository.rb"
#
# Repository for users
#
class UserRepository < Repository
  def initialize
    super
  end
  
  def getUserById(id)
    puts "User_repository : GetUserById(#{id})"
   
    
    @contents.each() { |i|
      
      return i  if "#{i.getI}" == "#{id}".strip
       
     
    }
   puts "Nill"
   return nil
  end
  
end
