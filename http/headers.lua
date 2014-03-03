------------------------------------------------------
-- headers.lua
--
-- List of possible headers to send to server. 
------------------------------------------------------
------------------------------------------------------
-- REQ_HEADERS{} - Table of request headers.
------------------------------------------------------
HEADERS = {}

HEADERS.REQUEST = {
["Connection"] 	= "",
["Date"] 			= date.asctime(),
["MIME-Version"] 	= "",
["Trailer"] 		= "",
["Transfer-Encoding"] = "",
["Upgrade"] 		= "",
["Via"] 				= "",
["Cache-Control"] = "",
["Client-IP"] 		= "",	
["From"] 			= "",
["Host"] 			= "",
["Referer"] 		= "",
["User-Agent"] 	= VERSION,

["Accept"] 			= "",
["Accept-Charset"] = "",
["Accept-Encoding"] = "",
["Accept-Language"] = "",
["TE"] 				= "",

["Authorization"] = "", -- OAuth and other fun will go here.
["Cookie"] 			= "",
["Cookie2"] 		= "",

["Max-Forwards"] 	= "",
["Proxy-Authorization"] = "",
["Proxy-Connection"] = ""
}

------------------------------------------------------
-- HEADERS.RES - Table of response headers. 
------------------------------------------------------
HEADERS.RESPONSE = {
["Age"] = "",
["Public"] = "",
["Retry-After"] = "",
["Server"] = "",
["Title"] = "",
["Warning"] = ""
}

------------------------------------------------------
-- HEADERS.NEG {} - Content negotiation headers. 
------------------------------------------------------
HEADERS.NEGOTIATION = {
["Accept-Ranges"] = "",
["Vary"] = ""
}

------------------------------------------------------
-- HEADERS.RSC {} - Response Security Headers. 
------------------------------------------------------
HEADERS.RESPONSE_SECURITY = {
["Proxy-Authenticate"] = "",
["Set-Cookie"] = "",
["Set-Cookie2"] = "",
["WWW-Authenticate"] = ""
}

------------------------------------------------------
-- HEADERS.ENT {} - Entity Request Headers
------------------------------------------------------
HEADERS.ENTITY_REQUEST = {
["Allow"] = "",
["Location"] = ""
}

------------------------------------------------------
-- HEADERS.CNT {} - Content Headers
------------------------------------------------------
HEADERS.CONTENT = {
["Content-Base"] = "",			-- ?? forgot what this is...
["Content-Encoding"] = "",
["Content-Language"] = "",		-- Set from definitions.lua
["Content-Length"] = "",		-- Done at index.
["Content-Location"] = "",		
["Content-MD5"] = "",			-- Done at index.
["Content-Range"] = "",
["Content-Type"] = "",
}

------------------------------------------------------
-- HEADERS.ECA {} - Entity Caching Headers 
------------------------------------------------------
HEADERS.ENTITY_CACHING = {
["ETag"] = "",
["Expires"] = "",
["Last-Modified"] = ""
}

return HEADERS
