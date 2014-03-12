------------------------------------------------------
-- db.lua
--
-- Connects to a module's database and more.
--  
-- // More
-- Opens an active connection to either a PostGres or
-- SQLite database.
--
-- // To Do
-- How do you handle multiple databases?
------------------------------------------------------
local priv = {}
local file_schema = "local/dbschema"	-- File to write schema to.

------------------------------------------------------
-- loaddb(db[string],conntype[postgres,sqlite]) local
--
-- Loads the proper database handle and any
-- authorization.
--
-- // More
-- sqlite will automatically create a file with the
-- database if it is not there.
--
-- Currently, however, postgres will need its database
-- created before draftling can use it.
-- This will change shortly.
--
-- *table
------------------------------------------------------
local function loaddb(db,conntype)
	local con
	if conntype == 'sqlite' 
	then
		local p 		= require('luasql.sqlite3')
		local env 	= p.sqlite3()
		con			= assert(env:connect(db)) 
		--[[
		if not con
			response.abort({500},"Cannot connect to database.") end
		--]]
	elseif conntype == 'postgres' 
	then
		local p 		= require('luasql.postgres')
		local dbname = string.gsub(db,'../db/','')
		
		-- Authentication details (db, username, password, hostname, port)
		local auth	= dofile('../db/auth/'..dbname..'.lua')

		-- Connect
		local env 	= assert(p.postgres())
		con			= assert(env:connect(db))  
		--[[
		if not con
			response.abort({500},"Cannot connect to database.") end
		--]]
	end
	return con
end

------------------------------------------------------
-- isPostgresOn() local
--
-- Throws an error if the user you specified can't
-- find an instance of postgres running.
--
-- If you ever need bash scripts, use a checksum.
-- Same with the rest of these files.
-- Checksum them and keep that somewhere.
-- This can be a module to help you secure the frame
-- work.
--
-- *bool
------------------------------------------------------
local function isPostgresOn()
	-- local g = assert(os.execute('ps aux | grep postgres'))
	local pg_status = false
	if assert(os.execute('ps aux | grep postgres'))
	then 
		pg_status = true 
	end
	return pg_status
end
 
------------------------------------------------------
-- exists() local
-- 
-- Checks if a particular table already exists. 
-- 
-- // More
--
-- exists() checks if a certain index exists in a 
-- certain table.  If it returns false, most likely
-- there is no table by that name anywhere in the
-- database.
--
-- If no check is supplied then use 'uid' as a index
-- to check for.
-- 
-- // ToDo
-- Replace this with a util call.
--
-- *bool
------------------------------------------------------
local function exists(t) 
	local query = string.format("SELECT * FROM %s LIMIT 1", t.table)
	if t.db.record.raw(query)
	then
		return true 
	else
		return false
	end
end

------------------------------------------------------
-- local function create()
--
-- Create our tables if we don't think they exist. 
------------------------------------------------------
local function create(t)
	local struct, st = {
		["sql"] = string.format("sql/%s.lua",t.table),
		["db"]  = t.db or nil,
		["table"] = t.table or nil
	}

	------------------------------------------------------
	-- ???
	------------------------------------------------------
	if struct.table 
	 and struct.db 
	then
		-- Load the SQL file if it exists..
		F.asset("private")
		if F.exists(struct.sql)
		then
			st = F.object(struct.sql)
		end
	
		-- Check if the backend we chose has tables.
		if is.key(t.conntype,st)
		then 
			-- Make database table.
			struct.db.table.make({[struct.table] = st[t.conntype]})
			
			-- How to catch an error on write?
			if t.records then
				struct.db.record.insert({[struct.table] = st.records})
			end
		else
			-- Log lack of backend as an error. 
			B(string.format("Could not use selected backend: %s",t.conntype))
			return false	
		end
	end
end

