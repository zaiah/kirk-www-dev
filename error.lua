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



------------------------------------------------------
-- local die(t)
--
-- A function to wrap a bunch of filler information 
-- into a 500 Internal Server Error page.
--
-- t can be either a table or string. If it's a table
-- it accepts the following parameters:
-- t {
-- 	msg = [string]    		-- A message that can include
--                      		-- any of the following when
--                      		-- crafting an error message:
--                      		-- ["%f", "%t", "%o", "%a" ]
--    __function = [string]   -- Define a function name for the error.
--    __and      = [table]    -- Define multiple items.
--    __or       = [table]    -- One or both of these have caused error.
--    __type     = [string]   -- Must be of a Lua type.
-- }
--
-- *nil
------------------------------------------------------
local function die(t)
	------------------------------------------------------
	-- local die_default(m)
	--
	-- Send a default death error with all wrappings done.
	-- m is an optional string.
	--
	-- *nil
	------------------------------------------------------
	local function die_default(m)
		-- Wrapping common responses can be done here.

		-- Send the death error.
		response.abort({500}, render.file({{
		  msg 			= m,
		  status 		= scodes[500],
		  code 			= 500,
		  stacktrace 	= debug.traceback(),	
		}}, "error"))
	end

	-- Check t if there is one.
	local t = table.retrieve({ 
		"msg", 
		"__function", 
		"__type",
		"__and",
		"__or",
	},t)

	-- Create some local spaces.
	local m

	-- If t.msg exists, then search to see if a 
	-- replacement is needed.
	if t and t.msg 
	then
		-- Catch any function names.
		if t.__function and string.find( t.msg, "%f", 0, true )
		then
			-- Using tags with the function name could be SUPER cool...
			t.msg = string.gsub( t.msg, '%%f', 
			'<b>function</b> <a class=on500 href="/"><i>' .. t.__function .. '()</i></a>' ) 
		-- Die becauase function name is needed.
		else
			die_default("No function name(s) supplied within module die.")
		end

		-- Catch type names.
		if t.__type and string.find( t.msg, "%t", 0, true )
		then
			-- Using tags with the function name could be SUPER cool...
			t.msg = string.gsub( t.msg, '%%t', 
				'<b>type</b> <i>'..t.__type..'</i>' ) 
			
		else
			die_default("No type name(s) supplied within module die.")
		end

		-- More complicated items with and & or.
--[[
		if t["__or"] and string.find( t.msg, "%o", 0, true )
		then
		else
			die_default("No <i>or</i> values supplied within module die.")
		end

		if t["__and"] and string.find( t.msg, "%a", 0, true )
		then
		else
			die_default("No <i>and</i> values supplied within module die.")
		end
--]]

		-- Finally set message. 
		m = t.msg
	end

	-- Send completed death message. 
	response.abort({500}, render.file({{
		msg 			= m or "A server error has occurred.",
		status 		= scodes[500],
		code 			= 500,
		stacktrace 	= debug.traceback(),	
	}}, "error"))
end



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

		-- This is adding some details for 500 errors.
		-- Over the next few weeks/days I'll be getting 
		-- rid of these. 
		if type(m) == 'table' and not is.ni(m)
		then
			-- Pull the proper responses out.
			m = table.retrieve({ "msg", "status", "stacktrace" }, m)

			-- Fill up any blank fields.
			-- 
			-- There is a serious mishap in render.() right now because
			-- it only works with tables 2 levels deep.  This will change
			-- in the future, but for now, it looks like this.
			local errt = {{
				msg = m.msg or "", 
			 	status = m.status or scodes[n],
				code = n,
				stacktrace = m.stacktrace or "",
			}}
			

			-- Return the final status code.
			response.abort({n}, render.file( errt, "error" ))
		else
			response.abort({n}, tostring(m or "Server error."))
		end
	end,

   ------------------------------------------------------
	-- .xerror(s)
	--
	-- Die in a certain error function.
	--
	-- The traceback is done here, and function that has
	-- this error built into it will be what shows.
	--
	-- *nil
   ------------------------------------------------------
	xerror = function (s)
		if type(s) ~= "string"
		then
			die({
				funct = "die.xerror()",
				msg = "%f requires a string as its first argument."
			}) 
				
		else	
			response.abort({500}, render.file({
				msg = "",	
				status = "",
				code = "",
				stacktrace = "",	
			}, "error"))
		end
	end,

   ------------------------------------------------------
	-- .xtype(e, vtype)
	--
	-- Die when type of e is not the same as any element
	-- in vtype.
	--
	-- *nil
   ------------------------------------------------------
	xtype = function (e, vtype)
		local fname = "die.xtype"
		if not e and not vtype
		then
			die({
				__function = fname,
				msg = "No arguments received at %f." 
			}) 

		elseif not vtype
		then
			die({
				__function = fname,
				msg = "No secondary argument received at %f." 
			}) 
---[[
		elseif type(vtype) == 'table'
		then
			local is_type = false
			if not is.ni(vtype)
			then
				die({
					__function = fname,
					__or		  = { "t:string", "t:table:n" },
					msg = "Secondary argument to %f must be of %o"
					-- msg = "Secondary argument to %f must be of type string or a numerically indexed table."
				})
			else
				-- Go through each.
				for __,element in ipairs(vtype)
				do
					if type(e) == element
					then
						is_type = true	
						break
					end
				end 	

				-- Die if is_type is still false.
				if not is_type
				then
				die({
					__function 	= "die.xerror()",
					__type 		= vtype,
					msg = "First argument to %f is not of %t." 
				}) 
				end
			end
--]]

		elseif tostring(type(e)) ~= tostring(vtype)
		then
			-- You'll have to glean the function name from the 
			-- stack traceback here to be useful.  Otherwise,
			-- a programmer would have to type the name of 
			-- every function he/she wished to write an error 
			-- for.	
			die({
				__function 	= fname,
				__type 		= vtype,
				msg 			= "First argument to %f is not of %t." 
			}) 
		end
	end,
}
