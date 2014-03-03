------------------------------------------------------
-- content.lua 
--
-- The reason this exists is in order to style
-- results in a more coherent way.
------------------------------------------------------
local dbblock  	-- Database/datastore results.
local datasource  -- Set a datasource.
local format		-- The way we wish to interpret our stuff.


------------------------------------------------------
-- Public items
------------------------------------------------------
local headers = {} -- Iterate over these and you can view table headers.
local indices		-- You need a standard way to iterate over a table that's
						-- been reindexed.


------------------------------------------------------
-- local typecheck(x)
--
-- Return x according to it's type.
--  
-- *string, *nil, *number, *table, *userdata
------------------------------------------------------
local function typecheck(x)
	return ({
		["function"] = function () return x() end,
		["string"] = function () return tostring(x) end,
		["number"] = function () return tonumber(x) end,
		["nil"] = function () return nil end, 
		["userdata"] = function () return "Userdata.  Access denied" end, 
		["table"] = function () return x end, 
	})[type(x)]()
end


------------------------------------------------------
-- 1. Query is evaluated before we even start.
-- 2. I need all the indices somehow.
-- 3. For each one, does append, replace or subvert
-- exist?
-- 4. If so, what type?  Handle it properly.
-- 5. Store the results somewhere and return.
------------------------------------------------------

---------------------------------------------------
-- new(profile, datasource)
--
-- Creates a connection to a table and sets up 
-- our module with a data source.
--
-- *nil
-------------------------------------------------
local function new(userformat, altds)
	if userformat 
	then
		-------------------------------------------------
		-- Get a userformat or skel.
		-- Or just grab some other file.
		-------------------------------------------------
		if type(userformat) == 'string'
		then
			for _,asset_type in ipairs({"skel","private"})
			do
				local f,get
				-- Find skels by extension.
				if asset_type == 'skel' 
				then
					F.asset("skel")
					f = F.exists(userformat, {".lua"})
					get = "skel"

				-- Find profiles by extension.
				elseif asset_type == 'private' 
				then
					F.asset("private") 
					f = F.exists("profiles/".. userformat, {".lua"})
					get = "profile"
				end

				-- Utilize some profile. 
				if f.status == true
				then
					format = add[get](userformat)
				end
			end
				
		-------------------------------------------------
		-- How to iterate over something random?
		-------------------------------------------------
		elseif type(userformat) == 'table'
		then
			format = userformat
		end

		if format
		then 
			-------------------------------------------------
			-- We only have one data profile and don't want
			-- to use a file, so we know what query to
			-- expect. 
			-------------------------------------------------
			if format.data 
			then
				if is.ni(format.data) 
				then
					return {
						["data"] = format.data,
						["append"] = table.return_to_key(format,{"append"}),
						["replace"] = table.return_to_key(format,{"replace"}),
						["subvert"] = table.return_to_key(format,{"subvert"}),
						["index"] = table.return_to_key(format,{"index"})
					}

				-------------------------------------------------
				-- If we've defined more than one query, choose
				-- the one that's been specified or the default
				-- if we were too lazy.
				-------------------------------------------------
				else
					local source = altds or "default"
					local transf = {
						["data"] = format.data[source], 
					}

					-------------------------------------------------
					-- Haven't found a great way of cycling through
					-- these transformations when a namespace is 
					-- involved.
					-------------------------------------------------
					for _,n in ipairs({"append", "replace", "subvert","index"})
					do
						if format[n]
						 and format[n][source]
						then
							transf[n] = format[n][source]
						end
					end

					-------------------------------------------------
					-- Return the block.
					-------------------------------------------------
					return transf 
				end -- if is.ni(format.data)

			-------------------------------------------------
			-- I want to support short queries.
			-------------------------------------------------
			elseif format.short
			then
				if is.ni(format.short)
				then
					local fs = format.short
					return {
						["data"] = D.connect(fs[1]).record.query(
							fs[2],fs[3],fs[4]),
						["append"] = table.return_to_key(format,{"append"}),
						["replace"] = table.return_to_key(format,{"replace"}),
						["subvert"] = table.return_to_key(format,{"subvert"}),
						["index"] = table.return_to_key(format,{"index"})
					}

				-------------------------------------------------
				-- If we've defined more than one query, choose
				-- the one that's been specified or the default
				-- if we were too lazy.
				--
				-- This can definitely be simplified.
				-------------------------------------------------
				else
					local source = altds or "default"
					local transf = {
						["data"] = format.short[source], 
					}

					-------------------------------------------------
					-- Haven't found a great way of cycling through
					-- these transformations when a namespace is 
					-- involved.
					-------------------------------------------------
					for _,n in ipairs({"append", "replace", "subvert","index"})
					do
						if format[n]
						 and format[n][source]
						then
							transf[n] = format[n][source]
						end
					end

					-------------------------------------------------
					-- Return the block.
					-------------------------------------------------
					return transf 
				end
			end
		else
			return nil
		end
	end -- if userformat
