require './contenttypeguesser'
require './docserver'
d = DocServer.new(2345, '0.0.0.0')
d.webroot = '/home/colin/public_html'
d.start
d.audit = true
d.debug = true
sleep 100
d.stop
