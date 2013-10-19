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
	local url			= string.gmatch(
		CGI.PATH_INFO,'/([0-9,A-Z,a-z,_,\(,\),#,-]*)')
	if CGI.QUERY_STRING then
		GET = require("http.get")(CGI.QUERY_STRING)
	end
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
--[[
		local h = "" 
--]]

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
		if pg.pgdebug then
			h = dg.console()
		end
		response.abort({200}, req.msg())
		return true
	end
end
