require 'ipaddr'

module MP3S
	module Config
		ScreenerList = [ 
			[	IPAddr.new("192.168.0.0/24"), [ 'ALLOW', 'NO_DOWNSAMPLE' ] ],
			[	IPAddr.new("109.148.232.0/24"), [ 'ALLOW' ] ],
			[	IPAddr.new("211.211.0.0/16"), [ 'DENY' ] ]
		]

		DefaultAction = 'BLOCK'
		DefaultDownsample = 'YES'
	end
end
