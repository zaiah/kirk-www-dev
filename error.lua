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
-- Valid Lua datatypes.
------------------------------------------------------
local lua_datatypes = {	
	"function",
	"userdata",
	"nil",
	"string",
	"number",
	"table",
	"boolean"
}


------------------------------------------------------
-- local up_chain(n, discard)
--
-- Traverse up the traceback chain n times for a 
-- function name.
--
-- Depending on where up_chain is thrown here different
-- codes will be in the message.
--
-- discard will choose whether or not you want to 
-- drop the traceback stream.
--
-- *string
------------------------------------------------------
local function up_chain(n, discard)
	-- Get the traceback.
	local d = debug.traceback()


	-- First, find the n line from the top of the traceback.
--	local a = string.find( d, "\n", 0, true )
	j = {}
	for line in string.gmatch(d, "\n([%a%w%s%.%_%?%/%:%(%)%'%-]+)")
--	for line in string.gmatch(d, "\t[%a%w%s%p]+")
	do
		table.insert(j, "[bob_]" .. line .. "[_bob]")
	end	
	response.abort({200}, table.concat({
		_.pre( d ),
		table.concat(j,"<br />")
	}))

	-- Depending on line number, you'll also have to
	-- check whether this function is an interface
	-- function.  If it's an app, it will be hard
	-- to pin down exactly where the issue took place
	-- (and more importantly, find which "namespace"
	-- this function has failed under.)
	--
	-- For example, you call pony = add.app("x")
	-- and function pony.monkey() fails.
	-- Stack traceback will only tell you that a
	-- function monkey failed in a page called x.
	--
	-- How do you get it to tell you that monkey
	-- failed?
end


------------------------------------------------------
-- local eval_css()
--
-- Check if XHR is enabled, and send the proper
-- styling of errors back.
------------------------------------------------------
local function eval_css()
	if xhr.status then
		return ""
	else
		return table.concat({
			"\n\t\t<link rel=stylesheet href=/styles/default/zero.css>",
			"\n\t\t<link rel=stylesheet href=/styles/default/error.css>"
		})
	end
end

