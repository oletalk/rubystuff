require 'logger'
require './conf/default'

$LOG = Logger.new(MP3S::Config::Logs[:path], 'weekly')

dt_format = MP3S::Config::Logs[:datetime_format]
$LOG.formatter = proc do |severity, datetime, progname, msg|
	newdatetime = dt_format.nil? ? datetime : datetime.strftime(dt_format)
	"#{newdatetime} #{severity}: #{msg}\n"
end