end

return {
	-------------------------------------------------
	-- .header()
	--
	-- Unsure if this will just return the current
	-- header according to a spec or if it will 
	-- create it.
	-------------------------------------------------
	["header"] = function ()
		return headers
	end,
	
	-------------------------------------------------
	-- process(t,ads)
	--
	-- ...
	-- *table
	-------------------------------------------------
	["process"] = function (t,ads)
		-------------------------------------------------
		-- Move through a set of results that exists.
		-------------------------------------------------
		local us = new(t,ads)		-- Set up the profile.
		local public = {}				-- Keep processed records.

		-------------------------------------------------
		-- If we just want a raw statement, use it.
		-------------------------------------------------

		-------------------------------------------------
		-- Data is required.
		-------------------------------------------------
		if us.data
		then
			for key,vtable in ipairs(us.data)
			do
				------------------------------------------------------
				-- Globally add immutable database resources.
				------------------------------------------------------
				if vtable 
				then
					for k,v in pairs(vtable) do
						data.resource[k] = v 
					end
				end

				------------------------------------------------------
				-- Sort the results according to our formatting.
				------------------------------------------------------
				local set = {}
	
				for key,value in pairs(vtable)
				do
					------------------------------------------------------
					-- Replace any database results.
					------------------------------------------------------
					if vtable[key] 
					 and us.replace and us.replace[key]
					 then	
						invalid_pattern = false
						-- Is it just hex chars??
						for _,x in ipairs({
							1,2,3,4,5,6,7,8,9,';',
							'A','B','C','D','E','F',
							'a','b','c','d','e','f'
						}) 
						do
						if string.find(vtable[key],'%'..x,nil,"plain") 
						then
							invalid_pattern = true; break; end
						end
	
					if not invalid_pattern then	
						-- Does not work with URL encoded strings?
						set[key] = string.format(
							typecheck(us.replace[key]),
							tostring(vtable[key]))
					else
						set[key] = tostring(vtable[key])
					end
				
					------------------------------------------------------
					-- Subvert results.
					------------------------------------------------------
					elseif vtable[key]
					 and is.value(key, us.subvert) 
					 then 
					------------------------------------------------------
					-- This is supposed to do something. 
					-- But what??
					------------------------------------------------------

					------------------------------------------------------
					-- Drop the raw database results in the table.
					------------------------------------------------------
					else
						set[key] = vtable[key] 
					end
				end -- for key, vtable in ipairs(us.data)
				
				------------------------------------------------------
				-- Do appends.
				-- You will have a namespace conflict here.
				------------------------------------------------------
				if us.append 
				then
					for key,val in pairs(us.append)
					do
						set[key] = typecheck(val)
					end
				end

				------------------------------------------------------
				-- Reindex if we've asked for it.
				------------------------------------------------------
				local resset
				if us.index then
					for _,value in ipairs(us.index) do
						table.insert(headers,value) 
					end 
					resset = table.reindex(set, us.index)
				else 
					resset = set end
	
				------------------------------------------------------
				-- Finally save the processed resources, but check 
				-- for an indexing scheme.
				------------------------------------------------------
				table.insert(public,resset)
				data.resource = {}	
			end	-- for key, vtable in ipairs(us.data)
			return public
		end	-- if us.data
	end
}
