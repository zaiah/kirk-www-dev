------------------------------------------------------
-- template.lua 
--
-- Match results to names in template.
--
-- Possible options:
-- safe - Do not die if key in template not found in db.
-- syntax - { start = x, end = y }
-- execute - Disable / enable execution within template
------------------------------------------------------
local payload				-- String holding the payload.
local query					-- Table holding either database query or standard table.
local file					-- Reference to a file.
local do_exec = false 	-- Run execution or not.
local safe = false 		-- Decide whether or not to die if db or table keys are not found.
local syntax = {			-- Define some alternate syntax.
	start = "",
	finish = ""
}

------------------------------------------------------
-- local how_deep() 
--
-- Get the max depth of a table?
-- *integer 
------------------------------------------------------
local function how_deep(t)
	-- Get max depth.
end


------------------------------------------------------
-- local render (file) 
--
-- Render a particular file. 
-- *table
------------------------------------------------------
local function render ( file )
	-----------------------------------------------
	-- Load the template file into memory.
	-- 
	-- IE has some strange quirks here if newlines
	-- are omitted, and if the payload is under
	-- 512 bytes.
	-----------------------------------------------
	payload = table.concat(F.totable( file ),"\n")

	-----------------------------------------------
	-- Check for each word.
	-- Store each key ( <word> ) --> keys
	-----------------------------------------------
	if safe then -- safe checking option is on
		-- Store
		local keys = {}
		for w in string.gmatch( payload, "%{[%c%s%w_]+%}" )
		do
			table.insert(keys, ({string.gsub(w,"[%{%}%c%s]","")})[1])
		end

		-- Check
		for __,my_key in ipairs(keys)
		do
			local status = false
			if is.value( my_key, table.keys( query[1] ))
			then
				-- out.add( my_key .. "<br />")
				-- out.add( table.concat( table.keys( query[1] )) .. "<br />")
				status = true
				-- stop running and move to next result...
			end

			-- This is going to be slow, I cannot remember 
			-- how to simulate a continue right now.
			if not status 
			then
				die.with(500, {
					msg = _.div("error", {
						"Cannot find key: " .. my_key, 
						"In database: " .. _.i( pg.dbname ), 
						"Please check the template file supplied: " ..
						 _.i( file ), 
					})
				})
			end
		end
	end

	-----------------------------------------------
	-- Store each block  ( { <word> } ) --> blocks
	-----------------------------------------------
	local blocks = {}
	for w in string.gmatch( payload, "%{[%c%s%w_]+%}" )
	do
		table.insert(blocks, w)
	end

	-----------------------------------------------
	-- Then do matching per each term that's in 
	-- the above.
	-----------------------------------------------
	local final_block = {}
	for __, db_stream in ipairs(query) 
	do
		local minp = payload
		for __, keycorr in ipairs( blocks )
		do
			-- Create a simple keyname, since we can't 
			-- access both {keys} and {blocks} this way.
			keyname = ({string.gsub(keycorr,"[%{%}%c%s]","")})[1]

			-- Simple find-and-replace of [ { <word> } ] with [ database result ]. 
			-- Possible that these just don't work.
			minp = string.gsub( minp, keycorr, db_stream[keyname])
		end

		-- Insert it.
		table.insert( final_block, minp )
	end 

	return final_block
end


------------------------------------------------------
-- local execute(str) 
--
-- Using the execute key terms "[" & "]", render
-- a file.
------------------------------------------------------
local function execute( t )
	-----------------------------------------------
	-- Now store each execution block.
	-----------------------------------------------
	-- for w in string.gmatch( table.concat(t), "%[[%c%s%w_%p]+%]" )
	-- do
	local payload = table.concat(t) 
	for w in string.gmatch( payload, "%[[%c%s%w_\"'%.%(%)%/%=%{%}]+%]" )
	do
		-- See the block before execution.
		-- response.abort({200}, w )
		a = string.sub(w, 2, string.len(w) - 1) 
		a = loadstring(a)

		-- See the results of the execution.
		-- response.abort({200}, a() )
		if type(a) == 'function'
		then
			-- Should it be a fatal error if your function returns nothing?
			local result = a() 
			if result then
				payload = string.gsub( 
					payload, "%[[%c%s%w_\"'%.%(%)%/%=%{%}]+%]", a(), 1 ) 
			end
		else
			-- Need a way to extract which line failed and at what position.
			response.abort({200}, 
				"Execution of lines in template: " .. file .. " failed.")
		end	
	end

	-----------------------------------------------
	-- Return content stream.
	-----------------------------------------------
	return payload --table.concat(final_block) 
end


return {
   ------------------------------------------------------
	-- .exec()
	--
	-- Set execution to on or off.
	-- *nil
   ------------------------------------------------------
	exec = function (b)
		do_exec = true 
	end,

		
   ------------------------------------------------------
   -- .safe 
   --
   -- Set safe to true.
	-- *nil
   ------------------------------------------------------
	safe = function ()
		safe = true 
	end,
	
   ------------------------------------------------------
   -- .string(t, str) 
   --
   -- Render a template string [str].
	-- *string
   ------------------------------------------------------
	-- string = function (t, str)
	-- end,
	
   ------------------------------------------------------
	-- .db(t, f)
	--
	-- Render a database dump.
   ------------------------------------------------------
	db = function (t, file)
	end,

   ------------------------------------------------------
   -- .file(t, f) 
   --
   -- Render a properly syntaxed file [f].
	-- *string
	------------------------------------------------------
	file = function (t, file)
		-----------------------------------------------
		-- Check if a template file exists.
		-----------------------------------------------
		if file
		 and type(file) == 'string'
		then
			-- Search private assets only.
			F.asset("private")
			local fname = "templates/" .. file .. ".tpl"

			-- Check for a .tpl extension.
			local f = F.exists( fname )
			if not f.status
			then
				die.with(500, "File '" .. fname .. "' not found")
			end

			------------------------------------------------------
			-- Clean / peek into this. 
			------------------------------------------------------
			query = t

			------------------------------------------------------
			-- Render the file, evaluating whether or not we 
			-- wanted execution.
			------------------------------------------------------
			if not do_exec
			then
				return table.concat(render( f.handle ))
			else
				return execute( render(f.handle) )
			end
		end
	end,
}
