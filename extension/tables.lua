------------------------------------------------------
-- tables.lua
--
-- Extends table functionality. 
------------------------------------------------------
local t = {
	------------------------------------------------------
	-- .load(t)
	--
	-- Load a table that's not really a table.
	------------------------------------------------------
	["load"] = function (s)
		-- lua -e "tt = s"
		-- Return tables.
		if type(s) == 'table'
		then
			return t

		-- Convert a giant string to table.
		-- If it fails, not sure where to log that yet...
		elseif type(s) == 'string'
		then
			-- Find the table start.
			local res = string.find(s, '{', 1, true)
			if res and type(res) == 'number'
			then
				-- Create a table because all of the checks have passed.
				local tt = {}		-- Store our entire table here.
				local strt = {}	-- Store just strings here.

				-- Create a table for saving certain things?
				local save = {
					key = false,		-- Is Lua saving a table key?
					value = false,		-- How about a table value?
					table = false,		-- How about a table as a table value?
					start = false,		-- The start of a string
					finish = false,	-- The end of a string.
				}

				local caught = {
					rb = false,			-- Signals the start of a table key.
					lb = false,			-- Signals the end of a table key.
					eq = false,			-- Signals setting a table key to some value.
					rc = false,			-- Signals start of a table.
					lc = false,			-- Signals end of a table.
					qu = false,			-- Signals start (or end) of a string.
				}
	
				-- Move through each real character.
				local c
				for char = res, string.len(s)
				do
					-- Just do something with the one character.
					c = string.sub(s,char,char)
					print(char, c)
	
					-- Catch different string pieces.	
					if c == '['
					then
						caught.rb = true
					
					elseif c == ']'
					then
						caught.lb = true

					elseif c == '='
					then
						caught.eq = true

					elseif c == '{'
					then
						caught.rc = true

					elseif c == '}'
					then
						caught.lc = true

					-- Two "'s together between a [ ] is considered a syntax error.
					elseif c == '"' or c == "'"
					then

					end
				end
			end
		end
	end,

	------------------------------------------------------
	-- .dump(t)
	--
	-- Dump a table in text format.
	------------------------------------------------------
	["dump"] = function (t)
		if t and type(t) == 'table' 
		then
			-- Stupid table.
			local tt = {}

			-- Run over numerically indexed tables.
			if is.ni(t) then
				for _,v in ipairs(t) 
				do 
					table.insert(tt, tostring(v)) 
				end

			-- Run over alphabetically indexed tables.
			else  
				for k,v in pairs(t) 
				do 
					table.insert(tt, string.format('["%s"] = %s', k, tostring(v))) 
				end
			end

			-- End the table.
			return "{" .. table.concat(tt,", ") .. "}"
		end
	end,
 
	------------------------------------------------------
	-- .load(t)
	--
	-- Load a table that's not really a table.
	------------------------------------------------------
	["load"] = function (s)
		-- lua -e "tt = s"
		-- Return tables.
		if type(s) == 'table'
		then
			return t

		-- Convert a giant string to table.
		-- If it fails, not sure where to log that yet...
		elseif type(s) == 'string'
		then
			-- Find the table start.
			local res = string.find(s, '{', 1, true)
			if res and type(res) == 'number'
			then
				-- Create a table because all of the checks have passed.
				local tt = {}		-- Store our entire table here.
				local strt = {}	-- Store just strings here.

				-- Create a table for saving certain things?
				local save = {
					key = false,		-- Is Lua saving a table key?
					value = false,		-- How about a table value?
					table = false,		-- How about a table as a table value?
					start = false,		-- The start of a string
					finish = false,	-- The end of a string.
				}

				local caught = {
					rb = false,			-- Signals the start of a table key.
					lb = false,			-- Signals the end of a table key.
					eq = false,			-- Signals setting a table key to some value.
					rc = false,			-- Signals start of a table.
					lc = false,			-- Signals end of a table.
					qu = false,			-- Signals start (or end) of a string.
				}
	
				-- Move through each real character.
				local c
				for char = res, string.len(s)
				do
					-- Just do something with the one character.
					c = string.sub(s,char,char)
					print(char, c)
	
					-- Catch different string pieces.	
					if c == '['
					then
						caught.rb = true
					
					elseif c == ']'
					then
						caught.lb = true

					elseif c == '='
					then
						caught.eq = true

					elseif c == '{'
					then
						caught.rc = true

					elseif c == '}'
					then
						caught.lc = true

					-- Two "'s together between a [ ] is considered a syntax error.
					elseif c == '"' or c == "'"
					then

					end
				end
			end
		end
	end,

	------------------------------------------------------
	-- .dump(t)
	--
	-- Dump a table in text format.
	------------------------------------------------------
	["dump"] = function (t)
		if t and type(t) == 'table' 
		then
			-- Stupid table.
			local tt = {}

			-- Run over numerically indexed tables.
			if is.ni(t) then
				for _,v in ipairs(t) 
				do 
					table.insert(tt, tostring(v)) 
				end

			-- Run over alphabetically indexed tables.
			else  
				for k,v in pairs(t) 
				do 
					table.insert(tt, string.format('["%s"] = %s', k, tostring(v))) 
				end
			end

			-- End the table.
			return "{" .. table.concat(tt,", ") .. "}"
		end
	end,
 
	------------------------------------------------------
	-- .encapsulate(t,indtype)
	--
	-- Add all elements to said table.
	-- If t is used, t.first,t.table and t.last must always 
	-- exist.
	--
	-- Proves useful for the following:
	-- 1. Generating forms, options, and other superflousity.
	-- 2. Generating XML, JSON and other output.
	-- *table
	------------------------------------------------------
	["encapsulate"] = function (t,indtype)
		local indtype = indtype or 'numeric'
		local tt = {}
		if indtype == 'alpha'
		then
		end

		tt[1] = t.first
		local c = 2
		for _,value in pairs(t.table)
		do 
			tt[c] = value 
			c = c + 1
		end
		tt[table.maxn(tt) + 1] = t.last
		return tt
	end,

	------------------------------------------------------
	-- .populate(f,t)
	--
	-- Populate a Lua table with some values according
	-- to function. t (for now) must be numerically 
	-- indexed.
	-- 
	-- If f is a table, then the second index must be a 
	-- number that will define how many results the function
	-- is supposed to take.
	-- *table
	------------------------------------------------------
	["populate"] = function (f,t)
		local tt = {}
		if type(f) == 'function'
		 and is.ni(t)
		then
			for _,n in ipairs(t)
			do
				table.insert(tt,f(n,n))
			end
			return tt
		end
	end,

	------------------------------------------------------
	-- .string(str,brk)
	--
	-- Create a table with str as the first index.
	--
	-- Useful for creating long strings as a table.
	-- Usually faster than appending a string to itself.
	--
	-- Specifying break will use either:
	-- a newline (\n)
	-- or html break (<br />)
	--
	-- *string, *table or *function
	------------------------------------------------------
	["string"] = function (str,brk)
		local t
		if type(str) == 'string' 
		 or not str
		then
			t = { str or "" }
		end

		return {
			["append"] = function (str2) t[table.maxn(t) + 1] = str2 end,
			["string"] = function () return table.concat(t,brk or "") end,
			["table"] = function () return t end
		}
	end,

	------------------------------------------------------
	-- .append(st,kt,d)
	--
	-- Append named values in [kt] from source table [st] 
	-- to a new table.  If the element is nil, it is not
	-- added.
	--
	-- *table
	------------------------------------------------------
	["append"] = function (st,kt,d)	
		local tt = {}
		local delim = d or '='
		if st and kt and is.ni(st)
		then
			for _,n in ipairs(st) do
				if kt[n] then table.insert(tt,kt[n]) end end
		end
		return tt
	end,

	------------------------------------------------------
	-- .append_with_delim(st,kt,d,use_quotes)
	--
	-- Append named values in [kt] from source table [st] 
	-- to a new table.  If the element is nil, it is not
	-- added.
	--
	-- *table
	------------------------------------------------------
	["append_with_delim"] = function (st,kt,d,use_quotes)	
		local tt = {}
		local delim = d or '='

		-- Do you want to quote or not?
		local asgnmt
		if use_quotes then asgnmt = '"%s"' 
		else asgnmt = '%s' end
	
		if st and kt and is.ni(st)
		then
			for _,n in ipairs(st) do
				-- Some C function to check types would be nice.
				--
				-- Should I check the types,
				-- Should I coerce the values myself?
				if kt[n] 
				then 
					table.insert(tt, 
						string.format("%s%s" .. asgnmt, n, delim, kt[n]))
				end 
			end
		end
		return tt
	end,		-- All these need to move to the string lib.

	------------------------------------------------------
	-- .append_with_names(st,kt)
	--
	-- Append indices from [st] that are presnet in [kt] 
	-- into a new table.  The value referenced by the key
	-- in [st] will be appended to the value in kt.
	--
	-- If the element is nil, it is not added.
	--
	-- *table
	------------------------------------------------------
	["append_with_names"] = function (st,nt,kt)	
		local tt = {}
		if st and kt 
		 and is.ni(st) and is.ni(nt)
		then
			-- This doesn't handle nils, so wtf?
			for i,v in pairs(st) do
				if kt[v] then table.insert(tt,nt[i] .. kt[v]) end end
		end
		return tt
	end,

	------------------------------------------------------
 	-- .union(t1,t2)
	-- 
	-- Combine tables t1 and t2.  Do more research
	-- on unions.
	--
 	-- Note:
	-- A more complex union will be coming soon.
	------------------------------------------------------
	union = function (t1,t2)
		if is.ni(t1) and is.ni(t2)
		then
			for __,val in ipairs(t2) do
				table.insert(t1,val)
			end
		else
			response.abort({500},
				"Arguments supplied to table.union( t1, t2 ) are" ..
				" not of the proper type."
			)
		end
		
		-- Not accounting for nils, are yah...?
		-- Disable conflicts.
		return t1
	end,


	------------------------------------------------------
	-- .assimilate(t1,t2) 
	--
	-- Add table t1 to table t2. 
	-- Both must be of the same type.
	-- *table
	------------------------------------------------------
	["assimilate"] = function (t1,t2)
		if t1
		 and t2
		then
			if is.ni(t1)
			 and is.ni(t2)
			 then
				for x,n in ipairs(t1)
				do
					t2[x] = n
				end
			else
				for x,n in pairs(t1)
				do
					t2[x] = n
				end
			end
		end
		return t2
	end,


	------------------------------------------------------
	-- .reindex(t,order)
	--
	-- Reindex t according to the sorting order.
	-- Very experimental and still not working entirely
	-- to spec.
	--
	-- *table
	------------------------------------------------------
	["reindex"] = function (t,order)
		if t 
		 and type(t) == 'table'
		 and type(order) == 'table'
		then
			local tt = {}
			for k,val in ipairs(order)
			do
				-- You have arrange both by number and text?
				tt[k] = t[val]	
			end
			return tt
		end	
	end,
 
	------------------------------------------------------ 
	-- .keys(t)
	--
	-- Return a table of just keys from t.
	-- *table
	------------------------------------------------------
	["keys"] = function (t)
		if t and not is.ni(t)
		then
			local tt = {}
			for k,_ in pairs(t) do table.insert(tt,k) end
			return tt
		end
	end,

	------------------------------------------------------ 
	-- .values(t)
	--
	-- Return a table of just values from t.
	-- *table
	------------------------------------------------------
	["values"] = function (t)
		-- Handle alphanumeric tables only
		-- Probably should log when they're not alphanumeric.
		if t and not is.ni(t)
		then
			local tt = {}
			for _,v in pairs(t) do table.insert(tt,v) end
			return tt
		end
	end,
	
	------------------------------------------------------
	-- .retrieve (kt,t)
	--
	-- Retrieve all non-blank key references from [t] and
	-- return a table with these non-blank keys. 
	--
	-- *table
	------------------------------------------------------
	["retrieve"] = function (t,mt)
		if t and is.ni(t)
		then
			local tt = {}
			for _,val in ipairs(t)
			do
				if is.key(val,mt)
				then
					tt[val] = mt[val] 
				end	
			end
			return tt
		end
	end,


	------------------------------------------------------
	-- .retrieve_non_matching(t,mt) 
	--
	-- Get keys from that don't match. 
	------------------------------------------------------
	["retrieve_non_matching"] = function (t,mt)
		if t and is.ni(t)
		then
			local tt = {}
			for key,val in pairs(mt)
			do
				if not is.value(key,t)
				then
					tt[key] = val 
				end	
			end
			return tt
		end
	end,


	------------------------------------------------------
	-- .as_string (t)
	--
	-- Output t as a string for easy testing.
	--
	-- *string
	------------------------------------------------------
	["as_string"] = function (t)
		if t and type(t) == 'table' 
		then
			local tt = {}
			if is.ni(t) then
				for _,v in ipairs(t) do table.insert(tt,tostring(v)) end
			else  
				for k,v in pairs(t) do 
					table.insert(tt,string.format('["%s"] = %s',k,tostring(v))) end
			end
			return table.concat(tt,",\n")
		end
	end,


	------------------------------------------------------
	-- .tonumeric(t,saveKeys[true,false])
	--
	-- Change an alphabetically indexed table (t) to 
	-- numeric using either the key or the value. 
	-- *table
	------------------------------------------------------
	["tonumeric"] = function (t,saveKeys)
		local tbl = {}
		if is.ni(t)
		then
			tbl = nil
		else
			if not saveKeys then
				for _,n in pairs(t) do
					table.insert(tbl,n)
				end
			else
				for n,_ in pairs(t) do
					table.insert(tbl,n)
				end
			end
		end
		return tbl
	end,

	------------------------------------------------------
	-- .compare(t1,t2) 
	--
	-- See if all the elements in t1 exist in t2. 
	-- (Useful with POSTs and GETs.)
	-- *bool
	------------------------------------------------------
	["compare"] = function (t1,t2)
		local trueness,status = {},true
		for index,value in ipairs(t1)
		do
			if t2[value]
			 and t2[value] ~= ''
			 and type(t2[value]) ~= nil
			 and type(t2[value]) ~= false 
			then
				trueness[index] = true
			 else
				trueness[index] = false
			end
		end 

		for index,value in ipairs(trueness)
		do
			if trueness[index] == false
			then
				status = false
			end
		end
		
		return status
	end,

	------------------------------------------------------
	-- .sortnsave(t)  / define some aliases...
	--
	-- Sorts a table (t) and saves it to a new table.
	-- *table 
	------------------------------------------------------
	["sort_and_save"] = function (t,doKeys) 
		local final = {}
		if is.ni(t)
		then
			for _,value in ipairs(t) do
				if type(value) == 'table' then return end
				table.insert(final,value)
			end
		else
			local c = 1
			if not doKeys
			then
				for _,value in pairs(t) do
					if type(value) == 'table' 
				    or type(value) == 'function' 
					 then 
						final[c] = nil 
					else
						final[c] = value
						c = c + 1
					end
				end
			else
				for key,_ in pairs(t) do
					final[c] = key 
					c = c + 1
				end
			end
		end
		table.sort(final)
		return final
	end,


	------------------------------------------------------
	-- .return_to_key(t,kt)
	--
	-- Return a table to a particular level of recursion
	-- defined by kt.
	--
	-- *table { value, index }
	------------------------------------------------------
	["return_to_key"] = function (t,kt)
		local tt = {}			-- Store our references here
		local index, value	-- Keep track of what was found.

		if type(t) == 'table' 
		 and type(kt) == 'table'
		then 
			------------------------------------------------------
			-- Move through everything, stop at the index and 
			-- return it. 
			------------------------------------------------------
			for k,v in ipairs(kt)
			do	
				------------------------------------------------------
				-- Evaluate the first index or any subsequent indices
				-- found in our table.
				------------------------------------------------------
				local tested_key = tt[k - 1] or t

				------------------------------------------------------
				-- Save the result at index v if we've found anything.
				------------------------------------------------------
				if tested_key[v] 
				then
					tt[k] = tested_key[v]
					index = v
					value = tt[k]

					------------------------------------------------------
					-- If we've reached the end, return everything.
					------------------------------------------------------
					if k == table.maxn(kt)
					then
						return value
					end

				------------------------------------------------------
				--	If we found either the first index or subsequent 
				--	indices but failed to reach the end of our
				--	list [kt], stop and return the value at the last 
				--	found index.
				------------------------------------------------------
				elseif next(tt)
				then
					return tt[k - 1]
					

				------------------------------------------------------
				--	If we don't find the first index, just stop.
				------------------------------------------------------
				else	
					return nil
				end -- if tested_key[v]

			end -- for k,v in ipairs(t)
		end -- if type(v) == 'table' ... 

		------------------------------------------------------
		-- Evaluate for nil arguments.  ipairs will autobreak
		-- upon encountering a nil argument.
		------------------------------------------------------
		return value
	end,


	------------------------------------------------------
	-- .from(s,d)
	--
	-- Generate some table from a string [s], using [d] as
	-- delimiter. 
	--
	-- *table
	------------------------------------------------------
	["from"] = function (s,d)
		local err

		-- Chop our string.
		if s and d 
		 and type(s) == 'string' 
		 and type(d) == 'string'
		then
			local term, tc, pos = {}, 1, {0} 
			-- You'll have to do one thing for strings with one character.
			-- Find the first term before [d] 
			if string.len(d) == 1
			then
				while ( string.find(s, d, pos[tc]) )
				do
					-- Second index is always same when one char long 
					starti = ({ string.find(s, d, pos[tc] + 1) })[1]
					endi   = ({ string.find(s, d, pos[tc] + 1) })[2]
					 -- We've reached the end at this point.
					if not endi 
					then 
						term[tc] = string.match(s, string.format("[^%s]+",d), pos[tc])
						return term
					else
						-- term[tc] references the match.
						term[tc] = string.match(s, string.format("[^%s]+",d), pos[tc])
						tc  = tc + 1
						pos[tc] = endi
					end
				end

			-- ...and another for strings with multiple characters.
			else
				while ( string.find(s, d, pos[tc]) )
				do
				  -- Second index is always same when one char long 
				  starti = ({ string.find(s, d, pos[tc] + 1) })[1]
				  endi   = ({ string.find(s, d, pos[tc] + 1) })[2]

				  -- We've reached the end at this point.
				  if not endi 
				  then 
					  term[tc] = string.match(s, string.format("[^%s]+",d), pos[tc])
					  break 
				  else
					  -- term[tc] references the match.
					  term[tc] = string.match(s, string.format("[^%s]+",d), pos[tc])
					  tc  = tc + 1
					  pos[tc] = endi
				  end
				end
				term[tc] = string.match(s,string.format("[^%s]+",d), endi)
				return term
			end
		end
	end,

	------------------------------------------------------
	-- .index(t,e) 
	--
	-- Return the index of element e from t.
	-- *number or *string
	------------------------------------------------------
	["index"] = function (t,e)
		local tt = {}
	if type(t) == 'table'
	then
		if is.ni(t)
		then
			for k,v in ipairs(t)
			do
				tt[v] = k
			end
		else
			for k,v in pairs(t)
			do
				if type(v) == "string" or type(v) == 'number' 
				then
		  			tt[v] = k
				end
			end
		end
	end

		return tt[e]
	end,

	------------------------------------------------------
	-- .indices(t,e)
	--
	-- Return the indices of element e from t.
	-- *number 
	------------------------------------------------------
	["indices"] = function (t,e)
		local tt, it = {}, {}	-- tt = switched table, it = indexed table
		for k,v in ipairs(t)
		do
			tt[v] = k
			if tt[e] then table.insert(it,k) end
		end
		return it
	end,

	------------------------------------------------------
	-- .copy(t) 
	--
	-- Make a copy of t.
	-- *table 
	------------------------------------------------------
	["copy"] =  function (t)
		local tt = {}
		if is.ni(t)
		then
			for _,v in ipairs(t) do table.insert(tt, v) end
		else
			for k,v in pairs(t)
			do
				tt[k] = v 
			end
		end
		return tt
	end,

	------------------------------------------------------
	-- .fill_with_key(t,key) 
	--
	-- File the values that correspond with key from some 
	-- table. 
	--
	-- *table
	------------------------------------------------------
	fill_with_key = function (t,key)
		local tt = {}
		if is.ni(t) then
		for __,item in ipairs(t) do
			table.insert( tt, item[key] )
		end
		else
			response.abort({500},"First argument to table.fill_with_key(t,key): " .. tostring(t) .. " is not of the proper type.")
		end
		return tt
	end,
}

------------------------------------------------------
-- local
--
-- Add normal table functions. 
-- This should be cleaner...
------------------------------------------------------
for x,n in pairs(table)
do
	t[x] = n
end

return t
