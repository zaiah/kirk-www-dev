----------------------------------------------- 
-- query.lua
--
-- An SQL ORM Layer 
--
-- // More
--
-- // Notes
-- This is the most awful piece of code in this
-- entire distribution.   Calls consistently
-- do not work because of the lack of information
-- received from the underlying driver.
----------------------------------------------- 

----------------------------------------------- 
-- priv {}
--
-- The private data table.
-- More will go here.
----------------------------------------------- 
local q = {}
local conntype = 'sqlite'
local priv = {
	["con"] 		= {},
	["table"] 	= "",
	["cur"] 		= {},
	["debug"] 	= false, 
	["control"] = false,
	["res"] 		= {},
	["query"] 	= '',
}


------------------------------------------------------
-- clean(term) local 
--
-- Sanitize SQL statements for basic gaming and syntax
-- errors.
------------------------------------------------------
local function clean(term)
	-- Where does the encoding library go?
	local bad, clean = { ';', '*', '='}, true 
	for _,terms in ipairs(bad)
	do 
		if string.find(term,terms)
		then	
			clean = false 
		end
	end
	return clean 
end


------------------------------------------------------
-- chop(t) local 
--
-- Chops strings.
-- *table 
------------------------------------------------------
local function chop(t)
	-- Define our delimiters.
	local delim = { 
		'=', 	-- Equal
		'~',  -- Similar
		'!'   -- Not
	}

	-- Chop our queries.
	local s,c,useful = {},1,function(te) return tostring(te[3]) end

	function f(x)
		if (tonumber(x)) 
		then
			x = tonumber(x)
		else
			x = string.format("'%s'",x)
		end	
		return x 
	end

	-- Save for later access.
	-- Check for LIKE as well.
	if type(t) == 'table'
	then
		for _,term in ipairs(t)
		do
			s[c] 	 = useful({ string.find(term,"(.*)=") })
			s[c+1] = f(useful({ string.find(term,"=(.*)") }))
			c 		 = c + 2
		end
	elseif type(t) == 'string'
	then
		s[c] 	 = useful({ string.find(t,"(.*)=") })
		s[c+1] = f(useful({ string.find(t,"=(.*)") }))
	end	
	return s
end


------------------------------------------------------
-- retrieve(cursor) local 
--
-- Retrieves all results of a query and gives them back. 
-- *table
------------------------------------------------------
local function retrieve(cursor)
	-- Take everything. Use pairs on the returned table.
	local set,c	= {},1

	if type(cursor) == 'userdata'
	then
		local dataReturn = {
			["all"] = function ()
				local res 	= cursor:fetch({}, "a") 
				while res
				do
					set[c] 		= {}
					for key,content in pairs(res)
					do
						set[c][key] = content	
					end	
					res = cursor:fetch({},"a")
					c = c + 1
				end
			end,

			["one"] = function ()
				set.limit	= cursor:fetch({},"a")
				set.result	= function ()
					local res 	= cursor:fetch({}, "a") 
					-- print(cursor)
					if res
					then	
						for x,y in pairs(res)
						do
							P(x,y)
						end
					end
				end
				set.advance = function()
					cursor:fetch({},"a")
				end
				
			end
		}

		if priv.control
		then
			dataReturn.one()
		else
			dataReturn.all()
		end
	end

	-- If we didn't find anything, return nothing.
	if table.maxn(set) == 0
	 or type(cursor) ~= "userdata"
	then
		return {nil} 
	else
		return set
	end	
end


------------------------------------------------------
-- ribbon {} 
--
-- The ribbon. 
------------------------------------------------------
local ribbon = {
	-- String Operators
	["="] = "=",
	["!"] = "NOT",
	["~"] = "LIKE",
--	["|"] = "OR",
--	["-"] = "BETWEEN",
}

-- Numeric Operators
local n_op = {
	">", "<", ">=", "<=", "<>", "!=" 
}

-- Union Operators.
local union_op = {
	"(", ")", "-"
}


