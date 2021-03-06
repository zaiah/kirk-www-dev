------------------------------------------------------
-- die.lua 
--
-- Die on different error code responses. 
-- None of these functions will return anything but
-- a status code.
------------------------------------------------------

return {
  ------------------------------------------------------
  -- on_404 
  --
  -- Die if a resource was not found.
  -- *nil
  ------------------------------------------------------
	on_404 = function (m)
		response.abort({404}, table.concat({
			status[404], 
			tostring( m or "The requested resource was not found.")
		}))
		return false
	end,

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
	end
}