------------------------------------------------------
-- connection {}
--
-- Public database information and functions for
-- apps.
------------------------------------------------------
local connection = {
	------------------------------------------------------
	-- .conntype()
	--
	-- Return connection type.
	-- SQLite by default.
	--
	-- *string.
	------------------------------------------------------
	["conntype"] = function ()
		local pg = dofile('../data/definitions.lua')
		if pg.conntype then
			return pg.conntype
		else
			return 'SQLite' 
		end
	end,

	------------------------------------------------------
	-- .connect(t)
	--
	-- Set up a database connection.
	--
	-- *table
	------------------------------------------------------
	["connect"] = function (tb_name)
		-- Prepare connection and load files.
		local db 		= require("ds.query")
		local conntype = pg.conntype or 'sqlite' 
		local db_name	= tostring(pg.dbname)

		-- Depending on backend, do something.
		-- This should just fail if it's wrong.
		if conntype == 'sqlite' 
	--	 or conntype == 'postgres' 	
	--	 and not isPostgresOn() 
		then
			priv.connection = loaddb('../db/' .. db_name,conntype)
		elseif conntype == 'postgres' 
		then
			if isPostgresOn()
			then
				priv.connection = loaddb(db_name,conntype)
			else
				response.send({500},"There is no Postgres instance running.")
			end
		end

		-- Make the handler aware of our connection and 
		-- turn on debugging if we asked for it.
		db.init(priv.connection,conntype,pg.dbdebug)

		-- Create our tables if we asked for it.
		if pg.dbauto 
		then
			-- The database or view should exist.
			if not exists({["table"] = tb_name, ["db"] = db})
			then
				-- Throw error if no file exists of course...
				create({["table"] = tb_name,["db"] = db,["conntype"] = conntype})
			end
		end

		-- Connect to and start pulling from the table.
		db.table.init(tb_name)
		return db
	end,

	------------------------------------------------------
	-- .generate_schema()
	--
	-- This is just a crutch function to keep os closed.
	-- *nil
	------------------------------------------------------
	["generate_schema"] = function ()
		if pg.conntype == "postgres"
		then
		elseif pg.dbname 
		 and ( 
			pg.conntype == "sqlite"
		 	or not pg.conntype 
	    )
		then
			if os.execute(
				"/usr/bin/sqlite3 " .. 
				"../db/" .. pg.dbname .. 
				" '.schema' > ../data/" .. file_schema) == 0
			then
				return true
			else
				return false
			end
		end
	end,

	------------------------------------------------------
	-- .eval(v)
	--
	-- Evaluate a value and return it?
	-- *number, *string
	------------------------------------------------------
	["eval"] = function (x,y)
		if type(x) == 'number' or (type(x) == 'string' and x ~= '')
			then return x
		-- What do we do with nil?
		elseif y then return y end
	end,

	------------------------------------------------------
	-- .maps() 
	--
	-- Execute maps and stuff. 
	-- This needs to run all of the time, but it 
	-- shouldn't be global.
	------------------------------------------------------
	["maps"] = function ()
		-- Datastore mapper. 
		local go = require("ds.mapper")

		-- Prepare connection and load files.
		local db 		= require("ds.query")
		local conntype = pg.conntype or 'sqlite' 
		local db_name	= tostring(pg.dbname)

		-- This is here for test purposes, but it should be a real table.
		--response.send({200}, go({
		return go({
			["conntype"] = conntype,
			["db_name"] = db_name,
			["fs"] = file_schema 
		}) 
	end,

	------------------------------------------------------
	-- maptest
	--
	-- Too many failures...and they don't make sense...
	------------------------------------------------------
	["maptest"] = function ()
		local t = {}
		local bla = function (x,y,z) 
			return string.format("<b>%s.%s:</b>\n",x,y) end
		for n,x in pairs( D.maps() ) do 
			table.insert(t,"Outer table name: ".. n) 
			for k,v in pairs( x ) do 
				if k == 'query' then
					if type(v) == 'table' then v = table.concat(v,",") end
					table.insert(t, bla(n,"query") .. v)
					table.insert(t, "\n")
				elseif k == 'order' then
					table.insert(t, bla(n,"ordering").. table.concat(v,", "))
					table.insert(t, "\n")
				elseif k == 'schema' then
					table.insert(t, bla(n,"schema"))
					for kk,vv in pairs(v) do
						table.insert(t,kk .. " is " .. vv) end
					table.insert(t, "\n")
				end	
			end	
		end

		table.insert(t, table.concat( D.maps(),"" ))
		return html.pre(table.concat(t,"\n"))
	end,

	------------------------------------------------------
	-- .getdb() 
	--
	-- Return a list of tables that have been created. 
	------------------------------------------------------
	["gettb"] = function ()
		local go = require("ds.mapper")

		-- Prepare connection and load files.
		local db 		= require("ds.query")
		local conntype = pg.conntype or 'sqlite' 
		local db_name	= tostring(pg.dbname)

		-- This is here for test purposes, but it should be a real table.
		--response.send({200}, go({
		return go({
			["conntype"] = conntype,
			["db_name"] = db_name,
			["fs"] = file_schema 
		},true) 
	end,

	------------------------------------------------------
	-- .check_for_existence() 
	--
	-- Check for the existence of tables provided by an
	-- application.
	------------------------------------------------------
	["check_for_existence"] = function (t)
		local name
		for tname, init_string in pairs(t)
		do
			if not table.index( D.gettb()["tables"], tname) then
				D.connect(tname).table.create(init_string)
			end	
		end
	end,


	------------------------------------------------------
	-- .encaps(s)
	--
	-- Temporary measure for writing new data to 
	-- database. 
	------------------------------------------------------
	encaps = function(s)
		-- A way better debugging engine will fix a ton of these problems.
		-- Hard to catch otherwise, even with a proper error code.
		s = string.escape(s,"'")

		-- Don't really want to die on empty strings.
		-- A more intelligent way to set a default value is wiser.
		return "'" .. (s or "") .. "'"	
	end,

	------------------------------------------------------
	-- add_to_db( name, t ) 
	--
	-- Temporary measure to add new rows in a database. 
	------------------------------------------------------
	add_to_db = function ( tb_name, t) 
		if type(tb_name) ~= "string" then
			response.abort({500}, "No table name supplied to add_to_db(name, t)")
		else
		D.connect( tb_name ).record.insert( table.concat(t,","))
		end
	end
}

return connection 
