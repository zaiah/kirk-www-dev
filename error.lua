------------------------------------------------------
-- error.lua 
--
-- Some better error handling.
--
-- All errors need to track down:
-- 1. exactly where something fell apart.
-- 2. what exactly caused it to fall apart.
-- 3. Illustrate which parameter caused the failure. 
------------------------------------------------------


return {
------------------------------------------------------
-- when_type_not(t, ttc)
--
-- Perform a typecheck and exit if not. 
--
-- If [t] is not of type [ttc], die with an 
-- appropriate server response.
------------------------------------------------------
	when_type_not = function (t, ttc)
		------------------------------------------------------
		-- die
		--
		-- Dies on encounter of incorrect type.
		-- The status code here will always be a 500.
		-- The message greatly depends on what happened and 
		-- what module we're in.
		------------------------------------------------------
		local function die()
			response.abort({500}, "Bad argument.")
		end

		-- Check for an argument.
		if not t then die() end

		-- Check for a type to check.	
		if not ttc 
		then 
			die()

		-- Handle one type to check.
		elseif type(ttc) == 'string'
		then
			if type(t) ~= ttc then die() end 

		-- Handle multiple types to check.
		elseif type(ttc) == 'table' 
		 and is.ni(ttc)
		then
			-- This should be moduled out.  
			-- die_on_true_occurence() or something...
			-- die_on_first_occurence() or something is the reverse... 
			-- both are needed.
			local status = false 
			for __,type_to_check in ipairs(ttc) 
			do
				if type(t) == type_to_check then status = true end 
			end	
			if not status then die() end

		-- Handle an incorrect second argument.	
		else
			die()
		end
	end,

   ------------------------------------------------------
   -- .with(n,m) 
   --
   -- Die with a predefined status code [n] and a message
	-- [m]. If [m] is not specified, then kirk will 
	-- choose the default status message and any formatting
	-- that's been specified.
	--
	-- *nil
   ------------------------------------------------------
	with = function(n, m)
		if not m
		then
			-- Include all the status codes.
			-- Choose a status code message without any special codes.
			-- If pg.error is set up, you can pick your own stuff.
		end
		response.abort({n}, tostring(m or "Server error."))
	end,
}
