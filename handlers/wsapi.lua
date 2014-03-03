------------------------------------------------------
-- wsapi.lua 
--
-- A WSAPI handler.
--
-- *nil 
------------------------------------------------------

local data = {}
data.url	  = {}
local CGI = require ("wsapi.cgi")		-- CGI Backend
local REQ = require ("wsapi.request")	-- Access to the request library.
local RES = require ("wsapi.response")	-- Access to the response library.

local S = {}	-- Entire Stream. 
local K = {}	-- Socket?

-- table.all(REQ.method)	
-- CGI.run()
