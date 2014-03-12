------------------------------------------------------
-- FileName 
--
-- Loads a Lua file and parses for errors. 
------------------------------------------------------
local function wrap_exec(run)
	-- Try to run the index, and your skel files, etc. 
	status, result = xpcall( run, debug.traceback )

	-- If the function was executed correctly, bring back the payload.
	if status
	then
		return result

	-- If not, cut execution with a 500 error.
	else
		-- Chop traceback.
		local c = string.find( result, "\n" )
		local m = string.sub( result, 1, (c - 1)) 
		local s = string.sub( result, (c + 1), -1)
		s = string.gsub( s, "\t", "  " )
		s = string.gsub( s, "stack traceback:", "" )

		-- Stackdump
		die.with(500,{ msg = m, stacktrace = s }) 	
	end	
end	

return {
	file = function (file)
		-- Wrapper to return loadfile()
		function run()
			return loadfile( file )()
		end

		return wrap_exec(run)
	end,
	
	funct = function (funct)
		if type(funct) == 'function'
		then
			return wrap_exec(funct)
		else
			die.xerror({
				fn = "interpret.funct",
				tn = type(funct),
				msg = "Expected <b>type</b><i>function</i> at %f.  Received %t."
			})
		end
	end,
}

