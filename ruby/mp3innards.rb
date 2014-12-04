require 'find'
require 'uri'

LIST_HEADER = '<h2>Song listing</h2>'
BR = '<br/>'
RC_OK = '200'
RC_NOT_FOUND = '404'

class Commander
  def initialize(app, request_line)
    /\/(?<command>\w+)(?<cmdpath>\/.*)$/ =~ request_line
    @command = command
    @cmdpath = cmdpath
    @app     = app
    @returncode = RC_OK
    @headers = {'Content-Type' => 'text/html'}
    puts "Command: #{@command}. Path: #{@cmdpath} (Original request_line is '#{request_line}')"
  end
  
  def response
    msg = "Hello World"
    @returncode = RC_OK
    
    #TODO: msg = Responder.new(@command, @cmdpath).response
    # looks like they may have to return all three elements (see bottom of this method)
    if @command == 'play'
      @headers['Content-Type'] = 'application/octet-stream; charset=utf8'
      # TODO: don't cache anything
      msg = contents_from_cmdpath
    elsif @command == 'list'
      puts @app.playlist.paths(nil).inspect
      msg = LIST_HEADER + @app.playlist.paths('playurl').join(BR)
    end
    if @command != 'play'
      puts msg
    end
    
    [ @returncode, @headers, [ msg ]]
  end
  
  private
  def contents_from_cmdpath()
    finalpath = @app.webroot + URI.unescape(@cmdpath)
    begin
      IO.read(finalpath)
    rescue Errno::ENOENT
      puts "Given path #{finalpath} was not found"
      @returncode = RC_NOT_FOUND
      @headers['Content-Type'] = 'text/html'
      "File not found"
    end
  end
end

class Song
  attr_reader :realpath

  def initialize(webpath, realpath)
    @webpath = webpath
    @realpath = realpath
  end
    
  def webpath(options)
    if (options == 'playurl')
      '<a href="/play' + @webpath + '">' + @webpath + '</a>'
    else
      @webpath
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
  
  def paths(options)
    @mp3s.collect { |x| x.webpath(options) }
  end
  
  def size
    @mp3s.size
  end
end