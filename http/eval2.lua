------------------------------------------------------
-- eval.lua
--
-- Creates an interface for crafting the response to
-- resource requests.
--
-- By this definition, E.links() does not belong here.
------------------------------------------------------

-- Include dependencies.
local request	  = {}	-- Table to store request model.
local err		  = {}	-- Table for different errors.
local priv		  = {}	-- Table for other things.

-- More setup.
local names = {}			-- Table of names only.
local evalx = {} 			-- An action besides inclusion is needed.

-- XHR needs a ton to work for some dumb reason...
local xhrt = {}			-- Table of modules that should only be 
								-- served partially via XMLHttpRequests.

------------------------------------------------------
-- href {}
--
-- Table to hold all hypertext reference formatting
-- data.
------------------------------------------------------
local href = {
   as      =  "string" ,			-- Define how links should be returned.
   url_root = { _d_ = "/" },		-- Relative path for links.
   class   = { _d_ = ""	},       -- Use a class with generated links.
   id      = { _d_ = false },	   -- Use ID's with generated links.
   string  = { _d_ = "" },			-- Use a custom string for generating links.
   subvert = { _d_ = {} },			-- Table for subverted stuff.
   group   = { _d_ = {} },			-- A group name or names.  Default.
   alias   = { _d_ = {} },       -- Set an alias.
--	src     = { _d_ = {} },       -- Where link reference names go.
}

------------------------------------------------------
-- xmlhttp {}
--
-- Table to hold XMLHttpRequest transport parameters.
------------------------------------------------------
local xmlhttp = {
	autobind = false,
	bounds = false,
	animate = false,
	show = false,
	hide = false,
	post = false,
	get = false,
	unique = false
}

------------------------------------------------------
-- eval {}
--
-- Table to hold elements used to evaluate the HTTP
-- request.
------------------------------------------------------
local eval = {
	level = 1,                 -- Should automatically be 1. 
	resources = false,			-- ?
	done = false,			      -- Change to true when eval_eval() is done. 
	fs_root = "/",					-- Serve relative to here?
	execution = { _d_ = {} },  -- Store execution blocks. 
	group = { _d_ = {} },		-- Set a place for resources.
	href = { _d_ = {} },		-- Set a place for resources.
	order = { "skel", "html" } -- Default order for finding files.
}

------------------------------------------------------
-- typecheck_me(x)
--
-- Instead of complex die.xtype() calls littered
-- through each of the functions, let's try working
-- through as much of the logic as possible here.
--
-- Notice that each table above has a default value
-- that matches the type that the modifying function
-- is supposed to receive. 
------------------------------------------------------



------------------------------------------------------
-- generate_href
--
-- Goes through a fairly long process to create
-- a hyperlink reference.
------------------------------------------------------