------------------------------------------------------
-- local bydelim(x)
--
-- More string chopping for dynamic queries.
--
-- *string
------------------------------------------------------
local function bydelim(x)
	local clause
	for _,n in ipairs({"=","!","~"}) do
		if string.match(x,n)
		then
			if ribbon[n] ~= "LIKE"
			then
				local s = string.chop(x,n)
				clause = string.format(
					"%s %s '%s'",s.key, ribbon[n], s.value)
			else
				local s = string.chop(x,n)
				clause = string.format(
					"%s LIKE '*%s*'",s.key, s.value)
			end
		end
	end
	return clause
end


------------------------------------------------------
-- local byopr(x)
--
-- Numerical operators for dynamic queries.
--
-- *integer
------------------------------------------------------
local function byopr(x)
	local clause, num
	for _,n in ipairs(n_op) do
		num =	string.match(x,n)
		if num 
		then
			return ({
				[">"] = "%s > %d",
				["<"] = "%s > %d",
				[">="] = "%s > %d",
				["<="] = "%s > %d",
				["<>"] = "%s <> %d",
				["!="] = "%s != %d",	-- This depends on engine?
			})[num]()
		end
	end
	return clause
end


------------------------------------------------------
-- local tblquery(qstr, term) 
--
-- Create a query and clause dynamically. 
--
-- *string
------------------------------------------------------
local function tblquery(qstr, term, operator)
	----------------------------------------------- 
	-- Single item tables.
	----------------------------------------------- 
	local clause
	
	----------------------------------------------- 
	-- Single item tables.
	----------------------------------------------- 
	if table.maxn(term) == 1
	then
		for _,n in ipairs({"=","!","~"}) do
			if string.match(term[1],n)
			then
				if ribbon[n] ~= "LIKE"
				then
					local s = string.chop(term[1],n)
					clause = string.format(
						"%s %s %s '%s'", operator or "WHERE", 
						s.key, ribbon[n], s.value)
				else
					local s = string.chop(term[1],n)
					clause = string.format(
						"%s %s LIKE '*%s*'", operator or "WHERE", s.key, s.value)
				end
			end
		end
		return string.format(qstr .. clause, priv.table)

	----------------------------------------------- 
	-- Multiple items (usually the case)..
	----------------------------------------------- 
	else
		----------------------------------------------- 
		-- Set the first one...
		----------------------------------------------- 
		for _,n in ipairs({"=","!","~"}) do
			if string.match(term[1],n)
			then
				if ribbon[n] ~= "LIKE"
				then
					local s = string.chop(term[1],n)
					clause = string.format(
						"%s %s %s '%s'", operator or "WHERE", 
						s.key, ribbon[n], s.value)
				else
					local s = string.chop(term[1],n)
					clause = string.format(
						"%s %s LIKE '*%s*'", operator or "WHERE", s.key, s.value)
				end
			end
		end

		----------------------------------------------- 
		-- ...then all subsequent.
		----------------------------------------------- 
		for x=2,table.maxn(term) 
		do 
			for _,n in ipairs({"=","!","~"}) do
				if string.match(term[x],n)
				then
					if ribbon[n] ~= "LIKE"
					then
						local s = string.chop(term[x],n)
						clause = clause .. string.format(
							", %s %s '%s'",s.key, ribbon[n], s.value)
					else
						local s = string.chop(term[x],n)
						clause = clause .. string.format(
							", %s LIKE '*%s*'",s.key, s.value)
					end
				end
			end
		end
		if clause then
		return string.format(qstr .. clause, priv.table)
		else
		return string.format(qstr, priv.table)
		end
	end
end

------------------------------------------------------
-- build_named_query(t) 
--
-- Build a query from an alphabetically indexed table. 
------------------------------------------------------
local function build_named_query(t)
	local set_t = {}
	-- There has GOT to be a function for this...we do it all the time.
	if not is.ni(t) then
		for k,v in pairs(t) do 
			if type(v) == 'string' then
			table.insert(set_t, tostring(k) .. ' = ' .. "'" .. string.escape(v,{';',"'"}) .. "'")
			end
		end
	end
	return table.concat(set_t,", ") 
