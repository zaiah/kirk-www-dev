------------------------------------------------------
-- mappers.lua 
--
-- Create maps, schemata and properly formatted
-- strings for different database types. 
------------------------------------------------------
------------------------------------------------------
-- null_clause_exists(s,nc) 
--
-- Check string [s] for the presence of [nc] in 
-- either upper or lower case. 
------------------------------------------------------
local function null_clause_exists(s,nc)
	-- Check upper, lower and permutated ( OmG, I fReAkIn LoVe ThoSe ShuuuueeeEEeeezz! )
	local status = false
	if type(s) == 'string' 
	then
		for _,n in ipairs({string.upper(nc), string.lower(nc)})
		do
			if string.find(s,n) then
			 	status = true
				return status	
			end
		end
	end 
	return status
end 

return function (t,get_type)
	------------------------------------------------------
	-- Variables everywhere.
	------------------------------------------------------
	local create_stmt		-- Hold for the create statement.
	local tables = {}		-- Hold for all the tables in a database.
	local views = {}		-- Hold for all the views in a database.
	local indices = {}	-- Hold for all the indices in a database.
	local schema = {}		-- Hold the schemata.
	local query = {}		-- Hold for query strings
	local sqlmap = {}		-- Table for the SQL map
	local order	= {}		-- Maintain column order.
	local null_clause		-- Hold space for "null clause"

	local Dschema = {}
	local Dquery = {}
	local Dsqlmap = {}
	local is_accessed = true	-- Define whether we've searched
										-- for a schema or not. 

	-- Anyway to initialize these as types?
	local index				-- String for the index we want.
	local datatype			-- String for the datatype.
	local pos 				-- String for the position.

	-- Returned tables.
	local sch_tables = {}	
	
	------------------------------------------------------
	-- Evaluate the items coming from {D}
	------------------------------------------------------
	local file_schema = t.fs
	local conntype = t.conntype
	local dbo = t.db_name or response.send({500},
		"No database was specified;" ..
		" therefore Pagan cannot retrieve " ..
		"a schema.<br/>Please either create the database yourself " ..
		"or set <u>dbauto</u> to <i>true</i> in the file located at " ..
		"data/definitions.lua.")

   ------------------------------------------------------
   -- Get a schema of some SQLite database.
   ------------------------------------------------------
	if conntype == 'sqlite'
	then
	  ------------------------------------------------------
	  -- Loading a file is ridiculous.
	  ------------------------------------------------------
	 	F.asset("private")
		local FF = F.exists(file_schema)

		if FF.status 
		then 
			local types = require("ds.datatypes")
			local view_detected = false
			null_clause = "autoincrement" 
			
			for line in io.lines(FF.handle)
			do
			  ------------------------------------------------------
			  -- Find the table name.
			  ------------------------------------------------------
				create_stmt =  { string.find(line,"CREATE TABLE ") }
				create_view =  { string.find(line,"CREATE VIEW") }

			   ------------------------------------------------------
			   -- Skip views and subsequent lines until we've 
			   -- reached the end of the statement.
			   ------------------------------------------------------
				if create_view[1] 
				 or view_detected 
				then
					-- Keep advancing lines until you reach a semicolon.
					view_detected = true
					if string.find(line,';',nil,"plain") then
						view_detected = false end 
							

			   ------------------------------------------------------
			   -- We found a new table, so let's get the schema.
			   ------------------------------------------------------
				elseif create_stmt[1]
				then
					-- Try 3 searches (\n, '(' or ' (').
					for _,n in ipairs({' (', '(', '\n('}) do
						if string.find(line,n,nil,"plain") then
							end_create_stmt = string.find(line,n,nil,"plain")
							break
						end
					end

					-- Stop processing if nothing was found.
					if not end_create_stmt then 
						response.send({500},"Could not load database tables.") end

					-- Get the current table name.
					tables.current = string.sub(line,
						( create_stmt[2] + 1 ),
						( end_create_stmt - 1 )) 
	

				   ------------------------------------------------------
					-- Indicate that we're ready to save the schema, order
					-- and query string of the first table encountered.
				   ------------------------------------------------------
					if not tables.old
					then
						tables.old = tables.current
						sqlmap[tables.current] = {
							["order"] = {}, 
							["query"] = {},
							["format"] = {},
							["schema"] = {} 
						}

						-- Save this for reference if we've asked for it.
						-- (via get_type)
						table.insert(sch_tables, tables.current)

				   ------------------------------------------------------
					-- Now we're ready to save the next (schema, order
					-- and query string). 
				   ------------------------------------------------------
					elseif tables.current ~= tables.old
					then
					   ------------------------------------------------------
						-- Save the query string.
					   ------------------------------------------------------
					   -- Be sure to catch ''s because they're wrong...
						sqlmap[tables.old]["query"] = Dquery --table.concat(Dquery,",")
						
					   ------------------------------------------------------
						-- Maintain order
					   ------------------------------------------------------
						sqlmap[tables.current] = {
							["order"] = {}, 
							["query"] = {},
							["format"] = {},
							["schema"] = {} }

					   ------------------------------------------------------
						-- Empty the tables and update namespace.
					   ------------------------------------------------------
					   tables.old = tables.current

						-- Save this for reference if we've asked for it.
						-- (via get_type)
						table.insert(sch_tables, tables.current)

						Dquery, Dsqlmap = {}, {}
						is_accessed = false
					end	
					
			  ------------------------------------------------------
			  -- To only break tables, you need to grab from the
			  -- CREATE statement to the next )
			  ------------------------------------------------------
				else

					------------------------------------------------------
					-- Make an approximation on the index and datatypes
					-- loaded.
					------------------------------------------------------
					index = string.match(line, "[%a%d,_]+ ")
					if index
					then 
						pos = ({string.find(line,index)})[2] 

						------------------------------------------------------
						-- NOTE: These holds are going to be different when 
						-- using Postgres or MySQL.
						------------------------------------------------------
						for i,v in ipairs({
							"[%a%d]+,",
							"[%a%d]+%)",
							"[%a%d]+ %)",
							-- Not working quite so well, can't pick up newlines...
							"[%a%d]+\r\n%)",
						}) 
						do
							local strmtch = string.match(line, v, pos)
							if strmtch then 
								({ 
									-- Return the capture as is.
									function () datatype = strmtch end, 
									function () datatype = strmtch end, 
									-- Return the capture without the trailing parentheses.
									function () 
										datatype = string.sub(strmtch,0,
											(string.len(strmtch) - 2)) 
									end, 
									function () 
										datatype = string.sub(strmtch,0,
											(string.len(strmtch) - 4)) 
									end, 
								})[i]()
								break; 
							else datatype = nil end
						end

						------------------------------------------------------
						-- Start building some sort of query string.
						------------------------------------------------------
						if datatype
						then
							index = string.sub( index, 1, ( string.len(index) - 1 ))
							datatype = string.gsub(string.sub( datatype, 1 ),',','')

							------------------------------------------------------
							-- Pagan uses UID for an AUTOINCREMENT field.
							-- If there is none, we just don't worry...
							--
							-- This becomes mega-wrong because we can easily
							-- have multiple fields that support AUTOINCREMENT.
							--	
							-- Additionally, other SQL engines may very well
							-- NOT use AUTOINCREMENT, so this "null clause" should
							-- be defined by something else.
							------------------------------------------------------
							if null_clause_exists(line, null_clause) 
							then
								table.insert(Dquery,"null")

							------------------------------------------------------
							-- Save the rest of the query string and build a 
							-- schema we can traverse.
							------------------------------------------------------
							else
								-- Order
								table.insert(sqlmap[tables.current]["order"],index)  

								-- Schema 
								sqlmap[tables.current]["schema"][index] = datatype

								-- Query
								table.insert(Dquery, 
									types.sqlite[string.lower(datatype)]) 
			
								-- Format
								sqlmap[tables.current]["format"][index] = types.sqlite[string.lower(datatype)]
							end
						end -- if datatype
					end -- if index 
				end -- if create_stmt[1]
			end -- for
		end -- if ff == 0

		------------------------------------------------------
		-- Write the last query.
		------------------------------------------------------
		if not is_accessed then 
			sqlmap[tables.current]["query"] = Dquery
			Dquery, Dsqlmap, tables = {}, {}, {}
		end

		------------------------------------------------------
		-- Return the block.
		------------------------------------------------------
		if type(get_type) == 'boolean'
		then
			return {
				["schema"] = sqlmap,
				["tables"] = sch_tables, }

		------------------------------------------------------
		-- Get tables, schema or something else specific.
		------------------------------------------------------
		elseif sqlmap and type(sqlmap) == 'table' 
		then 
			return sqlmap 
		end

   ------------------------------------------------------
   -- Get a schema of some SQLite database.
   ------------------------------------------------------
	elseif conntype == 'postgres'
	then

   ------------------------------------------------------
   -- You might have specified something that Pagan does
   -- not support.
   ------------------------------------------------------
	else
		return "omg, it's not sqlite"
	end -- if conntype == 'sqlite3'
end
