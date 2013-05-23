require './ssh.rb'

class Cisco_ssh < SSH
  attr_accessor :config, :users
  def initialize(creds)
    @host, @users = creds[:host], []
      
    creds[:prompt] = /.*>|.*#/
    super(creds)
    unless @errors
      cmd("term len 0")
      update_config
    end
  end
  
  def enable(pass)
    @ssh.cmd("en\r#{pass}")
  end
  
  def termlen=(length)
    @ssh.cmd("term len #{length}")
  end
  
  def close
    termlen=24
    @ssh.close
  end
  
  def update_config
    @config = @ssh.cmd("show run")
    get_users
  end
  
  private
  def get_interfaces
    interface = {}
    ints = cmd("show int status")
      
    end
  end
  
  def get_users
    @config.lines.each do |line|
      if line.include? "username"
        user = {}
        user[:username] = line.split[1]
        user[:password] = line.match(/(password|secret).\d.*/)[0].split[2]
        @users.push(user)
      end
    end
  end
end