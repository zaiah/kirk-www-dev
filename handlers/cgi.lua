------------------------------------------------------
-- cgi.lua 
--
-- A CGI handler. 
--
-- *nil
------------------------------------------------------

------------------------------------------------------
-- CGI {} 
--
-- Table containing values where found from above.
-- All of these need to be stored in like data.cgi
-- or something.
------------------------------------------------------
CGI = {} 


for _,cv in ipairs({
	"AUTH_TYPE",
	"GATEWAY_INTERFACE",
	"PATH_INFO",
	"PATH_TRANSLATED",
	"QUERY_STRING",
	"REMOTE_ADDR",
	"REQUEST_METHOD",
	"SCRIPT_NAME",
	"HTTP_COOKIE",
	"HTTP_INTERNAL_SERVER_ERROR",
	"SERVER_NAME",
	"SERVER_PORT",
	"SERVER_PROTOCOL",
	"SERVER_SOFTWARE",
	"REMOTE_HOST",
	"REMOTE_IDENT",
	"REMOTE_USER",
})
do
	CGI[cv] = os.getenv(cv)
end

require("handlers.cli")

------------------------------------------------------
-- Again, the absolute thinnest stack possible doesn't 
-- need any of this.
--
-- You only need a response library:
--		capable of processing headers
--		and parsing a response
--
-- (i'm trying to say, that this needs to come first.)
------------------------------------------------------
if CGI.REQUEST_METHOD == "HEAD" -- and REQUEST.HEADER["is_xml_http"] = true
then
	-- Get NOW()
	local this_instant = NOW()

	-- Receiving the correct header here would really help.

	-- Formulate a compliant date.
	HEADERS.USER["time_to_generate"] = date.asctime()
	HEADERS.USER["time_to_ship"] = ( function() 
	return string.format('%s %s %d %d:%d:%d',
		string.sub(L.days[this_instant.wday],1,3), 
		string.sub(L.months[this_instant.month],1,3), 
		this_instant.day, 
		this_instant.hour, 
		this_instant.min,
		this_instant.sec)
	end )()

	-- Send the response.
	response.abort({200}, "")
end

------------------------------------------------------
-- POST processing routines. 
------------------------------------------------------
if CGI.REQUEST_METHOD == "POST"
then
	for _,val in ipairs({"CONTENT_TYPE","CONTENT_LENGTH"})
	do
		CGI[val] = os.getenv(val)
	end
end
POST = require("http.post")(CGI,CLI)


------------------------------------------------------ 
-- Grab the response methods.
------------------------------------------------------
if CGI.HTTP_INTERNAL_SERVER_ERROR then
	response.send({500},CGI.HTTP_INTERNAL_SERVER_ERROR)
end	

------------------------------------------------------
-- Get the cookies available.
--
-- Being a scientist is fucking hard...
------------------------------------------------------
if CGI.HTTP_COOKIE then
	-- Chop the string.
	COOKIES = {}
	for _,value in ipairs(table.from(CGI.HTTP_COOKIE,'; '))
	do
		local cookie_s = string.chop(value,'=')
		COOKIES[cookie_s.key] = cookie_s.value
	end
end

------------------------------------------------------
-- Load our page and parse for errors. 
------------------------------------------------------
local function srv_req (file)
	local loader = ({loadfile( file )})
	return {
		msg = loader[1],
		errmsg = loader[2],
	}
end	


------------------------------------------------------
-- Start at everything besides the root.
------------------------------------------------------
if CGI.PATH_INFO ~= "/"
then

	------------------------------------------------------
	-- Chop the path and save it.
	------------------------------------------------------
	local count, srv = 1, {}
	local is_page
	local url = string.gmatch(CGI.PATH_INFO,'/([0-9,A-Z,a-z,_,\(,\),#,-]*)')
		
	------------------------------------------------------
	-- Save GET.  
	------------------------------------------------------
	if CGI.QUERY_STRING then
		GET = require("http.get")(CGI.QUERY_STRING)
	end

	------------------------------------------------------
	-- Make the url more accessible.
	------------------------------------------------------
	for v in url do
		data.url[count] = v
		count				 = count + 1
	end

	------------------------------------------------------
	-- Check the blocks of the URL. 
	-- Do they exist in pg.pages?
	--
	-- Possibly break this up so that the searches take
	-- place against a table vs. iterating through 
	-- possible failures.
	--
	-- Table would be generated from everything in the
	-- url.
	-----------------------------------------------------
	if pg.pages 
	then
		for level = table.maxn(data.url),1,-1 
		do	
			local rname = data.url[level] -- Resource name.

			------------------------------------------------------
			-- Serve for resources and only if we found no error.
			------------------------------------------------------
			if is.key(rname, pg.pages)
			then
				is_page = true
				F.asset("skel")
				for _,f in ipairs({
					-- Look for a skel in the top-level, then...
					tostring(pg.pages[rname]),
					-- ...look for a skel in respectively named directory.
					tostring(pg.pages[rname] .. "/" .. pg.default.page)
				}) 
				do

					------------------------------------------------------
					-- If we found the page, great. 
					-- See if there are any errors at req.errmsg.
					------------------------------------------------------
					srv = F.exists(f,".lua")
					if srv.status == true
					then 
					--	local req = srv_req("../skel/" .. srv.handle)
						local req = srv_req(srv.handle)

						------------------------------------------------------
						-- Return error if we run into syntax errors.
						--
						-- Still doesn't work.  When html has blank args
						-- error is not propagating.
						------------------------------------------------------
						if req.errmsg 
						then
							response.send({500}, req.errmsg)
							return false

						------------------------------------------------------
						-- Return our nicely formatted skel if not.
						------------------------------------------------------
						else
							response.send({200}, req.msg())
							if pg.pgdebug then 
								h = dg.console({
									server_side = true,
									tables = true,
									external = true,
									timing = os.time(), -- function to start and stop.	
								})
							end
							return true
						end
					end -- end if srv.status == true
				end -- end for _,f in ipairs({
			end -- end if is.key(rname, pg.pages) 
		end -- for level = table.maxn(data.url),1,-1

		------------------------------------------------------
		-- If we've defined a resource and didn't find the 
		-- page, that's bad. You'll need to send a 404 back.
		------------------------------------------------------
		if not srv.status
		 and is_page
		then
			response.send({404}, add.err("404"))
			return false
		else
			local req = srv_req("../skel/" .. pg.default.page .. ".lua")
			response.send({200}, req.msg() )
			return true
		end

	------------------------------------------------------
	-- If this is our only resource, we need to serve
	-- the regular backend.
	-- Only needs to run if NOTHING is found.
	------------------------------------------------------
	else
		local req = srv_req("../skel/" .. pg.default.page .. ".lua")
		response.send({200}, req.msg() )
		return true
	end

------------------------------------------------------
-- We must be at the root, so evaluate a default
-- request.
------------------------------------------------------
elseif CGI.PATH_INFO == "/"
then
	local req = srv_req("../skel/" .. pg.default.page .. ".lua")
	if req.errmsg 
	then
		response.send({500}, req.errmsg)
		return false
	else
		response.abort({200}, req.msg())
		return true
	end
end

