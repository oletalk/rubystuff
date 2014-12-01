module ContentTypeGuesser
	# Map extensions to their content type
	CONTENT_TYPE_MAPPING = {
	  'html' => 'text/html',
	  'txt' => 'text/plain',
	  'png' => 'image/png',
	  'jpg' => 'image/jpeg'
	}

	# Treat as binary data if content type cannot be found
	DEFAULT_CONTENT_TYPE = 'application/octet-stream'

	def content_type(path)
	  ext = File.extname(path).split(".").last
	  CONTENT_TYPE_MAPPING.fetch(ext, DEFAULT_CONTENT_TYPE)
	end
end