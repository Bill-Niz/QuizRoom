# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'rubygems'        
require 'daemons'
options = {
    :app_name   => "QuizRoom",
    :dir_mode   => :script,
    :dir        => 'pids',
    :multiple   => true,
    :ontop      => true,
    :mode       => :load,
    :backtrace  => true,
    :log_output => true,
    :monitor    => true
  }
  
  Daemons.run( 'main.rb', options)
