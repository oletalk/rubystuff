require 'rack'
require 'rack/server'
require './mp3innards'
require './mp3screener'
require './mp3const'


class MP3Server
	include Screener, Responses
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
	puts request.inspect
    # TODO: can we have a nil remote_ip here??
		remote_ip = request.env['REMOTE_ADDR']
		check_remote_ip(remote_ip)
		if ip_allowed?
			unit = Commander.new(self, request)
			unit.response
		else
			# forbidden!
			return_forbidden
		end
  end
end

Rack::Server.start( :app => MP3Server.new( webroot: '/opt/gulfport/mp3/napshare' ), :Port => 2345 )
