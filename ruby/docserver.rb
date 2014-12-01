require 'gserver'
require 'uri'

class DocServer < GServer
  include ContentTypeGuesser
  # Files will be served from this directory
  attr_accessor :webroot

  def initialize(port=2345, *args) # 30/11/2014 - specify port and host e.g. 0.0.0.0, in that order
    super(port, *args)
    @webroot = '.'
  end
  
  def error(detail)
    puts "PROBLEM!"
    puts $!, $@
  end
  
  def requested_file(request_line)
    #begin
      request_uri = request_line.split(" ")[0]
      path        = URI.unescape(URI(request_uri).path)
      log "In REQUESTED FILE"
      clean = []
    #rescue
    #  log "----------------------\nproblem..."
    #  puts $!, $@
    #end
    
    # Split the path into components
    parts = path.split("/")

    parts.each do |part|
      #skip any empty or current directory (".") path components
      next if part.empty? || part == '.'
      # If the path component goes up one directory level (".."),
      # remove the last clean component.
      # Otherwise, add the component to the Array of clean components
      part == '..' ? clean.pop : clean << part
    end

    # return the web root joined to the clean path
    File.join(@webroot, *clean)
  end
  
  def serve(io)
    request_line = io.readline
    /\/(?<command>\w+)(?<cmdpath>\/.*)$/ =~ request_line
    log "Command: #{command}. Path: #{cmdpath}"

    path = requested_file(cmdpath)
    log "PATH IS #{path}"
    path = File.join(path, 'index.html') if File.directory?(path)
    if File.exist?(path) && !File.directory?(path)
      File.open(path, "rb") do |file|
        io.puts "HTTP/1.1 200 OK\r\n" +
                     "Content-Type: #{content_type(file)}\r\n" +
                     "Content-Length: #{file.size}\r\n" +
                     "Connection: close\r\n"

        io.puts "\r\n"
        STDERR.puts "Requested file #{path} written"

        # write the contents of the file to the socket
        IO.copy_stream(file, io)
      end
    else
      message = "File not found"
      # respond with a 404 error code to indicate the file does not exist
      io.puts "HTTP/1.1 404 Not Found\r\n" +
                   "Content-Type: text/plain\r\n" +
                   "Content-Length: #{message.size}\r\n" +
                   "Connection: close\r\n"

      io.puts "\r\n"
      io.puts message
    end

  end
end

# Run the server with logging enabled
#server = DocServer.new
#server.audit = true
#server.start