------------------------------------------------------
-- eval {}
--
-- Public functions for serving pages. 
------------------------------------------------------
return {
	------------------------------------------------------
	-- .default( term )
	--
	-- Set a default for our frame.
	-- *nil
	------------------------------------------------------
	default = function (term)
		request.default = term
	end,

	------------------------------------------------------
	-- .run( level, f )
	--
	-- Run a function according to a specific resource.
	--
	-- *string, *table, *number or *nil
	------------------------------------------------------
	nrun = function (level, f)
	-- run = function (level, f, map) -- Need a way to choose resource.
		local run_res 
		if type(f) == 'function'
		then
			if type(map) == 'string'
			then
				request.selection = "__" .. map .. "__"
			end
			run_res = table.copy( names[request.selection] or names ) 

			------------------------------------------------------
			-- Get the value only if it exists.
			------------------------------------------------------
			if data.url[level]
			 and is.value(data.url[level],run_res)
			then
				return f(data.url[level])
			elseif request.default
			then 
				return f(request.default)
			else
				return ""
			end
		end	
	end,

	------------------------------------------------------
	-- .run( level, f )
	--
	-- ...
	------------------------------------------------------
	run = function (level, f)
		-- Die if f is not a function.
		die.xtype(f, "function")

		-- Run some stuff.	
		if type(map) == 'string'
		then
			request.selection = "__" .. map .. "__"
		end
	
		-- ...			
		local run_res = table.copy( names[request.selection] or names ) 

		------------------------------------------------------
		-- Get the value only if it exists.
		------------------------------------------------------
		if data.url[level]
		 and is.value(data.url[level],run_res)
		then
			return f(data.url[level])
		elseif request.default
		then 
			return f(request.default)
		else
			return ""
		end
	end,

	------------------------------------------------------
	-- .set(t)
	--
	-- ...
	------------------------------------------------------
	set = function (t)
		-- Die if e isn't a table.
		die.xtype(t, "table", "E.set")

		-- We can do it a simple way here by iterating through 
		-- what's already there with a pairs()
		for k,v in pairs(t)
		do
			-- If v is a table, then you have grouped resources.
			if type(v) == 'table'
			then
				-- Create a new group for this key.
				eval.group[k] = {} 
				-- href.src[k] = {}

				-- Recursion would be nice.
				for kk,vv in pairs(v)
				do
					if type(vv) == 'string' 
					then
						-- Add this string to the new group. 
						eval.group[k][kk] = vv
				
						-- Add an href link.
						-- table.insert(href.group[k], vv)

					elseif type(vv) == 'function'
					then
						-- Add this string to the new group. 
						eval.group[k][kk] = vv
				
						-- Add an href link.
						-- table.insert(href.group[k], kk)

					elseif type(vv) == 'table'
					then
						die.xerror({
							fn = "E.set",
							msg = "%f does not support tables more than 1 level deep. "..
					 		"Please check the value at index [" .. kk .. "] within " ..
							"index [" .. k .. "] at table supplied to %f." 
						})
					elseif type(vv) == 'userdata' 
			 		 or type(vv) == 'number' 
			 		 or type(vv) == 'boolean' 
			 		 or type(vv) == 'nil'
					then
						die.xerror({
						-- at = (debug.traceback can retrieve where it occurred)
						-- propagate = n (go up the chain n times to get error) 
							fn = "E.set",
							tn = type(vv),
							msg = "%f cannot support tables with keys mapped to %t. "..
					 		"Please check the value at index [" .. kk .. "] within " ..
							"index [" .. k .. "] at table supplied to %f." 
						})
					end
				end
		
			-- If it's a string or function, you're asking for a page in the skel
			-- directory or defining what to run to get a payload.
			elseif type(v) == 'string' or type(v) == 'function'
			then
				-- Add this string to a default group. 
				table.insert(eval.group._d_, v)
	
				-- Also tell eval to make a link out of it.
--				table.insert(href.src._d_, k)

			-- Typecheck your table.
			elseif type(v) == 'userdata' 
			 or type(v) == 'number' 
			 or type(v) == 'boolean' 
			 or type(v) == 'nil'
			then
				die.xerror({
				-- at = (debug.traceback can retrieve where it occurred)
				-- propagate = n (go up the chain n times to get error) 
					fn = "E.set",
					tn = type(v),
					msg = "%f cannot support tables with keys mapped to %t. "..
					 "Please check the value at index [" .. k .. "] at %f." 
				})
			end
		end
	end,

	------------------------------------------------------
	-- .set(t)
	--
	-- Set up what routes we'd like to work with.
	--
	-- *nil
	------------------------------------------------------
	nset = function (e)
		------------------------------------------------------
		-- Do we have only one route scheme defined? 
		------------------------------------------------------
		request.block = {}
		if is.ni(e)
		then 
			table.insert(request.block,e)

		------------------------------------------------------
		-- Maybe we have multiple route schemes defined. 
		------------------------------------------------------
		elseif type(e) == 'table'
		 and not is.ni(e)
		then 
			for k,v in pairs(e)
			do
				request.block[k] = v
			end
		end

		------------------------------------------------------
		-- Run through the single table and seperate href
		-- and functions.
		------------------------------------------------------
		if is.ni(request.block) 
		 and table.maxn(request.block) == 1
		then
			for k,v in pairs( request.block[1] )
			do
				if type(k) == 'number'
				then
					table.insert(names,v)	
				else
					table.insert(names,k) -- Save the name as a reference.
					evalx[k] = v			 -- Save the executions in evalx
				end
			end

		------------------------------------------------------
		-- Break up multiple tables of routes.
		------------------------------------------------------
		else
			-- are should probably be replaced here with
			-- any and all.
			if are.members_of_type(request.block,'table')
			then
				for reqkey,reqtb in pairs( request.block )
				do
					------------------------------------------------------
					-- If they aren't all tables then something else is up.
					------------------------------------------------------
					local uniqkey = "__" .. reqkey .. "__"
					names[uniqkey] = {}
					evalx[uniqkey] = {}
					for k,v in pairs(reqtb)
					do
						if type(k) == 'number'
						then
							table.insert(names[uniqkey],v)	
						else
							-- Save the name as a reference.
							table.insert(names[uniqkey],k)

							 -- Save the executions in evalx
							evalx[uniqkey][k] = v
						end	-- type(k) == 'number'
					end -- for k,v in paris(reqtb) ...
				end -- for reqkey, reqtb
			else
				------------------------------------------------------
				-- This should be the condition we test for and the
				-- fallback if something else occurs.
				------------------------------------------------------
				for k,v in pairs( request.block )
				do
					if type(k) == 'number'
					then
						table.insert(names,v)	
					else
						table.insert(names,k) -- Save the name as a reference.
						evalx[k] = v			 -- Save the executions in evalx
					end
				end
			end -- if are.members
		end -- is.ni(request.block)
	end,


	------------------------------------------------------
	-- .links( map,reps )
	--
	-- Generate list of links from eval.  Typical behavior 
	-- just sets up a link map relative to root.  Adding [map] 
	-- to the mix will map links according to the map you've 
	-- supplied within E.set(t).
	-- 
	-- [map] is either string or table.
	--
	-- *string
	------------------------------------------------------
	nlinks = function (map,reps)
		local linkstr		-- Store our prepared links here.
		local linkframe 	-- <a href=x ... ></a>
		local linkreps		-- Number of times to repeat string replacement.
		local links			-- Store our links table here.
		local alias	= {}	-- Finally, put away any aliases.
		
		------------------------------------------------------
		-- Iterate through argument list and figure out what
		-- we want.
		------------------------------------------------------
		if type(map) == 'string'
		then
			request.selection = "__" .. map .. "__"

			if type(reps) == 'table'
			then
				linkframe = reps[1] or nil	
				linkreps  = reps[2] or nil
			end

		elseif type(map) == 'table'
		 and not reps	
		then
			linkframe = map[1] or nil	
			linkreps  = map[2] or nil
		end 

		------------------------------------------------------
		-- Save everything in our frame for links.
		------------------------------------------------------
		links = table.copy( names[request.selection] or names ) 

		------------------------------------------------------
		-- Check for things we don't want.
		------------------------------------------------------
		if request.subvert
	 	 and type(request.subvert) == 'table'
		then
			-- Work on singular resources.
			if is.ni(request.subvert) then
				for _,key in ipairs(request.subvert) do
					table.remove(links, table.index(links,key))	
				end
			
			-- Work on multi resources.  If [map] isn't
			-- a string, then we did something wrong.  
			-- Error out because eval doesn't really know
			-- what you want.
			else
				if type(map) == 'string' 
				then 	
					if is.key(map,request.subvert) 
					then
						for key, value in pairs(request.subvert[map]) 
						do
							table.remove(links, table.index(links,value))	
						end
					end
				else
					response.abort({500},[[First argument to .links() 
						must be a string.]])
				end
			end

		elseif request.subvert
	 	 and type(request.subvert) == 'string'
		 then
			table.remove(links, table.index(links, request.subvert))
		end

		------------------------------------------------------
		-- Set aliases.
		------------------------------------------------------
		if request.alias
		then
			for _,value in ipairs(links)
			do 
				if request.alias[value] then
					alias[value] = request.alias[value]
				end
			end
		end

		------------------------------------------------------
		-- Finally output links.
		------------------------------------------------------
		local ls,c = {},1
		for _,key in ipairs(links) 
		do
			------------------------------------------------------
			-- Slightly special link scheme needed.
			------------------------------------------------------
			if linkframe 
			 and type(linkframe) == 'string'
			 and not linkreps 
			 then
				if type(xhrt) == 'table' and is.value(key,xhrt) then
					linkstr = string.format('<a id="%s" href="%s/%s">%s</a>',
						"__" .. key, linkframe, key, alias[key] or key)
				else 
				linkstr = string.format('<a href="%s/%s">%s</a>',
					linkframe, key, alias[key] or key)
				end

			------------------------------------------------------
			-- Custom link schemes needed.
			------------------------------------------------------
			elseif linkframe 
			 and type(linkreps) == 'number' 
			then
				local keys = {}
				if linkreps > 1
				then
					for v=1,( linkreps - 1 )
						do keys[v] = key end 
				end

				-- How do we catch error and die?
				table.insert(keys, alias[key] or key)
				linkstr = string.format(linkframe,unpack(keys))
			
			------------------------------------------------------
			-- No special link schemes needed.
			------------------------------------------------------
			else 
				if type(xhrt) == 'table' and is.value(key,xhrt) 
				then
					linkstr = string.format('<a id="%s" href="/%s">%s</a>',
						"__" .. key, key, alias[key] or key)
				else
				linkstr = string.format('<a href="/%s">%s</a>',
					key, alias[key] or key)
				end
			end
			ls[c] = linkstr
			c = c + 1
		end
		
		if request.selection then
			request.selection = nil	end	-- Reset link schemes
		return table.concat(ls,'\n')
	end,

	------------------------------------------------------
   -- .links( )
	-- 
	-- Flexible link output for resources defined with 
	-- E.set(). Takes a table with arguments.
	--
	-- Example and Usage:
	--
	-- <pre>
	-- E.links({
	--    as      = [table, string] 	-- Output link list as table or string.
	--    root    = [string]        	-- Creates href relative to [root].
	--    class   = [string]       	-- A class name for each.
	--    id      = [bool]          	-- Use the resource name as an id.
	--    string  = [string]        	-- Use this string as the link dump.
	--    subvert = [table, string] 	-- Do not include these resources as links.
	--    group   = [string]        	-- Choose a resource group if many have
	--                             	-- been specified.
	--    alias   = [table]         	-- Choose which resources to serve
	--                             	-- with an entirely different link name.
	-- })
	-- </pre>
	--
	-- *nil
	------------------------------------------------------
	links = function (t)
		-- Create a blank table.
		local tt = {}

		-- If [t] is blank, then just output the links 
		-- as a string.
		if not t
		then
			-- Shut down if E.set() was not called yet.
			die.xempty(eval.group._d_)
			
			-- Output a very simple link list.
			for k,v in ipairs( href.group._d_ )
			do
				linkstr = string.gsub('<a href="' .. href.url_root._d_ .. '%s">%s</a>', '%%s', v)
				table.insert(tt, linkstr) 
			end

		-- If [t] is a string, then auto-output the links
		-- for the group thrown in [t], dying with an error
		-- if that group does not exist.
		elseif type(t) == 'string'
		then
			-- Shut down if the group asked for does not exist.
			die.xnil(eval.group[t])
			
			-- Output a very simple link list.
			for k,v in ipairs( href.group[t] )
			do
				linkstr = string.gsub('<a href="' .. href.url_root._d_ .. '%s">%s</a>', '%%s', v)
				table.insert(tt, linkstr) 
			end

		-- If [t] is a table, then you'll be handling more complex
		-- functionality.
		elseif type(t) == 'table'
		then
			-- See below for a short explanation.
			--
			-- datatypes = {
			-- [k] = {  		-- The argument in t with the values you want to extract.
			-- 	[it] = []	-- The datatype expected for this argument.
			-- 	[ig] = []   -- If datatype of [it] is a table, and a group has been
			-- 	            -- selected, then [ig] is the datatype expected of the 
			-- 	            -- value that the group key corresponds to.
			-- 	[iv] = []   -- If datatype of [it] is a table, and no group has been
			-- 	            -- selected, then [iv] is the datatype expected of each
			-- 	            -- index in the table.
			--	}}
			local datatypes = {
				as = { it = "string" },
				url_root = { 
					it = {"string", "table"}, 
					ig = "string" },
				class = { 
					it = {"string", "table"}, 
					iv = { "string", "table" }, 
					ig = { "string", "table" }},
				id = { 
					it = {"boolean", "table"}, 
					ig = "boolean" },
				string = { 
					it = {"string", "table"}, 
					ig = "string" },
				subvert = { 
					it = {"string", "table"}, 
					ig = { "string", "table" }},
				group = { 
					it = {"string", "table"}, 
					ig = "string" },
				alias = { 
					it = "table", 
					ig = "string" }
			}

			-- Get the keys from [t]
			t = table.retrieve(table.keys(href), t)	-- Clear group, b/c issues will occur...

			-- Check if the group exists.
			if t and t.group
			then
				-- Do a quick type check.
				-- die.xtype(t.group, { "string", "table" }, "E.links")
				if type(t.group) ~= "string" and type(t.group) ~= "table"
				then
					die.xerror({
						fn = "E.links",
						on = { "string", "table" },
						msg = "Value at index [group] in %f must be either a %o."
					})
				end

				if type(t.group) == 'table'
				then
					-- Move through each making sure they exist in set.
					for xx,yy in pairs(t.group)
					do 
						-- Must be numerically indexed.	
						if type(xx) == 'string'
						then
						die.xerror({
							fn = "E.links",
							msg = "Table supplied at index [group] in %f must be a " ..
						 		"numerically indexed table."
						})
						end

						-- Check that a string was given.
						-- die.xtype(yy, "string", "E.links")
						if type(yy) ~= "string"
						then
						die.xerror({
							fn = "E.links", tn = type( yy ),
							msg = "Argument at index ["..xx.."] at index " ..
							"[group] in %f is of incorrect %t."
						})
					 	end

						-- Die if the group does not exist.
						if not is.key(yy, eval.group)
						then
						die.xerror({
							fn = "E.links",
							msg = "Group name '" .. xx .. "' does not "
							.. "exist at %f."
						})
						end
					end

				-- Check if the string is actually a group member.
				else
					if not is.key(t.group, href.group)
					then
						die.xerror({
							fn = "E.links",
							msg = "Group name '" .. t.group .. "' does not "
							.. "exist at %f."
						})
					end
				end
			end -- if t and t.group

			-- Handle everything else. 
			for _,v in ipairs({
				'as','url_root','class','id','string','subvert','alias'	
			})
			do
				-- Short name.
				local vararg = t[v] or href[v]["_d_"]
				local default = href[v]["_d_"]

				-- Die if "outer" argument does not match.
				-- die.xtype(vararg, datatypes[v]["it"])

				-- Depending on type of vararg, evaluate inner and set.
				-- There is no group negotiation needed here.
				if type(vararg) == "string" or type(vararg) == "boolean"
				then
					default = vararg 

				-- Do some group negotiation if it's a table.
				elseif type(vararg) == "table"
				then
					-- Run checks with supplied groups.
					if t and t.group
					then
						-- Cycle through the other indices. 
						for xx,yy in pairs(vararg)
						do 
							-- Check for numerically indexed tables.
							if is.value(v,{"url_root","id","string","alias"}) 
						 	 and type(xx) == 'number'
							then
								die.xerror({
									fn = "E.links", 
									msg = "Received the wrong table type at index"
								 	.. " [" .. v .. "] in %f."
								})
							end

							-- Otherwise, set up the table you've been given. 
							-- Still have to run each one.
							if is.value(v, {"url_root", 'string'})
							then
								-- Set the url root for a group.
								-- Replace all this mess with die.xtype() calls.
								if type(yy) ~= "string" then
								die.xerror({ fn = "E.links", tn = type(yy), 
									msg = "Received %t at index ["..v.."] at %f. Expected <i>string</i>." }) 
								end
								href.url_root[xx] = yy

							elseif v == 'id'
							then
								-- Set the url root for a group.
								-- Replace all this mess with die.xtype() calls.
								if type(yy) ~= "boolean" then
								die.xerror({ fn = "E.links", tn = type(yy), 
									msg = "Received %t at index ["..v.."] at %f. Expected <i>boolean</i>." }) 
								end
								href.id[xx] = yy

							elseif v == "class"
							then
								-- Replace all this mess with die.xtype() calls.
								if type(yy) ~= "string" and type(yy) ~= "table" then
								die.xerror({ fn = "E.links", tn = type(yy), 
									msg = "Received %t at index ["..xx.."] at index ["..v.."] at %f." }) end

								if type(yy) == 'string'
								then
									href.class[xx] = yy
								elseif type(yy) == 'table'
								then
									-- is.ni seems to be failing...  let's try anyway.
									if not is.ni(yy) 
									then
										die.xerror({
											fn = "E.links",
											msg = "Incorrect table type received at index ["..xx.."] " ..
												"at index ["..v.."] in %f."
										})
									else
										href.class[xx] = table.concat(yy," ")
									end
								end

							elseif v == "subvert"
							then
								-- Replace all this mess with die.xtype() calls.
								if type(yy) ~= "string" and type(yy) ~= "table" then
								die.xerror({ fn = "E.links", tn = type(yy), 
									msg = "Received %t at index ["..xx.."] at index ["..v.."] in %f." }) end
			
								-- Pop these from whatever you're generating links on.
								-- href.url[xx] = yy

							elseif v == "alias"
							then
								-- Replace all this mess with die.xtype() calls.
								if type(yy) ~= "string" and type(yy) ~= "table" then
								die.xerror({ fn = "E.links", tn = type(yy), 
									msg = "Received %t at index ["..xx.."] at index ["..v.."] in %f." }) 
								end
			
								-- Check that the group name for the alias exists?
								--[[
								if 
								die.xerror({ fn = "E.links", tn = type(yy), 
									msg = "Received %t at index ["..xx.."] at index ["..v.."] in %f." }) 
								end

								-- Should also check that the resource name exists?
								die.xerror({ fn = "E.links", tn = type(yy), 
									msg = "Received %t at index ["..xx.."] at index ["..v.."] in %f." }) 
								end
								--]]
		
								-- Finally make a table for these aliases if there isn't one and save each.
								if not href.alias[xx] then href.alias[xx] = {} end
								for akey,aval in pairs(yy) do href.alias[xx][akey] = aval end
							end
						end

					-- Not setting up any groups, so a lot of these will be wrong if
					-- a table has made it there.
					else
						-- Check for numerically indexed tables.
						if not is.value(v,{"class", "alias", "subvert"}) 
						then
							die.xerror({
								fn = "E.links", tn = type(t[v]),
								msg = "Received %t at index ["..v.."] at %f.  Expected non-table value."
							})
						end

						-- Cycle through the other indices. 
						for xx,yy in pairs(vararg)
						do 
							-- Otherwise, set up the table you've been given. 
							-- Still have to run each one.
							if v == "class"
							then
								-- Replace all this mess with die.xtype() calls.
								if type(yy) ~= "string" and type(yy) ~= "table" then
								die.xerror({ fn = "E.links", tn = type(yy), 
									msg = "Received %t at index ["..v.."] at %f." }) end

								if type(yy) == 'string'
								then
									href.class._d_ = yy
								elseif type(yy) == 'table'
								then
									-- is.ni seems to be failing...  let's try anyway.
									if not is.ni(yy) 
									then
										die.xerror({
											fn = "E.links",
											msg = "Incorrect table type received at index ["..xx.."] " ..
												"at index ["..v.."] in %f."
										})
									else
										href.class._d_ = table.concat(yy," ")
									end
								end

							elseif v == "subvert"
							then
								-- Replace all this mess with die.xtype() calls.
								if type(yy) ~= "string" and type(yy) ~= "table" then
								die.xerror({ fn = "E.links", tn = type(yy), 
									msg = "Received %t at index ["..xx.."] at index ["..v.."] in %f." }) end
			
								-- Pop these from whatever you're generating links on.
								-- href.url[xx] = yy

							elseif v == "alias"
							then
								-- Replace all this mess with die.xtype() calls.
								if type(yy) ~= "string" and type(yy) ~= "table" then
								die.xerror({ fn = "E.links", tn = type(yy), 
									msg = "Received %t at index ["..xx.."] at index ["..v.."] in %f." }) 
								end
			
								-- Check that the group name for the alias exists?
								--[[
								if 
								die.xerror({ fn = "E.links", tn = type(yy), 
									msg = "Received %t at index ["..xx.."] at index ["..v.."] in %f." }) 
								end

								-- Should also check that the resource name exists?
								die.xerror({ fn = "E.links", tn = type(yy), 
									msg = "Received %t at index ["..xx.."] at index ["..v.."] in %f." }) 
								end
								--]]
		
								-- Finally make a table for these aliases if there isn't one and save each.
								for akey,aval in pairs(yy) 
								do 
									href.alias._d_[akey] = aval 
								end
							end -- if v == 'class'
						end -- for xx,yy in pairs(vararg)
					end -- if t and t.group
				end
			end
	
		-- Catch bad arguments to E.links()
		else
			die.xtype(t, { "string", "table" })
		end

		-- Finally, we're ready to present the links, but there's more to be done.
		-- Has XMLHttp been requested?

		-- Iterate through each group asked for, if none, then iterate through _d_
		local group = t.group or eval.group
		local links = {}
		for __,v in ipairs(group) -- href.group[href.group] )
		do
			-- Move through strings doing replacements.
			if t and t.string and t.string[v]
			then
				for __,v in ipairs(group) -- href.group[href.group] )
				do
					-- Will use a custom syntax.
					for __,vv in ipairs(eval.group[v])
					do
						t.string[v] = string.gsub(tostring(t.string[v]), '%%s', vv)
						table.insert(links, t.string[v])   -- Use either string group.
					end
				end

			-- Move through the rest.
			else
				for __,vv in ipairs(eval.group[v])
				do
			---[[
				table.insert(links, table.concat({
					'<a href=',  															-- Start the tag.
					'"' .. tostring(href.url_root[v] or href.url_root._d_),	-- Relative root. 
					vv .. '"',                                       			-- Resource name.
					string.set(href.class[v] or href.class._d_," class"), 	-- Class name.
					(function ()															-- ID name.
						if href.id then return string.set(vv, " id") end 
					end)(),
					">",																		-- Close the opening tag.
--					href.alias[v] or vv,                      					-- Resource name or alias.
					vv,                      											-- Resource name or alias.
					"</a>\n" 																-- Close the entire tag.
				}))	
			--]]
				end 	
			end
		end
			

		local as = t.as or href.as
		
		-- A way to do the below in one line.
		-- If as were a string, then return table.concat(links, "\n")
		-- return on.mtype(as, { string = table.concat(links,"\n"), table = links })
		-- If as evaluates to "string", then return table.concat(links, "\n")
		-- return on.meval(as, { string = table.concat(links,"\n"), table = links })
		-- If as is true then return table.concat(links, "\n")
		-- return on.mbool?(as, table.concat(links,"\n"), links )
		if as == 'string' 
		then 
			return table.concat(links,"\n")
		else 
			return links
		end
	end,

	-- Return the links, because it's ugly.
	plinks = function (t)
	end,

	------------------------------------------------------
	-- .include(n, name)
	--
	-- Include resource at [n] as name.  Similar to 
	-- redefining pg.pages.
	--
	-- *nil
	------------------------------------------------------
	include = function (n, name)
	end,

	------------------------------------------------------
	-- .xmlhttp()
	--
	-- Bind resources to XMLHttpRequests. 
	-- 
	-- Example and Usage:
	--
	-- <pre>
	-- E.xmlhttp ({
	-- 	autobind = {	-- Choose to bind resources to ID's or classes...
	-- 		[x] = [string or table],
	-- 		[y] = [string or table],
	-- 	},
	-- 	bounds   = {	-- Define "aliases" for elements to bind to.
	-- 		[x] = ".fool", -- The class .fool can be referenced by [x] now.
	-- 		[y] = "#mega", -- The ID mega can be referenced by [y] now.
	-- 	},
	-- 	animate  = {   -- Bind an animation to some elements.
	-- 		[x] = [number or table],
	-- 		[y] = 300 or { start = 300, end = 300}
	-- 	},
	--  [show,hide] = [number or table],  -- Set show and hide speed 
	--  [show,hide] = 300 -- or           -- for elements.
	--  [show,hide] = { 
	-- 		[x] = 300
	-- 	},
	-- 	post 	= [string or table]
	-- 	get = [string or table]
	-- })
	-- </pre>
	--
	-- *nil
	------------------------------------------------------
	xmlhttp = function (t)
	end,

	------------------------------------------------------
	-- .fail
	--
	-- Fail if certain resources are not found, instead
	-- of passing the resource name to a script defined
   -- in pg.pages.
	-- 
	-- Example and Usage:
	-- <pre>
	-- E.fail({       -- Fail with a 404 if resources at n are not found.
	-- 	level 	 = [number]          -- at level [number]
	-- 	resources = [string, table]   -- If these resources are received,
   --                                  -- then it's ok.
	-- 	group 	 = [string]          -- Only fail with unavailable 
   --                                  -- resources from this group.
	-- 	message   = [string]          -- Choose a different message for 
   --                                  -- the default 404 page.
	-- 	resource  = [string]          -- Choose a particular resource 
   --                                  -- for serving 404 pages.
	-- 	                              -- Keep in mind that pg can also 
   --                                  -- serve custom error pages.
	-- })  
	-- </pre>
	--
	-- *nil            
	-----------------------------------------------------
	fail = function (t)
	end,

	------------------------------------------------------
	-- .serve(int,xpath)
	--
	-- Serves resource requested.
	-- No (int) means serve a primary resource.  int can be
	-- 2,3 or 4 -- indicating how deep you want Pagan to
	-- delve into the url structure.
	--
	-- Does not serve private data.
	--
	-- *nil or *string
	------------------------------------------------------
	serve = function (int,xpath)
		------------------------------------------------------
		-- Check our arguments; setup items and variables. 
		------------------------------------------------------
		if type(xpath) == 'table'
		 and not xpath[1]
		then
			request.xpath = xpath[2] or ""

		elseif type(xpath) == 'table'
		then
			request.selection = "__" .. xpath[1] .. "__"
			request.xpath = xpath[2] or ""

		elseif type(xpath) == 'string'
		then 
			request.selection = "__" .. xpath .. "__"
		end

		------------------------------------------------------
		-- snames = Final table of resources to choose from.
		-- sevalx = Table of functions. 
		------------------------------------------------------
		local int = int or table.maxn(data.url)
		local dd = data.url[int]
		local snames = names[request.selection] or names
		local sevalx = evalx[request.selection] or evalx

		------------------------------------------------------
		-- local find_file (filename)
		-- 
		-- Find [filename] by extension.
		-- *string
		------------------------------------------------------
		local function find_file( filename )
			for _,inc in ipairs({"skel","html"})
			do
				local FF = add[inc]( filename )
				if FF then
					return FF or "" 
				end
			end
		end

		------------------------------------------------------
		-- local x_or_not( xblock )
		--
		-- Execute or present string returned by [xblock] 
		-- either by using XMLHttpRequest or a typical return.
		--
		-- *string or *nil
		------------------------------------------------------
		local function x_or_not( req, xblock )
			-- Is this resource autobound to JS?	
			if type(xhrt) == 'table' 
			 and is.value(req,xhrt) 
			then
				response.abort({200}, xblock)

			-- If not serve like normal.
			else
				return xblock
			end
		end

		------------------------------------------------------
		-- Evaluate whatever code is tied to the function.
		------------------------------------------------------
		if is.value(dd, snames)
		 and is.key(dd, sevalx)
		then
			--return sevalx[dd]() or ""
			return x_or_not( dd, sevalx[dd]() ) or nil

		------------------------------------------------------
		-- Do a file include.
		------------------------------------------------------
		elseif is.value(dd, snames)
		then
			if request.xpath and type(request.xpath) == 'string' then
			--	return find_file( string.format("%s/%s",request.xpath, dd) )
				return x_or_not( request.xpath, 
					find_file( string.format("%s/%s", request.xpath, dd) )) or nil
			else
			--	return find_file( dd ) end
				return x_or_not( dd, find_file( dd )) or nil 
			end
			
		------------------------------------------------------
		-- If nothing is satisfied, let E.serve handle it.
		-- 
		-- The XHR handling should happen here for fallback 
		-- support.
		------------------------------------------------------
		else
			if request.err
			then
				return ({
					string = function ()
						return request.err
					end,
					["function"] = function ()
						return request.err()
					end,
				})[type(request.err)]()

			else
				return ({
					string = function ()
						if is.value(request.default, snames)
						 and is.key(request.default, sevalx)
						then 
							return sevalx[request.default]()
	
						elseif is.value(request.default, snames) 
						then 
							return find_file ( request.default ) 
						end
					end,
					["function"] = function ()
						return request.default()
					end,
					["nil"] = function ()
						response.abort({500},[[No default request 
							specified for method .serve()]])
					end,
				})[type(request.default)]()
			end	-- if.request.err
		end
	end,
}
