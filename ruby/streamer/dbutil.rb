require './dbaccess'

class DButil < DB

	def startup(recreate=false)
		if recreate
			s = IO.read('./db/schema.sql')
			exec(s)
		end
	end

	def read_tag(filepath)
		res = exec('SELECT artist, title, secs FROM mp3song WHERE path = $1', [filepath])
		artist = nil
		title = nil
		secs = nil
		res.each do |tuple|
			artist = tuple['artist']
			title = tuple['title']
			secs = tuple['secs']
		end
		{ 'artist' => artist, 'title' => title, 'secs' => secs }
	end

	def store_tag_info(filepath, artist, title, secs)
		exec('BEGIN TRANSACTION')
		exec('UPDATE mp3song SET artist = $2, title = $3, secs = $4 WHERE path = $1', 
					[filepath, artist, title, secs])
		exec('INSERT INTO mp3song (path, artist, title, secs) SELECT $1::VARCHAR, $2, $3, $4 WHERE NOT EXISTS (SELECT 1 FROM mp3song WHERE path = $1)', [filepath, artist, title, secs])
		exec('COMMIT TRANSACTION')
	end
end
