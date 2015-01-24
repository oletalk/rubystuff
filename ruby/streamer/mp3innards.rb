require 'find'
require 'uri'
require './mp3data'
require './log'

LIST_HEADER = '<h2>Song listing</h2><p><a href="drop">Playlist</a></p>'
M3U_HEADER = "#EXTM3U\n"
BR = '<br/>'
CR = "\n"
RC_OK = '200'
RC_NOT_FOUND = '404'

class Commander

  def initialize(app, request_obj)

	# we just want these headers from the request
	request_line = request_obj.env['REQUEST_PATH']
	http_host    = request_obj.env['HTTP_HOST']
	
    /\/(?<command>\w+)(?<cmdpath>\/.*)$/ =~ request_line
	@http_host = http_host
    @command = command
    @cmdpath = cmdpath
    @app     = app
    @returncode = RC_OK
    @headers = {'Content-Type' => 'text/html'}
    $LOG.info "Command: #{@command}. Path: #{@cmdpath} (Original request_line is '#{request_line}')"
  end
  
  def response
    msg = "Hello World"
    @returncode = RC_OK
    
    if @command == 'play'
      @headers['Content-Type'] = 'application/octet-stream; charset=utf8'
      # TODO: don't cache anything
      msg = contents_from_cmdpath
    elsif @command == 'list'
      $LOG.debug @app.playlist.paths(nil).inspect
      msg = LIST_HEADER + @app.playlist.paths('playurl').join(BR)
	elsif @command == 'drop'
	  @headers['Content-Type'] = 'text/plain'
	  msg = M3U_HEADER + @app.playlist.paths('m3u', @http_host).join(CR);
    end
    if @command != 'play'
      $LOG.info msg
    end
    
    [ @returncode, @headers, [ msg ]]
  end
  
#def return_not_found
#[ '404', { 'Content-Type' => 'text/html' }, [ '<h3>404 Not Found</h3>' ] ]
#end

	def return_forbidden
 		[ '403', { 'Content-Type' => 'text/html' }, [ '<h3>403 Forbidden</h3>' ] ]
	end

	
  private
  def contents_from_cmdpath()
    finalpath = @app.webroot + URI.unescape(@cmdpath)
    begin
		# TODO: need to downsample if @app.downsampling? is true
      IO.read(finalpath)
    rescue Errno::ENOENT
      $LOG.warn "Given path #{finalpath} was not found"
      @returncode = RC_NOT_FOUND
      @headers['Content-Type'] = 'text/html'
      "File not found"
    end
  end

end

class Playlist
  def initialize(webroot)
    @webroot = webroot
    # chop off trailing slash if any
    @webroot.sub!(/\/$/, '')
    
    @mp3s = []
    Find.find(webroot) do |path|
      if FileTest.file?(path)
        if File.extname(path).upcase == '.MP3' or File.extname(path).upcase == '.OGG'
          if !File.basename(path).start_with?('.') 
            @mp3s.push Song.new(path.sub(@webroot, ""), path)
          end
        end
      end
    end
  end
  
  def paths(*options)
    @mp3s.collect { |x| x.webpath(*options) }
  end
  
  def size
    @mp3s.size
  end

end
