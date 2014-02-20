------------------------------------------------------
-- add.lua 
--
-- Return common objects and items. 
-- Unfortunately, it could be either text or string.
-- I tried to choose what was most appropiate.
------------------------------------------------------
return {
	------------------------------------------------------
	-- .app(fname)
	--
	-- Pick up a file in the pg.sink.private/apps/
	-- directory.
	--
	-- *table
	------------------------------------------------------
	["app"] = function (filename)
		F.asset("private")
		return F.object("apps/" .. filename)
	end,

	------------------------------------------------------
	-- .err(fname, ext)
	--
	-- Pick up a file in the pg.sink.private/error/
	-- directory.
	--
	-- *table or *string
	------------------------------------------------------
	["err"] = function (filename, ext)
		F.asset("private")
		-- add.err or send err can return proper headers and CSS as well
		local f = F.exists("error/" .. filename, {".html",".htm",".xhtml"})
		
		return F.object("error/" .. filename)
	end,

	------------------------------------------------------
	-- .sql(fname)
	--
	-- Pick up a file in the pg.sink.private/sql/ 
	-- directory.
	--
	-- *table
	------------------------------------------------------
	["sql"] = function (filename)
		F.asset("private")
		return F.object("sql/" .. filename)
	end,

	------------------------------------------------------
	-- .skel(fname)
	--
	-- Pick up a file in the pg.sink.skel/ directory.
	--
	-- *table
	------------------------------------------------------
	["skel"] = function (filename)
		F.asset("skel")
		local f = F.exists(filename,".lua")

		if f.status == true
		then
			return F.object(filename)
		else
			return nil
		end
	end,

	------------------------------------------------------
	-- .profile(fname)
	--
	-- Pick up a file in the pg.sink.private/profiles/
	-- directory.
	-- *string 
	------------------------------------------------------
	["profile"] = function (filename)
		F.asset("private")
		return F.object("profiles/" .. filename)
	end,

	------------------------------------------------------
	-- .asset()
	------------------------------------------------------
	["asset"] = function (filename)
		F.asset("private")
		return F.object("assets/" .. filename)
	end,

	------------------------------------------------------
	-- .html 
	--
	-- Pick up a file in the pg.sink.public/sql/ directory.
	-- *string 
	------------------------------------------------------
	["html"] = function (filename)
		-- If nothing found, return an empty string.	
		F.asset("public")
		local f = F.exists("html/" .. filename, {".html",".htm",".xhtml"})
		if f.status == true 
		then
			return table.concat(F.totable(f.handle))
		else
			return table.concat({nil})
		end
	end
}
