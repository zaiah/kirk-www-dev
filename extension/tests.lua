------------------------------------------------------
-- _tests.lua 
--
-- Comprises the "is" part of the interface. 
------------------------------------------------------

------------------------------------------------------
-- handle_table( t, tval ) 
--
-- Handle different types of tables when dealing
-- with table values.
--
-- *nil 
------------------------------------------------------
local function handle_table(t,tval)
	-- Handle simple errors. 
	if t and is.ni(t) --t[table.maxn(t)]
	then
	 response.abort({500}, 
		"Table supplied to are.all_keys(n,t) not in correct format.")
	elseif tval and not is.ni(tval)
	then
	 response.abort({500}, 
		"Table to search supplied to are.all_keys(n,t) ".. 
		"is not in the correct format.")
	end
end


local is = {
	------------------------------------------------------
	-- .oftype(c,ttype) 
	--
	-- Check for type of c. 
	-- If ttype is supplied, oftype() will check if c is
	-- ttype.  Otherwise, will return the type of c.
	------------------------------------------------------
	["oftype"] = function (c,ttype)
		local status = false
		if not c and not ttype
		then
			return nil
		else
			local status = false
			local dtypes = {
				["f"] = 'function',
				["n"] = 'number',
				["s"] = 'string',
				["t"] = 'table',
				["u"] = 'userdata'
			}
			if type(c) == dtypes[ttype]
			then
				status = true
			end
		end
		return status
	end,

	------------------------------------------------------
	-- .set(text,key) 
	--
	-- If text is a value, then set it and return a string
	-- with it set.
	-- [id] is optional key to set text to.
	--
	-- Should return a status as well.
	-- *string or *nil
	------------------------------------------------------
	["set"] = function (text,key)
		local rt = ""
		if text
		 and text ~= ''
		 and key
		 and key ~= ''
		 then
			rt = string.format("%s=%s",key,text)
		elseif text
		 and text ~= ''
		 then
			rt = text
		else
			rt = nil 
		end
		return rt
	end,

	------------------------------------------------------
	-- .all(t,bool[true,false]) 
	--
	-- Return true if all elements in t are set.
	--
	-- Everything in trueness will be true if all
	-- things are set to bool.
	-- *bool 
	--
	-- This is not quite right....
	-- We're not really checking that all elements are
	-- true or false all the time, but rather that all
	-- elements are something other than false or nil.
	------------------------------------------------------
	["all"] = function(t,bool)
		local status = false

		-- If all elements have an entry in or exist in the table.	
		-- Check trueness and stuff.	
		if t 
--		 and bool == true or bool == false 
		 then
			local c,trueness = 1,{}
			if t[table.maxn(t)]
			then
				for _,value in ipairs(t)
				do
					print(type(value))
					if type(value) ~= false 
					 and type(value) ~= nil 
					 then
						trueness[c] = true
					 else
						trueness[c] = false 
					end
					c = c + 1
				end
			else
				for _,value in ipairs(t)
				do
					if type(value) ~= false 
					 and type(value) ~= nil 
					 then
						trueness[c] = true
						c = c + 1
					end
				end
			end
		
			-- If anything in trueness is equal to false then
			-- there is no index for that one anyway.
			-- so....checking the size of t vs. trueness will
			-- tell us whether or not we were successful.
			--
			-- But this only works with numeric tables.
			for _,value in ipairs(trueness)
			do
				if value == false
				then
					return nil
				end
			end 
		end
		return status
	end,
	
	------------------------------------------------------
	-- .any(t,bool[true,false]) 
	--
	-- Return true if any elements in t are set.
	-- *bool 
	------------------------------------------------------
	["any"] = function(t,bool)
		local status = false
		if t 
		 and bool == true or bool == false 
		 then
			if t[table.maxn(t)]
			then
				for _,value in ipairs(t)
				do
					if type(value) == bool
					 then
						status = true 
					end
				end
			else
				for _,value in pairs(t)
				do
					if type(value) == bool 
					 then
						status = true 
					end
				end
			end
		end
		return status
	end,


	------------------------------------------------------
	-- .ni(t) 
	--
	-- Check if t is numerically indexed.
	-- *bool 
	------------------------------------------------------
	["ni"] = function (t)
		local status = false
		if t and t[table.maxn(t)]
		then
			status = true
		end
		return status 
	end,

	------------------------------------------------------
	-- .key(tval,t) 
	--
	-- Check if tval is a key in t.
	-- *bool 
	------------------------------------------------------
	["key"] = function (tval,t)
		local status = false
		if not t or is.ni(t) --t[table.maxn(t)]
		then
			die.xerror({
				fn = "is.key",
				msg = "Received numerically indexed table at %f. " .. 
				"Expected alphabetically indexed table."
			})
		end
	
		for key,_ in pairs(t) do
			if tval == key 
			then
				status = true
				return status
			end
		end
	end,

	------------------------------------------------------
	-- .value(tval,t,getIndex) 
	--
	-- Check if tval is a value in t.
	--
	-- If getIndex is true, then return
	-- the index.
	-- *bool 
	------------------------------------------------------
	["value"] = function (tval,t,getIndex)
		local status = false
		local index
		if t
		then 
			if t[table.maxn(t)]
			then
				for ind,value in ipairs(t) do
					if tval == value 
					then
						status = true
						index  = ind
					end
				end
			else	
				for ind,value in pairs(t) do
					if tval == value then
						status = true
						index  = ind
					end
				end
			end
		end

		-- ?
		if getIndex then
			return { ["status"] = status, ["index"] = index }
		else
			return status
		end
end,
}

