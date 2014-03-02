------------------------------------------------------
-- shuffler.lua 
--
-- A key sorting function for tables with multiple
-- keys mapped to differing types.  Handles typechecking
-- and validation of parameters received in a less
-- verbose fashion. 
--
-- Expects four parameters:
-- ns = A "validation" table containing the keys:
-- 	datatypes = string or table -- datatypes that each subsequent level
-- 										-- of a table should contain
--		_[type]   = function			-- Where [type] is any of the following: 
--		                           -- string, function, number, userdata
--		                           -- boolean, nil,
--		                           -- atable = alpha table, 
--		                           -- ntable = nindex table
-- 
-- pp = a table with values you want to sort
-- name = the index of the table containing the key to pp
-- fname = the name of whatever function you want to show up
-- 	for propagating errors.
--
-- *nil
------------------------------------------------------
return function (ns,pp,name,fname)
	local c = 1
	local fname = fname

	-- Got to catch all this stuff.
	for __,xterms in ipairs({ns,pp,name,fname})
	do
		die.xnil(xterms)
	end

	-- First, make sure that you know what you should be looking for.
	-- If it's a table, then we need to iterate over it.  And furthermore
	-- we need to know what type.
	local function filter_types(type_value)
		local prop_types = {}	-- A table for our datatypes.  Return it.
		local actual 				-- The type of the var in question.
		local all_datatypes = { -- The Lua datatypes + two - one.
			"string", 
			"function", 
		--	"table", 
			"number", 
			"userdata", 
			"boolean", 
			"nil",
			"atable",
			"ntable"
		}

		-- I have multiple types here.
		if type(type_value) == 'table'
		then
			-- Cannot handle alphanumerics.
			if not is.ni(type_value) 
			then
				die.xerror({ 
					fn = fname, 
					msg = "Expected %t at datatypes." })
			-- Move through each value and make sure that it is a valid type.
			else
				for __,kk in ipairs(type_value) 
				do
--			die.quick(kk)
					if is.value(kk, all_datatypes)
					then
						table.insert(prop_types, kk)
					else
						die.xerror({fn = "filter_types", tn = type(kk), 
					 msg = "Received %t at %f. Expected <b>type</b> <i>string</i>."})
					end
				end
			end
		-- I have only one type here.
		elseif type(type_value) == 'string'
		then
			if is.value(type_value, all_datatypes) 
			then
				table.insert(prop_types, type_value)
			end
		end

		-- Is this going to be released when this function is done?
		-- die.quick(table.dump(prop_types))
		return prop_types
	end

	-- Check for a status of false. (or make one if no return)
	-- Kill this loop also if c has gotten too large.
	return_exec = true
	while return_exec -- or ns[name]["datatypes"][c]
	do
		-- get_actual
		--
		-- Returns the proper type of some element, differentiating between
		-- alpha and numeric tables.
		actual = (function (tt)
			if type(tt) == 'table'
			then
				if is.ni(tt) then 
					return "ntable" 
				else 
					return "atable" 
				end
			else
				return type(tt)
			end
		end)(pp)

		local filtered = filter_types(ns[name]["datatypes"])

		-- If the type matches any of the possible, then move to processing
		-- it by type with the functions defined in ns.
		if is.value(actual, filtered)
		then
			-- Set up the name of our function by concatenating type and
			-- an underscore, differentiating between alphas and numerics.
			local lfname = "_" .. actual 

			-- Run the function, but check if it's actually bound to a handler.
			local tt = table.keys(ns[name])
			table.remove(tt, table.index(tt, "datatypes"))
			if is.value(lfname, tt)
			then
				-- Got to be careful here, b/c this is how we tell this to end.
				return_exec = ns[name][lfname](pp)
			else
				die.xerror({
					fn = fname,
					an = tt,
					msg = "No function bound to <b>namespace</b> "..lfname..
					 " at %f.  This parameter should have functions bound to %a."
				})
			end
		-- If we reach this, the developer supplied an incorrect type.
		else
			die.xerror({ fn = fname, tn = type(pp),
				msg = "Incorrect %t supplied at index ["..name.."] in %f." })	
		end

		-- Increment our cheap counter.
		c = c + 1
	end	
end
