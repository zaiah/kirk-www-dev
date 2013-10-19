------------------------------------------------------
-- _file.lua 
--
-- Do stuff with files. 
--
-- Check for: 
-- successful write.
-- successful save.
-- successful close.
------------------------------------------------------
local priv = {}

------------------------------------------------------
-- Set up.
------------------------------------------------------
local file 	= {}
local asset	= priv.asset or 'public'

------------------------------------------------------
-- Handles for different file functions.
------------------------------------------------------
file.name	= 'infile'	-- File name.
file.atype	= 'public'	-- Default asset type.
file.tmp		= {}			-- Temporary hold.

------------------------------------------------------
-- default(filename) local
--
-- Return a filename.
-- *string
------------------------------------------------------
local function default(filename)
	local f = filename or file.name
	return string.format('%s/%s',pg.sink[file.atype],f)
end

------------------------------------------------------
-- protected(filename) local TEST 
--
-- Return a file in some other location... 
------------------------------------------------------
local function protected(filename)
	local f = filename or file.name
	return string.format('%s',f)
end

------------------------------------------------------
-- tabularize(file,r1,r2) local
--
-- Save file contents to a table. 
--
-- *table
------------------------------------------------------
local function tabularize(fask,r1,r2)
	------------------------------------------------------
	-- ???
	------------------------------------------------------
	local tt, c = {}, 1
	local fullpath = pg.sink[file.atype] .. "/" .. fask
	for line in io.lines(fask)
	do
		tt[c] = line
		c = c + 1
	end
	
	------------------------------------------------------
	-- ???
	------------------------------------------------------
	if r1 and r2
	then
		local c,tr = r1 + 1, table.string(tt[r1])
		while c ~= r2
		do
			tr.append(tt[c])
			c = c + 1
		end
		return tr.table()
	else
		return tt
	end
end

	
------------------------------------------------------
-- .save(text,filename) local
--
-- Write information to a file.
-- *nil
------------------------------------------------------
local function save(text,filename)
	local ff = io.open(filename,'a+')
	ff:write(tostring(text))
	ff:flush()
	ff:close()
end

------------------------------------------------------
-- mktmp() 
--
-- Create a temporary file from some data.
-- *string
------------------------------------------------------
local function mktmp()
	-- Return table indicator as unique idenitifier.
	local tt 	= {}
	local uuid  = tostring((function ()
		return { string.gsub(
			string.gsub(tostring(tt),'table: ',''),'0x','') 
		}
	end
	)()[1])

	-- Add to tmp table.
	local index = table.maxn(file.tmp) + 1 
	file.tmp[index] = tostring(pg.sink.tmp .. '/' .. uuid) 
	return file.tmp[index]
end

