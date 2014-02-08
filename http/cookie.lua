------------------------------------------------------
-- cookie.lua 
--
-- Functions to handle setting up cookies. 
------------------------------------------------------
------------------------------------------------------
-- diff {} 
--
-- Local methods for calculating different time
-- units.
------------------------------------------------------
local function diff_secs(n)
	if type(n) == 'number'
	then
	return n * 86400
	else
		response.abort({500}, "Argument supplied to diff_secs() is not a number!")
		die.with(500, "Argument supplied to diff_secs() is not a number!")
	end
end

return  {
   ------------------------------------------------------
   -- .new (t) / .bake() 
   --
   -- Create a new cookie.
	--
	-- t must be a table and can contain:
	-- domain:
	-- expires:
	-- maxage:
	-- path:
	--
	-- A cookie must contain at least a domain, a path and
	-- some expiry.  No "expires" parameter will default
	-- to a cookie that does not expire.  Domain will
	-- default to pg.sitename if it exists.  Path will
	-- default to root (/).
	--
	-- Be careful if you need a shorter expiry time, right
	-- now .new only takes seconds as an argument.  the 
	-- date library is under construction.	
	--
	-- *nil
   ------------------------------------------------------
	new = function (t)
		-- Define some places.
		local security, id_string	
		local cookie_t 				-- Table keys adhering to cookie spec.
		local iden_t 					-- Where any user supplied IDs are held.
		local cookie_headers = {"domain","expires","maxage","path"}

		-- Retrieve a user's cookie values if supplied.
		if type(t) == 'table'
		then
			-- Retrieve cookie identifiers that don't land within the spec.
			iden_t = table.retrieve_non_matching(cookie_headers,t) 
			iden_t = table.append_with_delim( table.keys(iden_t), iden_t, "=")

			-- Debugging the actual cookie time.
			---[[
			-- response.abort({200}, date.cookie( os.time() + diff_secs( t.expires ) ))	
			-- response.abort({200}, date.cookie( 86400 ))
			-- Notice this, when GMT is not tz, 3600 * 5 is epoch...
			-- response.abort({200}, date.cookie( 3600 * 5 ))
			--]]

			-- Get expires time.
			if t.expires and type(t.expires) == 'number'
			then	
			--		table.insert(cookie_t,"Expires=" .. date.cookie() ) 
				t.expires = date.cookie( os.time() + diff_secs( t.expires ) )
			end

			--[[
		  	response.abort( {200}, table.concat({
				t.expires .. " GMT"
			}))
			--]]

			-- Get or create maxage.
			if t.maxage and type(t.maxage) == 'number'
			then 
				t.maxage = date.cookie( os.time() + diff_secs( t.maxage ) )
			end

			-- Retrieve all cookie identifiers defined per the spec.
			cookie_t = table.append_with_names(
				{"domain","expires","maxage","path"},
				{"Domain=","Expires=","Max-Age=","path="},
			t)

			-- Make secure or not?
			if t.secure 
			then 
				table.insert(cookie_t,"secure")
			else 
				table.insert(cookie_t,"HttpOnly") 
			end

			-- Debugging what's in the cookie_t data structure.
			--[[
			response.abort({200}, table.dump( cookie_t ))
			--]]

			-- Debugging responses.
			--[[
			response.abort({200}, table.concat({
			  "Cookie Spec: " .. table.concat(cookie_t,';'),
			  "User supplied: " .. table.concat(iden_t,';')
			},"<br />"))
			--]]

		-- Generate a cookie with some sensible defaults. 
		-- Does not send any other values.
		else
			cookie_t = { 
				-- Generate at least random names and value.
				"id=" .. uuid.alnum(10),
				"Expires=" .. date.cookie(), 
				-- "Path=/" 
			}
		end

		-- Set a cookie.
		if type(iden_t) == 'table'
		then
			cookie_t = table.concat({
			--	"lp=ssdfsdfsaffd",
				table.concat(iden_t,"; "),
				table.concat(cookie_t,"; "),
			}, '; ') 

		-- Not so sure this is the greatest of choices.
		else
			cookie_t = table.concat(cookie_t,"; ")
		end

		-- Insert into header table until kirk is ready to send a response.
		HEADERS.USER['Set-Cookie'] = cookie_t
		---[[
		response.abort({200}, table.concat({
		  "What's in HEADERS.USER?: " .. table.dump(HEADERS.USER)
		},"<br />"))
		--]]
	end,

	------------------------------------------------------
	-- .delete() / .eat() 
	--
	-- Destroys a cookie. 
	-- *nil
	------------------------------------------------------
	delete = function ( id )
		HEADERS.USER["Set-Cookie"] = table.concat({
			tostring(id or "id") ..  "=" .. "deleted", 
			"Expires=" .. date.cookie( 0 )
		},'; ')	
	end,

	------------------------------------------------------
	-- .retrieve() / .taste()
	--
	-- Get a cookie out of the database. 
	-- *string
	------------------------------------------------------
	retrieve = function (s)
		if COOKIES and type(COOKIES) == 'table'
		then
			response.abort({200}, table.concat({
				"Cookies: ",
				tostring(table.dump( COOKIES ))
			}))
		end
 
		if type(s) == 'string' then
			if is.key(s,COOKIES) then return COOKIES[s] end
		end
	end,

	------------------------------------------------------
	-- .exists() / .smell() 
	--
	-- If a cookie exists, return true.
	-- *bool
	------------------------------------------------------
	exists = function (t)
		local status = false

		-- Check for multiple cookies?	
		if type(t) == 'table' and is.ni(t) 
		then
			for _,value in ipairs(t) do
				if is.key(value,COOKIES) then
					status = true
				end
			end

		-- Check for one cookie. 
		elseif type(t) == 'string' then
			if COOKIES and is.key(t,COOKIES) 
			then 
				status = true 
			end	
		end
		return status
	end,
}