------------------------------------------------------
-- are {}
--
-- Plural tests.
------------------------------------------------------
local are = {
	------------------------------------------------------
	-- .members_are_of_type(t,ty)
	--
	-- Check if members in t are of type [ty] where
	-- [ty] can be either a table or proper string.
	-- Return [false] either at the first value in [t] that 
	-- does not match [ty] if [ty] is a string or the value
	-- in [t] that doesn't match any values in [ty] provided
	-- [ty] is a table.
	-- 
	-- *bool
	------------------------------------------------------
	["members_of_type"] = function (t,ty)
		------------------------------------------------------
		-- Can't think of a way not to evaluate the request
		-- block twice.
		------------------------------------------------------
		local is_deep, request_ind = {}, {}

		------------------------------------------------------
		-- Only work on alpha tables.
		------------------------------------------------------
		if not is.ni(t)
		 and type(ty) == 'string'
		then
			for r,q in pairs(t)
			do
				table.insert(request_ind,r)
				if type(q) == ty
				then
					table.insert(is_deep,r)
				end
			end

			------------------------------------------------------
			-- Check for evenness.
			------------------------------------------------------
			if table.maxn(request_ind) == table.maxn(is_deep)
			then
				return true
			else
				return false
			end

		------------------------------------------------------
		-- Numerically indexed tables.
		------------------------------------------------------
		elseif is.ni(t)
		then
			-- Check if each value is of any of the proper types.
			type_correct = true 
			if type(ty) == 'table'
			then
				for _,val in ipairs(t) do
					for _,test_type in ipairs(ty) do
						if type(val) ~= test_type then
							type_correct = false 
						end
					end
				end

			-- Check if each value is only of the one type.
			elseif type(ty) == 'string'
			then
				for _,val in ipairs(t) do
					if type(val) ~= ty then
						type_correct = false 
					end
				end

			-- t isn't a table so don't bother.
			else
				LOG.file(t .. " is not a table in function are.members_of_type().")
			end
			return type_correct
		end
	end,

	------------------------------------------------------
	-- .all_existent_keys( tval, t ) 
	--
	-- Test if each key in tval exists in t.  Returns
	-- false if just one value does not exist.
	--
	-- *bool 
	------------------------------------------------------
	all_existent_keys = function (tval,t)
		local status = true

		-- Handle simple errors. 
		handle_table(t, tval)

		-- Iterate through tval's values.
		for __,my_val in ipairs(tval)
		do
			if not t[my_val]
			then
				return false 
			end
		end

		return status 
	end,


	------------------------------------------------------
	-- .any_existent_keys( tval, t )
	--
	-- Test if any keys in [tval] exist in [t].  Returns
	-- true if any one value exists.
	--
	-- *bool 
	------------------------------------------------------
	any_existent_keys = function (tval,t)
		local status = false 
		handle_table(t, tval)

		-- Iterate through tval's values.
		for __,my_val in ipairs(tval)
		do
			if t[my_val]
			then
				return true -- Stop because not all are true.
			end
		end

		return status 
	end,


	------------------------------------------------------
	-- any_blank_keys(tval, t) 
	--
	-- Test if any keys in [tval] correspond to an actual
	-- value in [t].  The value can be of any type, except 
	-- an empty string.  Returns false if one is 
	-- encountered.
	--
	-- *bool
	------------------------------------------------------
	any_blank_keys = function (tval, t)
		local status = false 
		handle_table(t, tval)

		-- Iterate through tval's values.
		for __,my_val in ipairs(tval)
		do
			if t[my_val] 
			and t[my_val] ~= "" 
			then
				return true
			end
		end

		return status 
	end
}

return {
	["is"] = is,
	["are"] = are,
}
