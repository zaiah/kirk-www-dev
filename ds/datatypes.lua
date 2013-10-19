------------------------------------------------------
-- datatypes.lua 
--
-- List of datatypes for regular SQL.
-- These may become applications.
------------------------------------------------------

------------------------------------------------------
-- types {} 
--
-- Different datatypes for different databases. 
------------------------------------------------------
return {
	------------------------------------------------------ 
	-- .sqlite {}
	------------------------------------------------------
	["sqlite"] = {
		["text"] = "%s",
		["integer"] = "%d",
		["real"] = '%d',
		["blob"] = "%s"
	},

	------------------------------------------------------ 
	-- .postgres {}
	--
	-- Reference here at:
	-- http://postgresql.org/docs/7.4/static/datatype.html
	------------------------------------------------------
	["postgres"] = {
		-- Strings
		["bit"] = "%s",
		["varbit"] = "%s",
		["bit varying"] = "%s",
		["bool"] = "%s",
		["bytea"] = "%s",	 				-- For binary data...not string.
		["varchar"] = "%s", 				-- Can be any length.
		["char"] = "%s",	 				-- Limited length.
		["text"] = "%s",
		["xml"] = "%s",
		["json"] = "%s",

		-- Integers / Numbers
		["bigint"] = "%s",
		["bigserial"] = "%s",
		["integer"] = "%d",
		["int"] = "%d",
		["int4"] = "%d",
		["real"] = "%d",
		["smallint"] = "%d",
		["int2"] = "%d",
		["smallserial"] = "%s",
		["serial2"] = "%s",
		["serial"] = "%s",
		["serial4"] = "%s",

		-- IP Address
		["cidr"] = "%s",	 				-- IP Address
		["inet"] = "%s",

		["date"] = '%d',
		["double precision"] = '%d',	-- both of these 
		["float8"] = '%d',				-- 	must be 8 bytes

		-- Weird array formats.
		["interval"] = "%s",

		-- Shapes (Are these GIS extensions?)
		["box"] = "%s",
		["circle"] = "%s",
		["path"] = "%s",
		["point"] = "%s",
		["polygon"] = "%s",

		-- Date & Time 
		["time"] = "%d",	-- Need rules to see if has timezone.
		["timestamp"] = "%d",

		-- Autoincrments & Identifiers
		["uuid"] = "%s",
		
		-- Postgres Only 
		["tsquery"] = "%s",
		["tsvector"] = "%s",
		["txid_snapshot"] = "%s",

		-- If you've defined a custom datatype, then
		-- you'll just have to figure it out on your own.
	},
}
