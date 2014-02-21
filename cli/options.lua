------------------------------------------------------
-- options.lua
--
-- 
------------------------------------------------------
return function (vararg)
	------------------------------------------------------
	-- options {}
	-- 
	-- Define a table of options using the following
	-- syntax rules:
	--
	-- name =  { short = ?, args = ? }
	--           short =  , ( -1 is any number, 
	--							 	any other number parses that may arguments )
	--
	-- Option syntax.
	--
	--[[
	[ option name ]	
		.short 	= short flag 
		.long		= long flag
		.argc 	= argument count
		.argv 	= argument element(s) 
		.run     = [ true or false ] depending on if option thrown.
		.rules	= functions to run on each argument
	 [ .body ]	= can optionally code with the function you want in the table thrown
					  (if order matters, you don't want to use this)
	--]]
	------------------------------------------------------
	local args = {
		------------------------------------------------------
		-- backend
		--
		-- Choose a different backend. 
		------------------------------------------------------
		backend = { short = "b", argc = 1 },

		------------------------------------------------------
		-- suspend
		--
		-- Suspend certain libraries.
		------------------------------------------------------
		suspend = { short = "s", argc = -1 },

		------------------------------------------------------
		-- suspend-group { a, b, c, ... } or "[a, b, c, ... ]"
		-- 
		-- Suspend an entire group of libraries.
		------------------------------------------------------
		["suspend-group"] = { short = "x", argc = -1 },

		------------------------------------------------------
		-- dump-pg 
		-- 
		-- Dump everything in an instance's pg table.
		------------------------------------------------------
		["dump-pg"] = { short = "d", argc = 0 },

		------------------------------------------------------
		-- list-modules
		--
		-- List all the modules in a particular place.
		------------------------------------------------------
		["list-modules"] = { short = "l", argc = 0 },

		------------------------------------------------------
		-- post [t]
		--
		-- Submit table or string over POST. 
		-- If 
		------------------------------------------------------
		post = { short = "p", argc = -1 },

		------------------------------------------------------
		-- get [t]
		--
		-- Perform a GET request for [path]
		------------------------------------------------------
		get = { short = "g", argc = -1 },
	}

	------------------------------------------------------
	-- Probably need to check args to make sure .short 
	-- options don't repeat themselves.
	--
	-- Compile both short and long options.
	------------------------------------------------------
	local opts = {}
	for ok, ov in pairs(args)
	do
		opts[ok] = ov.short or "nil"
		-- print( ok .. " = " .. tostring(ov.short or "nil") )
	end

	------------------------------------------------------
	-- Parse each argument. 
	------------------------------------------------------
	-- Hold each argument "categorizer"
	local flag, ns

	-- Run the looper.
	for __blankarg__, cli_value in ipairs( vararg )
	do
		-- Is argv and argument or flag?
		local arg_flag

		-- Catch double-dash full option names.
		if is.value( string.sub(cli_value,3,-1), table.keys(opts) )
		then
			flag = string.sub(cli_value,3,-1)
			arg_flag = true

		-- Catch single-dash short option names.
		elseif is.value( string.sub(cli_value,2,3), table.values(opts) )
		then
			flag = table.index( opts, string.sub(cli_value,2,3))
			arg_flag = true

		-- Unix Format end of options.
		elseif string.sub(cli_value, 0,2) == "--" 
		 and string.sub( cli_value, 2, -1) == "" 
		then
			arg_flag = true

		-- Catch invalid arguments.	
		elseif string.sub(cli_value, 0,1) == "-" 
		 or string.sub( cli_value, 0, 2) == "--" 
		 and string.sub( cli_value, 2, -1) ~= "" 
		then
			print("Invalid argument received: " .. cli_value)
			os.exit()
		end

		-- What is the value of flag after every evaluation.
		-- print( "flag: " .. tostring(flag) )
		-- print( "argv: " .. tostring(cli_value) )

		-- Set the evaluation flag to true.
		ns = args[flag]
		ns.run = true 
	
		-- Set the options.  
		-- This can be within the else clause at the top of the loop.	
		-- If this is true, then start just adding to the argument chain.
		if not arg_flag
		then	
		if ns.argc == 0
		then
			-- print( "argc is 0" )	
		elseif ns.argc == 1
		then
			-- print("argc is exactly 1")
			ns.argv = cli_value
	
		elseif ns.argc > 1
		then
			-- print("argc is greater than 0")
			if not ns.argv then ns.argv = {} end
			if ns.argv and table.maxn(ns.argv) > ns.argc
			then
				print("Too many arguments supplied to option: --" .. flag) 
			end
			table.insert(ns.argv, cli_value)	

		elseif ns.argc == -1
		then
			-- print("argc can be of any length")
			if not ns.argv then ns.argv = {} end
			table.insert(ns.argv, cli_value)	
		end
		end
	end

	-- Unset flag
	flag = nil
	ns = nil

	------------------------------------------------------
	-- Add each o
	------------------------------------------------------
	return args
end
