------------------------------------------------------
-- cgi.lua 
--
-- A CGI handler for Kirk.
------------------------------------------------------

------------------------------------------------------
-- CGI {} 
--
-- Table containing values where found from above.
-- All of these need to be stored in like data.cgi
-- or something.
------------------------------------------------------
if not CGI 
then
	-- Make a global CGI table here.
	CGI = {}

	-- Move through environment variables.
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

	-- Transform each value in t with the function f.
	-- Can possibly set a chain by using a table.
	-- (Formerly was table.populate..., and not too 
	-- descriptive.) 
	-- table.transform(t, f)
end

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
if CGI
then
	if CGI.REQUEST_METHOD == "HEAD" -- and REQUEST.HEADER["is_xml_http"] = true
	then
		-- Receiving the correct header here would really help.
		-- Formulate a compliant date.
		HEADERS.USER["time_to_generate"] = date.cookie(RECVD)
		HEADERS.USER["time_to_ship"] = date.cookie()

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

	------------------------------------------------------
	-- POST can be accessed globally just like GET.
	------------------------------------------------------
	POST = require("http.post")(CGI,CLI)

	------------------------------------------------------ 
	-- Die if the server brings back an error.
	------------------------------------------------------
	if CGI.HTTP_INTERNAL_SERVER_ERROR then
		die.with(500, { msg = CGI.HTTP_INTERNAL_SERVER_ERROR })
	--	response.abort({500}, CGI.HTTP_INTERNAL_SERVER_ERROR)
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
	-- CGI lua
	------------------------------------------------------
	local function srv_default()
		if pg.default and pg.default.page
		then
			F.asset("skel")
			local f = F.exists( pg.default.page .. ".lua" )
			if f.status 
			then
				req = interpret.file( f.handle )  -- "../skel/" .. pg.default.page .. ".lua")
				response.abort( {200}, req )
			else
				die.with(500, { 
					msg = "No file '" .. pg.default.page .. ".lua' could be found at path '" .. pg.path .. "/skel.'",
					stacktrace = "None."
				})
			end
		else
			die.with(200, { 
				msg = [[Kirk is working, but no default page has been 
				defined in ]] .. pg.path .. "/data/definitions.lua",
				stacktrace = "Try setting the value of 'page' in definitions.lua to "
				.. "a file name under the \n directory " .. pg.path .. "/skel."
			})
		end
	end

	------------------------------------------------------
	-- Start at everything besides the root.
	------------------------------------------------------
	local req
	local file_check
	local rname
	------------------------------------------------------
	-- We must be at the root, so evaluate a default
	-- request.
	------------------------------------------------------
	if CGI.PATH_INFO == "/"
	then
		if pg.default and pg.default.page
		then
			F.asset("skel")
			local f = F.exists( pg.default.page .. ".lua" )
			if f.status 
			then
				req = interpret.file( f.handle )  -- "../skel/" .. pg.default.page .. ".lua")
				response.abort( {200}, req )
			else
				die.with(500, { 
					msg = "No file '" .. pg.default.page .. ".lua' could be found " .. 
					"at path '" .. pg.path .. "/skel.'",
					stacktrace = "None."
				})
			end
		else
			die.with(200, { 
				msg = [[Kirk is working, but no default page has been 
				defined in ]] .. pg.path .. "/data/definitions.lua",
				stacktrace = "Try setting the value of 'page' in definitions.lua to "
				.. "a file name under the \n directory " .. pg.path .. "/skel."
			})
		end

	------------------------------------------------------
	-- Serve all resources besides /.
	------------------------------------------------------
	elseif CGI.PATH_INFO ~= "/"
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
		local urlt = {}
		for v in url do
			if v ~= "" then
				table.insert(data.url, v)
			end
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
				rname = data.url[level] -- Resource name.

				------------------------------------------------------
				-- Serve for resources and only if we found no error.
				------------------------------------------------------
				if is.key(rname, pg.pages)
				then
					is_page = true
					F.asset("skel")

					-- Check a certain set of files. 
					if pg.default and pg.default.page
					then
						file_check = { 
							pg.pages[rname],
							pg.pages[rname] .. "/" .. pg.default.page
						}
					else
						file_check = { pg.pages[rname] }
					end

					------------------------------------------------------
					-- Loop through each file.
					------------------------------------------------------
					for __,ffile in ipairs( file_check )
					do
						------------------------------------------------------
						-- If we found the page, great. 
						------------------------------------------------------
						srv = F.exists(ffile,".lua")

						------------------------------------------------------
						-- Serve the resource if it was found. 
						------------------------------------------------------
						if srv.status == true
						then 
							req = interpret.file(srv.handle)
							response.abort({200}, req)
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
				-- Die will be handling the other 404's...
				die.with(404, {
					msg = "Resource at '<i>/" .. rname .. "</i>' could not be found."
				})
			else
				srv_default()
			end

		------------------------------------------------------
		-- If this is our only resource, we need to serve
		-- the regular backend.
		-- Only needs to run if NOTHING is found.
		------------------------------------------------------
		else
			srv_default()
		--	req = interpret("../skel/" .. pg.default.page .. ".lua")
		--	response.send({200}, req.msg() )
		--	response.send( {200}, req )
		end
	end
end