end

------------------------------------------------------
-- build_named_clause(t) 
--
-- Build a clause from an alphabetically indexed table. 
------------------------------------------------------
local function build_named_clause(t)
	local set_t = {}
	-- There has GOT to be a function for this...we do it all the time.
	if not is.ni(t) then
		for k,v in pairs(t) do 
			table.insert(set_t, tostring(k) .. ' = ' .. "'" .. v .. "'")
		end
	end
	return table.concat(set_t,", ") 
end


------------------------------------------------------
-- local exec(query,clean) 
--
-- Execute the query, check for gaming and
-- return a result.
--
-- Can activate debugging and error logging from one
-- place.
--
-- *table
------------------------------------------------------
local function exec(user_query,clean)
	-- Lookup should work faster.
	local out = priv.debug or 'standard'
	local e = {
		["debug"] = function ()
			local dbexec = priv.con:execute(user_query)
			if not dbexec
			then
				-- This needs a much better error report.
				if user_query then user_query = tostring(user_query) end
				response.abort({500},
					"There was an error parsing user query: " .. user_query ..
					"There has been an error in the database.")
				return
			else
				return dbexec end
		end,
		["standard"] = function ()
			-- This can be multiple types 
			-- (a number when running updates)
			-- (bool when doing writes)
			return priv.con:execute(user_query)
		end
	}
	return e[out]()
end


----------------------------------------------- 
-- dbErrors {}
--
-- Set a variety of different error messages.
----------------------------------------------- 
local dbErrors = {}

----------------------------------------------- 
-- dbTableManipulators {}
--
-- Functions to manipulate SQL tables.
----------------------------------------------- 
local dbTableManipulators = {
	----------------------------------------------- 
	-- .table(name)
	--
	-- Toss around a particular table, then
	-- you can omit it from the query.
	----------------------------------------------- 
	["init"] = function (name,debugging)
		priv.table = name
	end,

	----------------------------------------------- 
	--	.mktable(t)
	--
	-- Makes one table (t).
	----------------------------------------------- 
	["make"] = function (t)
		-- Make a table for each t.
		q.postgres 	= "CREATE TABLE %s( %s );"
		q.sqlite		= "CREATE TABLE %s ( %s );"
		for name,sql in pairs(t) do
			exec(string.format(q[conntype],name, sql ))
		end	
	end,

	----------------------------------------------- 
	--	.create(s)
	--
	-- Makes one table according to SQL in (s).
	----------------------------------------------- 
	["create"] = function (s)
		-- Make a table for each t.
		q.postgres 	= "CREATE TABLE %s( %s );"
		q.sqlite		= "CREATE TABLE %s ( %s );"

		-- How is this going to catch errors;
		exec(string.format(q[conntype], priv.table, s))
	end,

	----------------------------------------------- 
	--	.rmtable(t)
	--
	-- Removes a table.
	----------------------------------------------- 
	["remove"] = function (t)
		q[conntype] = "DROP TABLE %s"
		if type(t) == 'table' 
		then
			-- Destroy a table for each t.
			for name,columns in pairs(t) do
				exec(string.format(q[conntype], name))
			end
		elseif priv.table 
		then
			exec(string.format(q[conntype], priv.table))
		end
	end,

	----------------------------------------------- 
	--	mdtable(t)
	--
	-- Change a table name.
	----------------------------------------------- 
	["modify"] = function (old,new)
		q[conntype] = "UPDATE %s WHERE %s = %s;"
		exec(string.format(q[conntype],priv.table, old, new))
	end
}

