#!/usr/bin/lua
------------------------------------------------------
-- index.lua
--
-- Main handler for CGI/FCGI scripts.
--
-- More configuration is going to move:
-- We're also going to do this loading via
-- coroutines and cut whatever cycles possible.
--
-- The unfortunate side effect is that pg may
-- end up EXTREMELY long...
--
-- Also standardize error messages:
-- 
------------------------------------------------------

------------------------------------------------------
-- Global configuration. 
-- Will be moving to data/definitions with time.
--
-- Dates
--  Sun, 06 Nov 1994 08:49:37 GMT  ; RFC 822, updated by RFC 1123
--  Sunday, 06-Nov-94 08:49:37 GMT ; RFC 850, obsoleted by RFC 1036
--  Sun Nov  6 08:49:37 1994       ; ANSI C's asctime() format
------------------------------------------------------
VERSION = "Pagan 1.1"
LOCALE  = "EN:us"
DATE	  = os.date('*t',os.time())
NOW     = function () return os.date('*t', os.time()) end
TIME 	  = os.time()
-- L		  = require("i18n.locale")
-- print( env )
date	  = {
	["asctime"] = function ()
		return string.format('%s %s %d %d:%d:%d',
			string.sub(L.days[DATE.wday],1,3), 
			string.sub(L.months[DATE.month],1,3), 
			DATE.day, 
			DATE.hour, 
			DATE.min,
			DATE.sec)
	end
}

------------------------------------------------------
-- The absolute thinnest stack possible doesn't need
-- any of this.
--
-- You only need a response library:
--		capable of processing headers
--		and parsing a response
------------------------------------------------------

------------------------------------------------------
-- Get the configuration and include optional debug.
------------------------------------------------------
pg = dofile("../data/definitions.lua")  -- Data file.

------------------------------------------------------
-- is = More robust value testing.
-- table = More robust table functions.
-- html = HTML encapsulation and body population.
--
-- D = Work with databases. 
-- E = Do basic routing.
-- F = Work with files.
-- N = Encode strings and URLs.
-- C = Work quickly with content.
--
-- Next question is smarter inclusion.
-- (This is going to take forever on bigger sites.)
--
-- Encapsulating each within a function delays -- processing.
------------------------------------------------------
is 		= require("extension.tests").is 	-- Useful tests.
are 		= require("extension.tests").are	-- More useful tests.
table 	= require("extension.tables")		-- Table extensions. 
string 	= require("extension.strings") 	-- String extensions. 
date		= require("extension.date")		-- Dates
arg		= require("extension.arg")			-- Repetitive argument processing.
uuid		= require("extension.uuid")		-- Ridiculous error handling.
-- co		= require("extension.coroutine") -- Send functions through coroutines.

html  	= require("http.html").html		-- HTML encapsulation.
cookie  	= require("http.cookie")			-- Cookies
_			= html									-- (syntactic sugar)
htags		= require("http.html").htags		-- List of available HTML tags

D 			= require("ds.db")					-- ORM interface
E 			= require("http.eval")				-- Routing and resources.
cookie 	= require("http.cookie")			-- Cookie handling.
F 			= require("file.file") 				-- File interaction
add 		= require("file.add")				-- Preload common files.
-- S 		= require("http.sockets")			-- Send data over sockets.
C 			= require("ds.content")				-- Get something from a database.
as 		= require("ds.serialization")		-- Serialization formats.
console	= require("debugger")				-- Debugging ability.
die		= require("error")					-- Ridiculous error handling.
 
R 			= function (fname) 					-- Add error pages.  
	return add.err(fname) end
LOG 		= require("ds.log")					-- Debugging if we asked for it.
	if not pg.pgdebug then
		for k,_ in pairs(LOG) do
			LOG[k] = function () return nil end end end
response = require("http.response")
content_types = require("http.content-types")
xmlhttp  = require("http.xmlhttp")


------------------------------------------------------
-- There must be something else that will help you
-- create this.
------------------------------------------------------
pg.dbsch	= D.generate_schema(pg.dbname) 

------------------------------------------------------
-- Finally add the globals needed to make this useful.
------------------------------------------------------
data = {}					-- Globally accessible data.
data.url  = {}				-- Hold URIs.
data.resource = {}		-- Preprocessed datastore records.
HEADERS 		 = {}			-- Pagan's HTTP headers
HEADERS.USER = {}			-- Developer supplied HTTP headers.

------------------------------------------------------
-- crbody(queue,t) 
--
-- Append queue to t, to generate a message body for
-- stdout or stderr. 
-- 
-- Also discards strings when simply concatenating 
-- with a comma.  (i.e. P(k,y) does not work like 
-- print(k,y).
------------------------------------------------------
local function crbody(queue,t)
	local int = table.maxn(t) or 0

	-- Is [queue] a table?
	if type(queue) == 'table'			
	then
		if is.ni(queue) then
			t[int + 1] = table.concat(queue,"\n")
		else
			return
		end

	-- Check for either function or nil.
	elseif type(queue) == 'function' 
	 or type(queue) == 'nil' 			
	then
		t[int + 1] = tostring(queue)

	-- Is [queue] a string or a number?
	elseif type(queue) == 'string' 
	 or type(queue) == 'number'	-- String
	then
		t[int + 1] = queue 

	-- [queue] can't do any userdata.
	elseif type(queue) == 'userdata'
	then
		response.abort({500},"Cannot parse or interpret eleemnt of type `userdata`: " ..
			tostring(userdata))
	end
end

------------------------------------------------------
-- STDIO, STDERR {}
--
-- Tables for emulating standard in and standard out. 
------------------------------------------------------
STDOUT, STDERR = {}, {}

------------------------------------------------------
-- P(queue), B(queue)
--
-- Functions to add to STDOUT and STDERR, 
-- respectively.
------------------------------------------------------
P = function (queue) crbody(queue,STDOUT) end
B = function (queue) crbody(queue,STDERR) end

------------------------------------------------------
-- CLI {} 
--
-- Command line interface mode and options. 
-- WARNING: Will be ported later.
------------------------------------------------------
local CLI = {}
args = {...}

------------------------------------------------------
-- Security and overrides.
-- RESTRICTED {} = Functions that aren't allowed. 
-- LOCAL_ONLY {} = Eventually these may be allowed.
------------------------------------------------------
RESTRICTED = {
	-- "os",
	"assert",
	"_VERSION",
	"module",
	"debug",
	"_G",
}

LOCAL_ONLY = {
	"getfenv",
	"setfenv"
}

for _,e in ipairs(table.assimilate(LOCAL_ONLY,RESTRICTED))
do
	e = nil
end

os.execute 	= nil
dofile		= nil
debug 	  	= nil

------------------------------------------------------ 
-- Options parsing.
-- 
-- Needs some way to block execution.
------------------------------------------------------
if pg.cli_on 
then
	-- Evaluate any options.
	local oo = require("cli/options")( {...} )	
	if type(oo) == 'table' then
		require("cli/logic")( oo )
	end	
end

------------------------------------------------------ 
-- Parse a certain backend.
------------------------------------------------------
if pg.backend == 'CGI' or pg.backend == 'cgi'
 or not pg.backend
then
	require("handlers.cgi")

elseif pg.backend == 'FCGI' or pg.backend == 'fcgi'
then
	require("handlers.fcgi")

elseif pg.backend == 'WSAPI' or pg.backend == 'wsapi'
then
	require("handlers.wsapi")

elseif pg.backend == 'CLI' or pg.backend == 'cli'
then
	require("handlers.cli")

end

os.getenv 	= nil
