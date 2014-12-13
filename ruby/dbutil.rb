require './dbaccess'

class DButil < DB

	def startup(recreate=false)
		if recreate
			s = File.open('./db/schema.sql')
			exec(s)
		end
	end
end