------------------------------------------------------
-- dbRecordManipulator(s) {} 
--
-- Functions to manipulate records. 
------------------------------------------------------
local dbRecordManipulators = {
	------------------------------------------------------
	-- .chop() 
	--
	-- Chop stuff. 
	------------------------------------------------------
	["chop"] = function (t)
		return chop(t)
	end,
	
	----------------------------------------------- 
	-- .advance()
	--
	-- Let the database engine know whether we
	-- want to advance or not.
	----------------------------------------------- 
	["advance"] = function ()
		
	end,
	
	----------------------------------------------- 
	-- .insert(t)
	--
	-- Creates one record from a table t.
	--
	-- // More
	-- t must contain a [name] that corresponds
	-- to a table name, and values that correspond
	-- to given table's structure.
	-- 
	-- *bool
	----------------------------------------------- 
	["insert"] = function (t,keyref)
		----------------------------------------------- 
		-- Different query strings.
		----------------------------------------------- 
		q.postgres 	= "INSERT INTO %s VALUES( %s );"
		q.sqlite		= "INSERT INTO '%s' VALUES( %s );"

		----------------------------------------------- 
		-- Evaluate static SQL files.
		-- 
		-- The mapper does not run dynamically when 
		-- creating these.  `pagan-demonize` maybe?
		----------------------------------------------- 
		if pg.dbstatic
		then
			local qstring 
			local found = F.exists("sql/" .. priv.table .. ".lua") 
			F.asset("private")

			if found.status == true 
			then
				qstring = add.sql(priv.table).query	

				----------------------------------------------- 
				-- Error out if something bad happens.
				----------------------------------------------- 
				if not qstring
				then
					response.send({500},table.concat({
						"There is no map generated for table: <i>",
						priv.table .. "</i> yet. <br />Please create a table ", 
						"key for this table so that Pagan can run against it."
					}))

				----------------------------------------------- 
				-- Split our string.
				----------------------------------------------- 
				else
					local success = false
					for _,split in ipairs({',',', ','|'}) do
						q.qtypes  = table.from(qstring,split)
						if q.qtypes and table.maxn(q.qtypes) > 1
						then
							success = true 
							break	
						end
					end
			
					----------------------------------------------- 
					-- Error out, because we have nothing to map.
					----------------------------------------------- 
					if not success
					then
						response.send({500},msg)
							response.send({500},"There was an error parsing the SQL query map " ..
							"for this table: <i>" .. priv.table .. "</i>.  Please " ..
							"regenerate this file with a new query map.")
					end	
				end
			end -- if found.status == true

		----------------------------------------------- 
		-- Evaluate SQL schema dynamically.  
		----------------------------------------------- 
		else
			local b = D.maps()
			if type(t) == 'table'
			then
			local sqlt, ki = {}, 1
			if type(keyref) == 'table'
			then
				----------------------------------------------- 
				-- Set up shortnames, because they're
				-- absolutely ridiculous. 
				----------------------------------------------- 
				local qu = b[priv.table]["query"]
				local fm = b[priv.table]["format"]
				local ix = b[priv.table]["order"]

				----------------------------------------------- 
				-- Iterate over each element in the query
				-- string for proper type and supplied data.
				----------------------------------------------- 
				for ii,vv in ipairs(qu)
				do
					----------------------------------------------- 
					-- If the index in our query string points to
					-- some permutation of null, don't bother adding
					-- it to the SQL string as it has already been
					-- taken care of.
					----------------------------------------------- 
					local record_is_null = false
					for _,nullname in ipairs({"NULL","null"})
					do
						if qu[ii] == nullname 
						then
							record_is_null = true
							break
						end	
					end

					----------------------------------------------- 
					-- Only proceed if the record actually expects
					-- a value.
					----------------------------------------------- 
					if not record_is_null 
					then 
						----------------------------------------------- 
						-- Evaluate the correct formatting strings for
						-- unrequired values.
						----------------------------------------------- 
						if string.sub(keyref[ki],0,1) == '@'
						then
							----------------------------------------------- 
							-- Catch integers.
							----------------------------------------------- 
							if fm[string.sub(keyref[ki],2)] == '%d' 
							then 
								sqlt[ki] = t[string.sub(keyref[ki],2)] or 0 
								--------------------------------------------------
								-- A properly formed error will include 
								-- the value, the type expected by the 
								-- table column, and the name of the table
								-- column.
								--------------------------------------------------
								if type(sqlt[ki]) ~= 'integer' 
								then
									response.abort({500},
										"Critical database error:<br />" ..
										"Type of: " .. tostring(sqlt[ki]) ..
										" does not match expected type in table.")
								end

							----------------------------------------------- 
							-- Catch strings.
							----------------------------------------------- 
							elseif fm[string.sub(keyref[ki],2)] == '%s' 
							then 
								sqlt[ki] = string.format("'%s'",
									string.escape(t[string.sub(keyref[ki],2)] or "", 
									{";","'"}))

								if type(sqlt[ki]) ~= 'string' 
								then
									-- The error here and in the previous function 
									-- are the same.
									response.abort({500},
										"Critical database error:<br />" ..
										"Type of: " .. tostring(sqlt[ki]) ..
										" does not match expected type in table.")
								end
							end

						----------------------------------------------- 
						-- Evaluate the correct formatting strings for
						-- required values from t.
						----------------------------------------------- 
						elseif string.sub(keyref[ki],0,1) == '!'
						then
							sqlt[ki] = t[string.sub(keyref[ki],2)] or
								response.abort({500},"Required value not received.")
				
						----------------------------------------------- 
						-- Most likely, this value is not in t, but we
						-- have to evaluate it anyway.
						----------------------------------------------- 
						else
							if qu[ii] == '%s' then
								sqlt[ki] = string.format("'%s'",
									string.escape(keyref[ki] or "", {";","'"}))
							else 
								sqlt[ki] = keyref[ki] or ""
							end
						end

						----------------------------------------------- 
						-- One up our incrementor.
						----------------------------------------------- 
						ki = ki + 1
					end -- if not record_is_null 
				end -- for ii,vv in ipairs(b[priv.table]["query"])
	
				----------------------------------------------- 
				-- Die at any errors.
				----------------------------------------------- 
				for inc,strval in ipairs(sqlt) do
					if not strval then
						return response.send({500},"Value at " .. inc 
						.. "in result string is nil.") 
					end 
				end

				----------------------------------------------- 
				-- Run the INSERT statement.is
				----------------------------------------------- 
				--[[	
				P("Database writes")
				P(q[conntype])
				P(priv.table)
				P(table.concat(b[priv.table]["query"],","))
				P(sqlstr)
				P(table.concat(sqlt,","))
				--]]
			
				----------------------------------------------- 
				-- this code does not run:
				-- 1. unicode string checks for injections.
				-- 2. the built string for injections.
				--	
				-- There must be some ways to solve this...
				-- 1. Since C is part of the picture, you may
				-- be able to let the parser handle this job.
				-- 2. If not, then you may be able to write
				-- a pretty fast search algorithim to traverse
				-- the final string for any sort of injection.
				--
				-- Other than that, this is still a liability.
				----------------------------------------------- 
				---[[
				exec(
					string.format(q[conntype], priv.table, 
					string.format(table.concat(b[priv.table]["query"],","), 
					unpack(sqlt) )))
				--]]
			end

		----------------------------------------------- 
		-- Drop a formatted string, and your SQL 
		-- backend will write it.
		----------------------------------------------- 
		elseif type(t) == 'string'
		then
			exec(string.format(q[conntype],priv.table,t))

		----------------------------------------------- 
		-- Supports formatted strings, but in a table.
		-- This is murder considering what we've had
		-- to write so far. 
		----------------------------------------------- 
		else
			for name,values in pairs(t) do 
				exec(string.format(q[conntype], priv.table, values))
			end
		end
		end -- if pg.dbstatic
	end,

	----------------------------------------------- 
	-- .remove(term,comp)
	--
	-- Remove a record.
	-- Multiple criteria through table.
	--
	-- When term is just one item (no split) then
	-- Pagan will get rid of the item matching
	-- the ID.
	--
	-- When term is designated (x=y), then Pagan
	-- will drop the record where x = y.
	--
	-- When term is a table of designations, then
	-- Pagan will drop all applicable records.
	--
	-- Returns false when something goes wrong.
	-- 
	-- *bool
	----------------------------------------------- 
	["remove"] = function (term)
		local clause 
		if type(term) == 'string'
		then 
			----------------------------------------------- 
			-- Rid record at ID when ID is a string.
			----------------------------------------------- 
			if not string.find(term,'=')		-- equal
			 or not string.find(term,'!')		-- not
			 or not string.find(term,'~')		-- like
			then
				q[conntype] = "DELETE FROM %s WHERE %s = '%s';"
				exec(string.format(q[conntype], priv.table, "uid", term))

			----------------------------------------------- 
			-- Get rid of one or more records by 
			-- designation.
			----------------------------------------------- 
			else
				q[conntype] = "DELETE FROM %s WHERE %s = '%s';"
				local s = string.chop(term,"=")
				exec(string.format(q[conntype], priv.table, s.key, s.value))
			end

		----------------------------------------------- 
		-- Rid record at ID when ID is an integer.
		----------------------------------------------- 
		elseif type(term) == 'number'
		then
			q[conntype] = "DELETE FROM %s WHERE %s = %d;"
			exec(string.format(q[conntype], priv.table, "uid", term))

		----------------------------------------------- 
		-- Make a variable length WHERE clause
		----------------------------------------------- 
		elseif type(term) == 'table'
		then
			q[conntype] = "DELETE FROM %s WHERE %s = '%s';"
			for key, val in pairs(term)
			do
				-- Every exec must return a status or set using a private variable.
				exec(string.format(q[conntype], priv.table, term.key, term.value))
	--		P(tblquery(q[conntype], term) .. ";")
			--exec(tblquery(q[conntype], term) .. ";")
			end		
		end		
	end,

	----------------------------------------------- 
	--	modify(set,where)
	--
	-- Change a record's content.
	--
	-- *bool
	----------------------------------------------- 
	["modify"] = function (set,where)
		----------------------------------------------- 
		-- Create a query seed.
		----------------------------------------------- 
		q[conntype]	= "UPDATE %s" 
		local quer

		----------------------------------------------- 
		-- Create a long "AND" if necessary.
		----------------------------------------------- 
		if type(set) == 'string'
		 and type(where) == 'string'
		then
			quer = string.format("%s SET %s WHERE %s",
				q[conntype], bydelim(set), bydelim(where)) 

		elseif type(set) == 'table'	
		 and type(where) == 'table'	
		then
			-- only works with ipairs now?
			if is.ni(set) and is.ni(where) then
				quer = string.format("%s %s %s",
					q[conntype], tblquery("", set, "SET"), tblquery("", where))

			elseif is.ni(set) and not is.ni(where)
			then

			else
				-- Iterate through what you were supplied,
				-- But you should still check your schema for type 
				-- correctness and die before it makes it to the database.
				quer = string.format("%s %s %s",
				q[conntype], build_named_query(set), build_named_query(where))
			end

		elseif type(set) == 'string'	
		 and type(where) == 'table'
		then
			quer = string.format("%s SET %s %s",
				q[conntype], bydelim(set), tblquery("", where))

		elseif type(set) == 'table'	
		 and type(where) == 'string'	
		then
			if is.ni(set) then
				quer = string.format("%s %s WHERE %s",
					q[conntype], tblquery("", set, "SET"), bydelim(where))

			else
				quer = string.format("%s SET %s WHERE %s",
					q[conntype], build_named_query(set), bydelim(where))
			end
		end		
		
		--P(string.format(quer, priv.table) .. ";")
		exec(string.format(quer, priv.table) .. ";")
	end,
			
	----------------------------------------------- 
	--	.query(t)
	--
	-- Grab record(s) from a table. 
	-- 
	-- More
	-- Specifying t as an integer returns all 
	-- results from a LIMIT clause where [t] is the
	-- limit.
	--
	-- Specifying t as a string will create a 
	-- WHERE clause, where the term to the left of
	-- the seperator denotes the column and the right
	-- denotes the values.
	--
	-- Specifying t as a table will allow multiple
	-- types of records to be selected.
	-- 
	-- *table
	----------------------------------------------- 
	["select"] = function (term,clause,column)
		----------------------------------------------- 
		-- Set a default query string.
		----------------------------------------------- 
		q[conntype] = 'SELECT %s FROM %s'
		local colsel = column or '*'

		----------------------------------------------- 
		-- Select a default operator, a default limit 
		-- and send the query.
		----------------------------------------------- 
		local cur
		if not term
		 and not clause
		then 
			cur = string.format(q[conntype] .. ";", 
				colsel, priv.table)
			cur = exec(cur)
			return retrieve(cur)

		----------------------------------------------- 
		-- Handle zero as term. 
		----------------------------------------------- 
		elseif type(term) == 'number' and term == 0
		then	
			if not clause
			then
				q[conntype] = 'SELECT %s FROM %s;'
				cur = string.format(q[conntype], 
					colsel, priv.table)

			elseif type(clause) == 'string'
			then
				q[conntype] = 'SELECT %s FROM %s WHERE %s;'
				cur = string.format(q[conntype], 
					colsel, priv.table, bydelim(clause))

			elseif type(clause) == 'table'
			then
				q[conntype] = 'SELECT %s FROM %s %s;'
				cur = string.format(q[conntype], 
					colsel, priv.table, tblquery("",clause))
			end

			cur = exec(cur)
			return retrieve(cur)

		----------------------------------------------- 
		-- Select a default operator while specifying a
		-- LIMIT.
		----------------------------------------------- 
		elseif type(term) == 'number'
		then	
			if not clause
			then
				q[conntype] = 'SELECT %s FROM %s LIMIT %d;'
				cur = string.format(q[conntype], 
					colsel, priv.table, term)

			elseif type(clause) == 'string'
			then
				q[conntype] = 'SELECT %s FROM %s WHERE %s LIMIT %d;'
				cur = string.format(q[conntype], 
					colsel, priv.table, bydelim(clause), term)

			elseif type(clause) == 'table'
			then
				q[conntype] = 'SELECT %s FROM %s %s LIMIT %d;'
				cur = string.format(q[conntype], 
					colsel, priv.table, tblquery("",clause), term)
			end

			cur = exec(cur)
			return retrieve(cur)

		end
	end,

	----------------------------------------------- 
	-- .raw(str)
	--
	-- These are really tough.
	-- You might need to index every statement, check
	-- for it, and look for restricted tables.
	-- Be REALLY careful!
	----------------------------------------------- 
	["raw"] = function (str)
		-- Cleaning is important.
		str = tostring(str .. ';')
		if type(exec(str)) == 'userdata'
		then
			cur = retrieve(exec(str))
		end
	--P(type(cur))
		return cur
	end,
}

----------------------------------------------- 
-- db {}
--
-- Global database functions.
----------------------------------------------- 
local db = {
	----------------------------------------------- 
	-- init(handle)
	--
	-- Make our module aware of the database
	-- handle.
	--
	-- Still dangerous, because a malicious user
	-- can change the handle from here.
	----------------------------------------------- 
	["init"] = function (handle,dbtype,debugging)
		priv.con = handle
		conntype = dbtype
		if debugging
		then
			priv.debug = 'debug'
		end 
	end,

	["advance"] = function (keyword)
		priv.control = true
	end,

	----------------------------------------------- 
	-- .table {}
	--
	-- Modifies tables.
	----------------------------------------------- 
	["table"] = dbTableManipulators,

	----------------------------------------------- 
	-- .record {}
	--
	-- Modifies records.
	----------------------------------------------- 
	["record"] = dbRecordManipulators,
	
	----------------------------------------------- 
	--	exit() / shutdown()
	--
	-- Close out all the database access.
	----------------------------------------------- 
	["exit"] = function ()
		cur:close()
		priv.con:close()
		env:close()
	end
}

db.record.query = db.record.select

return db
