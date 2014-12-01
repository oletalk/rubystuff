require 'rack'
require 'rack/server'

class MP3Unit
  def initialize(app, request_line)
    /\/(?<command>\w+)(?<cmdpath>\/.*)$/ =~ request_line
    @command = command
    @cmdpath = cmdpath
    @app     = app
    puts "Command: #{@command}. Path: #{@cmdpath} (Original request_line is '#{request_line}')"
  end
  
  def response
    msg = "Hello World"
    if @command == 'play'
      finalpath = @app.webroot + @cmdpath
      msg << " - did you ask for #{finalpath} ?"
    end
    
    ['200', {}, [ msg ]]
  end
end


class MP3Server
  attr_reader :webroot
  
  def initialize args
    args.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
    puts self.inspect
  end
    
    
  def call(env)
    request = Rack::Request.new env
    request_line = request.env['REQUEST_PATH']
    
    unit = MP3Unit.new(self, request_line)
    unit.response
  end
end

Rack::Server.start( :app => MP3Server.new( webroot: '/opt/gulfport/mp3/ripped' ), :Port => 2345 )