------------------------------------------------------
-- f {} 
--
-- Public file functions.
------------------------------------------------------
local f = {
	------------------------------------------------------
	-- .asset([public,private]) 
	--
	-- Set asset type.
	------------------------------------------------------
	["asset"] = function(atype) 
		local assets = {
			["skel"] = "skel",
			["public"] = "public",
			["private"] = "private",
			["tmp"] = "tmp"
		}

		if is.key(atype,assets) then
			file.atype = assets[atype]
		end
	end,
	
	------------------------------------------------------
	-- .name(filename)
	--
	-- Use this as filename.
	-- Return current filename if filename is boolean.
	-- *string or *nil
	------------------------------------------------------
	["name"] = function(filename)
		local f
		if filename
		 and type(filename) == 'string'
		 then
			file.name = filename
			f = nil
		elseif filename
		 and type(filename) == 'boolean' 
		 then
			f = default()
		 else	
		end
		return f
	end,

	------------------------------------------------------
	-- binary(file) local
	--
	-- Open your binary document.
	-- 
	-- *table
	------------------------------------------------------
	["binary"] = function (file)
		local rr = assert(io.open(default(file),'rb')) -- Does this open twice???
		if rr 
		then
			P(rr:read("*a"))
			rr:close()
		end
	end,

	------------------------------------------------------
	-- .exists(file,suffix)
	--
	-- Check if [file] exists.
	-- If so return status and handle?
	--
	-- *table
	------------------------------------------------------
	["exists"] = function (fask,suffix)
		------------------------------------------------------
		-- Find a file name with any suffix.
		------------------------------------------------------
		if fask 
		 and suffix
		then
			-- Define some stuff.
			local status, search  = false, {}
			local fullpath = pg.sink[file.atype] .. "/" .. fask
			search[1] = fullpath
	
			-- Try regular file and files with the suffix.
			if type(suffix) == 'table'
			then
				for _,v in ipairs(suffix) do
					table.insert(search,fullpath .. v)
				end
			else
				search[2] = fullpath .. suffix
			end

			-- Then see if they can be opened.
			-- Return true and the handle name if so.
			for _,f in ipairs(search)  
			do
				if io.open(f)
				then 
					local handle = string.gsub(f, pg.sink[file.atype] .. "/","")
					status = true
					return { ["status"] = status, ["handle"] = f } 
				end			
			end
	
			-- If nothing was found, return failure.
			if not status then
				return { ["status"] = false, ["handle"] = 0 } 
			end
					
		------------------------------------------------------
		-- Just find a file name?
		------------------------------------------------------
		elseif fask
		then
			if io.open(pg.sink[file.atype] .. "/" .. fask)
			then
				local handle = pg.sink[file.atype] .. "/" .. fask
				return { ["status"] = true, ["handle"] = handle} 
			else
				return { ["status"] = false, ["handle"] = 0 } 
			end
		end
	end,

	------------------------------------------------------
	-- .copy(file1,file2)
	--
	-- Copy file1 to file2 or if file2 doesn't exist, 
	-- copy file.name to file1.
	--
	-- *nil
	------------------------------------------------------
	["copy"] = function (file1,file2)
		local ff

		if not file2
		then
			ff = tabularize(default())
			gg = io.open(default(file1),'w+')
		else
			ff = tabularize(default(file1))
			gg = io.open(default(file2),'w+')
		end

		if type(ff) == 'table'
		 and type(gg) == 'userdata'
		 then
			for _,line in ipairs(ff)
			do
				-- Depending on buffer size, this can be written quickly.
				gg:write(tostring(line .. '\n'))
			end
			gg:flush() 
			gg:close()
		end
	end,

	------------------------------------------------------
	-- .write(content,filename) 
	--
	-- Write information to a file.
	--
	-- *nil (stupid not to return anything...)
	------------------------------------------------------
	["write"] = function (text, filename)
		save(text,default(filename))
	end,

	------------------------------------------------------
	-- .delete(filename) 
	--
	-- Delete a file.
	-- *bool
	------------------------------------------------------
	["delete"] = function (filename)
		return os.remove(default(filename))	
	end,

	------------------------------------------------------
	-- .rename(filename) 
	--
	-- Rename a file.
	-- Think...cuz we got pubs and privs.
	-- *bool
	------------------------------------------------------
	["rename"] = function (f1,f2)
		local old,new 
		if not f2
		then
			old,new = default(),default(f1)
		else
			old,new = default(f1),default(f2)
		end
		return os.rename(old,new)
	end,

	------------------------------------------------------
	-- .object(filename)
	--
	-- Load a file as an object.
	-- *table
	------------------------------------------------------
	["object"] = function (filename)
		------------------------------------------------------
		-- Objects and file handles.
		------------------------------------------------------
		local obj, fh
		local function f_req (file)
			local loader = ({loadfile( file )})
			return {
				["msg"] 		= loader[1],
				["errmsg"] 	= loader[2],
			}
		end

		------------------------------------------------------
		-- Search for files without a .lua extension first.
		------------------------------------------------------
		if (string.sub(filename,-4)) ~= ".lua"
		then
			fh = f_req(default(filename) .. ".lua")
			if fh.errmsg
			then
				response.send({500}, fh.errmsg)
				return false
			else	
				obj = fh.msg()
			end

		------------------------------------------------------
		-- Then search for files with a .lua extension.
		------------------------------------------------------
		else
			obj = loadfile(default(filename))()
		end

		if obj
		then
			return obj
		end
	end,

	------------------------------------------------------
	-- .totable(filename,r1,r2) 
	--
	-- Writes filename contents to a table.
	-- *table
	------------------------------------------------------
	["totable"] = function (filename,r1,r2)
		return tabularize(filename,r1,r2)
	end,

	------------------------------------------------------
	-- .asfunction(filename) 
	--
	-- Import file and execute as function. 
	------------------------------------------------------
	["asfunction"] = function (filename)
		-- protected exists for a reason...
		-- if public exec happens you're in trouble...
		return tabularize(default(filename))	
	end,
	
	------------------------------------------------------
	-- .tmp(filename)
	--
	-- Create a temporary file from some content. 
	--
	-- Buffering, splitting, checking and other fun
	-- can be done here.
	--
	-- *userdata
	------------------------------------------------------
	["tmp"] = function (content)
		return mktmp() -- I think I need the handle to process...
	end,

}

--dofile(path .. "debug/filesuite.lua")(f)
return f
