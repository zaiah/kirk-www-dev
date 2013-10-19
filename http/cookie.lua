------------------------------------------------------
-- cookie.lua 
--
-- Functions to handle setting up cookies. 
------------------------------------------------------

local cookie = {
	["new"] = function (t)
		-- Retrieve from t. 
		-- Retrieve from t. 
		local security, id_string	
		local cookie_headers = {"domain","expires","maxage","path"}
		local cookie_t = table.append_with_names(
			{"domain","expires","maxage","path"},
			{"Domain=","Expires=","Max-Age=","path="},
		t)


		-- Get the others...
		local ids = table.retrieve_non_matching(cookie_headers,t) 
		local idt = table.append_with_delim( table.keys(ids), ids, "=")
		id_string = table.concat(idt,';')


		-- Dates
		datePast = 'Sat, 05-Nov-2011 13:28:14 GMT' 
		dateFuture = 'Sat, 05-Nov-2013 13:28:14 GMT' 


		-- Defaults
		if not t.expiry then table.insert(cookie_t,"Expires=" .. dateFuture) end
		if t.secure then table.insert(cookie_t,"secure")
		else table.insert(cookie_t,"HttpOnly") end

	
		-- Set a cookie.
		local cookie_s = table.concat(cookie_t,";")

		-- Add a trailing semicolon.
		if string.sub( id_string, string.len(id_string) ) ~= ';'
		then
			id_string = id_string .. ";"
		end

		HEADERS.USER['Set-Cookie'] = id_string .. cookie_s
		-- return pt.iso8601(1371437546)
	end,

	------------------------------------------------------
	-- .die() 
	--
	-- Kill a cookie. 
	-- *nil
	------------------------------------------------------
	["die"] = function ( id )
		if type(id) == 'string' then
			HEADERS.USER["Set-Cookie"] = "sess_id=" .. id .. ";Expires="	
				.. 'Sat, 05-Nov-2011 13:28:14 GMT; HttpOnly' 
		end
	end,

	------------------------------------------------------
	-- .retrieve() 
	--
	-- Get a cookie out of the database. 
	-- *string
	------------------------------------------------------
	["retrieve"] = function ()
		if type(s) == 'string' then
			if is.key(s,COOKIES) then return COOKIES[s] end
		end
	end,

	------------------------------------------------------
	-- .exists() 
	--
	-- If a cookie exists, return true.
	-- *bool
	------------------------------------------------------
	["exists"] = function (t)
		local status = false
		if type(t) == 'table' and is.ni(t) then
			for _,value in ipairs(t) do
				if is.key(value,COOKIES) then
					status = true
				end
			end
 
		elseif type(t) == 'string' then
			if is.key(t,COOKIES) then status = true end	
		end
		return status
	end,

	------------------------------------------------------
	-- set_expiry() 
	--
	-- Set a new expiry date for a cookie. 
	-- *nil
	------------------------------------------------------
	["set_expiry"] = function (n)
		-- pt.gmt( n )
		HEADERS.USER["Set-Cookie"] = "ID=death;Expires="
--		 .. pt.gmt(n) .. 'HttpOnly' 
	end,
}
