------------------------------------------------------
-- cli.lua 
--
-- A command-line handler for errors and whatnot. 
--
-- Lots of options:
--
-- Submit POSTs
-- Run GETs
-- Run HEADs
-- Emulate servers?
-- Run with different CGI/FCGI/... values
------------------------------------------------------

local CLI = {}

local CLI_CGI_DEFAULT = {	
AUTH_TYPE = "",	-- What is this?
GATEWAY_INTERFACE = "",
PATH_INFO = "",
PATH_TRANSLATED,
QUERY_STRING,
REMOTE_ADDR,
REQUEST_METHOD,
SCRIPT_NAME,
HTTP_COOKIE,
HTTP_INTERNAL_SERVER_ERROR,
SERVER_NAME = "kirk-cli",
SERVER_PORT = 0,
SERVER_PROTOCOL = "",
SERVER_SOFTWARE = "kirk",
REMOTE_HOST = "",
REMOTE_IDENT = "",
REMOTE_USER = "",
}

for x,n in ipairs(args) do
	if n == 'path' then CGI.PATH_INFO = args[x + 1]
	elseif n == 'cgi' then
		for x,y in pairs(CGI) do P(x .. '\t' .. y) end
	end 
end

