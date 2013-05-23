require 'rubygems'
require 'net/ssh'
require 'net/ssh/telnet'

class SSH
  attr_accessor :errors
  
  def initialize(creds)
    begin
      creds[:user] ||= creds[:username]
      creds[:host] ||= creds[:hostname]
      
      @ssh_session = Net::SSH.start(creds[:host], creds[:user], :password => creds[:password], :keys => [])
      @ssh = Net::SSH::Telnet.new("Session" => @ssh_session, "Prompt" => creds[:prompt])
      @errors = false
    rescue Exception => e
      @errors = e
    end
  end
  
  def cmd(command)
    @ssh.cmd(command)
  end
  
  def close
    @ssh.close
  end
    
end

