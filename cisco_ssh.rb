require './ssh.rb'

class Cisco_ssh < SSH
  attr_accessor :config, :users, :interfaces
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
    get_interfaces
  end
  
  private
  def get_interfaces
    @interfaces = []
    @config.scan(/interface.*?!/m).each do |int|
      interface = {}
      interface[:name] = int.split[1]
      
      vlan_match = int.match(/vlan\ (\d+)/)
      interface[:vlan] = vlan_match.nil? ? nil : vlan_match[1].to_i
      
      interface[:disabled] = int.include?("shutdown") ? true : false
      
      interface[:config] = int
      
      @interfaces.push(interface)
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