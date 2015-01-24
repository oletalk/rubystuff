require './conf/clientlist'
require 'ipaddr'
require './log'

module Screener

	def check_remote_ip(ip)
		remote_ip = IPAddr.new(ip)
		action = MP3S::Config::DefaultAction
		@downsampling = MP3S::Config::DefaultDownsample.downcase == 'yes' # any other affirmative string?

		MP3S::Config::ScreenerList.each do |iprange, screeneraction|
			# note screeneraction looks like '[ 'ALLOW', 'NO_DOWNSAMPLE' ]
			if iprange.include?(ip)
				@screener_action = screeneraction
				if screeneraction.size > 1
					dsample = screeneraction[1].downcase != 'no_downsample'
					dsample_default = @downsampling
					# these will take effect if they reverse the default choice
					if dsample != dsample_default
						@downsampling = dsample
					end
				end
			end
		end
		$LOG.info "Action for #{ip} is #{@screener_action}"
		@screener_action
	end

	def ip_allowed?
		@screener_action[0] == 'ALLOW'
	end

	def downsampling?
		@downsampling
	end

end
