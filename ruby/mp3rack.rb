require 'rack'
require 'rack/server'
require './mp3innards'


class MP3Server
  attr_reader :webroot, :playlist
  
  def initialize args
    args.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
    
    @playlist = Playlist.new(@webroot)
    #puts self.inspect
  end
    
    
  def call(env)
    request = Rack::Request.new env
    request_line = request.env['REQUEST_PATH']
	request_host = request.env['HTTP_HOST']
    
    unit = Commander.new(self, request_line, request_host)
    unit.response
  end
end

Rack::Server.start( :app => MP3Server.new( webroot: '/opt/gulfport/mp3/ripped' ), :Port => 2345 )
