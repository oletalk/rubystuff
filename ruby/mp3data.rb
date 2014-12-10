require 'id3tag'

class Song
  attr_reader :realpath

  def initialize(webpath, realpath)
    @webpath = webpath
    @realpath = realpath
    # TODO: lazily initialise tag info?
	@tag = Tag.new(@realpath)
  end
    
  def webpath(*options)
	(type, header) = *options
	prefix = "http://#{header}"
	if header.nil? || header.empty?
		puts "WARNING! Null or empty HTTP_HEADER"
	end

    if type == 'playurl'
      '<a href="/play' + @webpath + '">' + @webpath + '</a>'
	elsif type == 'm3u'
# TODO: unhardcode these
		artist = @tag.artist || 'Artist'
		title = @tag.title || 'Title'
		taginfo = "#{artist} - #{title}"

		artist.strip!
		title.strip!

		secs = @tag.length || '-1'
	  "#EXTINF:#{secs},#{taginfo}\n#{prefix}/play" + URI.escape(@webpath)
    else
      @webpath
    end
  end
end

class Tag
	attr_accessor :artist, :title, :length

	def initialize(filepath)
		mp3file = File.open(filepath)
		tag = ID3Tag.read(mp3file)

		@artist = tag.artist
		@title = tag.title
		@length = -1

    # grab length if it is there
		tlen_frame = tag.get_frame(:TLEN)
	  unless (tlen_frame.nil? || tlen_frame.content.nil?)
			@length = tlen_frame.content.to_i / 1000
		end

		@artist.strip! unless @artist.nil?
		@title.strip! unless @title.nil?
		puts self.inspect
	end
end
