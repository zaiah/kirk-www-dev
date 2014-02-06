------------------------------------------------------
-- cookie.lua 
--
-- Functions to handle setting up cookies. 
------------------------------------------------------
		-- Complicated date conversion.
		-- Move somewhere else.
		local function pad(n) 
			if n and string.len(n) == 1 and type(n) == 'number'
			then
				return tostring(0 .. n)
			elseif n
			then
				return n
			end
		end

		local days = {
			"Sunday", 
			"Monday", 
			"Tuesday", 
			"Wednesday", 
			"Thursday", 
			"Friday",
			"Saturday"
		}

		local months = {
			"January",
			"February",
			"March",
			"April",
			"May",
			"June",
			"July",
			"August",
			"September",
			"October",
			"November",
			"December"
		}

		local date_tbl

		local function cookie_date( n )
			-- Set a date source.
			local date_src = n or os.time()

			-- This outputs Coordinated Universal Time (GMT?)
			-- local date_tbl = os.date( "*t", date_src )
			
			-- This outputs local time.
			local date_tbl = os.date( "*t", date_src )

			-- ...
			return table.concat({
				string.sub(days[date_tbl.wday],1,3), ", ",
				pad( date_tbl.day ), " ",
				string.sub(months[date_tbl.month],1,3), " ",
				date_tbl.year, " ",
				pad( date_tbl.hour ), ":",
				pad( date_tbl.min ), ":",
				pad( date_tbl.sec )
			})
		end

		-- Seems like you need both time and date.
		-- time should return current tick time.
		-- date should return today's date and some other stuff.

		-- Date is really for formatting,
		-- while time is really for numbers.
		--
		-- Since this is so, automatic padding makes more sense.
		-- Also, all the returns will be strings.
		-- 
		-- Some examples:
		-- You'll need a table for adjustment.
		-- { 	time 		= n, 	  -- Supply a time.
		--   	tz 		= gmt,  -- Account for timezone changes.
		--  	[unit] 	= n	  -- Output offset?
		-- }	
		-- 
		-- date.tz( x )									-- Change timezone temporarily.
		-- date.now()  - Does this make sense?  No... time.now() is a better idea.
		-- date.unix()										-- Outputs '1234123123'
		-- date.gmt()										-- Outputs Wed, 13 Jan
		-- date.second()									-- Outputs '01'
		-- date.minute()									-- Outputs '01'
		-- date.hour()										-- Outputs '01'
		-- date.milliseconds()							-- Outputs '0.001'
		-- date.epoch()									-- Should return the epoch.
		-- date.[etc]()
		-- date.[after,before](nil, {[unit] = 7}) -- Outputs date incrementing 
																-- or decrementing by [unit]
																-- where [unit] = units of time.
		-- This can become an application
		--
		-- You can return a range, but you'll hvae to format it, figure out how
		-- you want iterate over the range (every day, every hour, every second?, etc)
		--	
		-- dotevery will need it.
		-- date.range( x, y )							-- Returns a range of dates as a table.

		-- Time functions are relative to unix time like date, but
		-- an argument changes it.
		-- time.seconds()									-- Returns 1
		-- time.hour()										-- Returns 1
		-- time.now()										-- Returns unix time
		-- time.milliseconds()							-- Returns 111
		-- time.epoch()									-- Should return 0.
		-- time.nanoseconds()							-- Returns 12312312321

		-- Something like
		-- date.gmt( time.now() + time.days(9) )
		-- would handle the Expires= string for a cookie.

		-- .after, .before, {
		-- 	sec = 9,
		-- 	min = 9,
		-- 	year = 9,
		-- 	day = 9,
		-- 	wday = 9,
		-- }
local function diff_secs(n)
	if type(n) == 'number'
	then
		return n * 86400
	else
		response.abort({500}, "Argument supplied to diff_secs() is not a number!")
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
			-- response.abort({200}, cookie_date( os.time() + diff_secs( t.expires ) ))	
			-- response.abort({200}, cookie_date( 86400 ))
			-- Notice this, when GMT is not tz, 3600 * 5 is epoch...
			-- response.abort({200}, cookie_date( 3600 * 5 ))
			--]]

			-- Get expires time.
			if t.expires and type(t.expires) == 'number'
			then	
			--		table.insert(cookie_t,"Expires=" .. cookie_date() ) 
				t.expires = cookie_date( os.time() + diff_secs( t.expires ) )
			end

			--[[
		  	response.abort( {200}, table.concat({
				t.expires .. " GMT"
			}))
			--]]

			-- Get or create maxage.
			if t.maxage and type(t.maxage) == 'number'
			then 
				t.maxage = cookie_date( os.time() + diff_secs( t.maxage ) )
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
				"Expires=" .. cookie_date(), 
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
		--[[
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
			"Expires=" .. cookie_date( 0 )
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
