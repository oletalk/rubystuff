require 'pg'
require './conf/db'

class DB

	def initialize
		@conn = PG::Connection.new(:dbname => MP3S::Config::DB[:name], 
														   :user   => MP3S::Config::DB[:user],
														   :password => MP3S::Config::DB[:password])
	end

	def exec(*params)
		@conn.exec_params(*params)
	end
end