------------------------------------------------------
-- local die(t)
--
-- A function to wrap a bunch of filler information 
-- into a 500 Internal Server Error page.
--
-- t can be either a table or string. If it's a table
-- it accepts the following parameters:
-- t {
-- 	msg = [string] -- A message that can include
--                   -- any of the following when
--                   -- crafting an error message:
--                   -- ["%f", "%t", "%o", "%a" ]
--    fn = [string]  -- Define a function name for the error.
--    an = [table]   -- Define multiple items.
--    on = [table]   -- One or both of these have caused error.
--    tn = [string]  -- Must be of a Lua type.
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
		"altstatus", 
		"fn", 
		"tn",
		"an",
		"on",
	}, t)

	-- Create some local spaces.
	local m,s

	-- If t.msg exists, then search to see if a 
	-- replacement is needed.
	if t and t.msg 
	then
		-- Catch any function names.
		if t.fn and type(t.fn) == 'string' and string.find(t.msg, "%f", 0, true)
		then
			-- Using tags with the function name could be SUPER cool...
			t.msg = string.gsub( t.msg, '%%f', 
			'<b>function</b> <a class=on500 href="/"><i>' .. t.fn .. '()</i></a>') 
		-- Die becauase function name is needed.
		elseif t.fn then
			die_default("No function name(s) supplied within module die.")
		end

		-- Catch alternate messages.
		s = t.altstatus

		-- Catch type names.
		---[[
		if t.tn and string.find( t.msg, "%t", 0, true )
		then
			-- Using tags with the function name could be SUPER cool...
			t.msg = string.gsub( t.msg, '%%t', 
				'<b>type</b> <i>'..t.tn..'</i>' ) 
			
		elseif t.tn then
			die_default("No type name(s) supplied within module die.")
		end
		--]]

		-- Or's
		if t.on and string.find( t.msg, "%o", 0, true )
		then
			t.msg = string.gsub( t.msg, '%%o', table.concat(t.on, " or "))
				
		elseif t.on then
			die_default("No <i>or</i> values supplied within module die.")
		end

		-- and's
		if t.an and string.find( t.msg, "%a", 0, true )
		then
			t.msg = string.gsub( t.msg, '%%a', table.concat(t.an, " and "))

		elseif t.an then
			die_default("No <i>and</i> values supplied within module die.")
		end

		-- Finally set message. 
		m = t.msg
	end

	-- A CSS Stream for regular errors.

	-- Send completed death message. 
	response.abort({500}, render.file({{
		css 			= eval_css(), 
		msg 			= m or "A server error has occurred.",
		status 		= s or scodes[500],
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
				css = eval_css(), 
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
	-- .xempty(e)
	--
	-- Die if e is empty.  If e is a table, then xempty()
	-- will check if there are any values within the 
	-- table, or if it's just blank.   If e is a string,
	-- the xempty() will see if it's of length zero.
   ------------------------------------------------------
	xempty = function (e)
		local fname = "die.xempty"
		if e 
		then
			if type(e) == 'table' and not next(e)
			then
				die({
					fn = fname,
					msg = "Table supplied at %f has no keys or indices."
				})
			elseif type(e) == 'string' and e == "" 
			then
				die({
					fn = fname,
					msg = "String supplied at %f is empty."
				})
			end
		end
	end,

   ------------------------------------------------------
	-- .xnil(e)
	--
	-- Die if something is nil.
   ------------------------------------------------------
	xnil = function (e)
		local fname = "die.xnil"
		if type(e) == 'nil'
		then
			die({ fn = fname, msg = "Value supplied at %f is nil." })
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
	xtype = function (e, vtype, fname)
		-- local fname = up_chain(1,true)
		local fname = fname or "die.xtype"

		if not e and not vtype
		then
			die({
				fn = fname,
				msg = "No arguments received at %f." 
			}) 

		elseif not vtype
		then
			die({
				fn = fname,
				msg = "No secondary argument received at %f." 
			}) 

		elseif type(vtype) == 'table'
		then
			local is_type = false
			if not is.ni(vtype)
			then
				die({
					fn 	= fname,
					on	  	= { "type string", "numerically indexed table" },
					msg	= "Secondary argument to %f must be of %o."
				})
			else
				-- Go through each.
				for xn,element in ipairs(vtype)
				do
					-- Go through all the Lua types here.
					if not is.value(tostring(element), lua_datatypes) 
					then
						die({
							fn = fname,
							msg = "Value at index: " .. xn .. " within second " ..
							"argument received at %f is not a valid Lua datatype."
						})
					end

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
						fn 	= fname, 
						on 	= { unpack(vtype) },
						msg   = "First argument to %f is not a %o." 
					}) 
				end
			end

		elseif tostring(type(e)) ~= tostring(vtype)
		then
			-- You'll have to glean the function name from the 
			-- stack traceback here to be useful.  Otherwise,
			-- a programmer would have to type the name of 
			-- every function he/she wished to write an error 
			-- for.	
			die({
				fn 	= fname,
				tn 	= vtype,
				msg 	= "First argument to %f is not of %t." 
			}) 
		end
	end,

   ------------------------------------------------------
	-- .xerror(t)
	--
	-- Open our private die function because it's more
	-- useful sometimes.
	--
	-- *nil
   ------------------------------------------------------
	xerror = die,

   ------------------------------------------------------
	-- .quick(m)
	--
	-- Die with no excess, except a descriptive message.
	-- Used mostly for testing.
	--
	-- *nil
   ------------------------------------------------------
	quick = function (m)
		if type(m) == 'table' then m = table.dump(m, true) end
		die({
			altstatus = "Debugging Message",
			msg = m
		})
	end
}
