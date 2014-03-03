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
   as      	=  "string" ,				-- Define how links should be returned.
   url_root = { ["_d_"] = "/" },		-- Relative path for links.
   class   	= { ["_d_"] = ""	},  	-- Use a class with generated links.
   id      	= { ["_d_"] = false },  -- Use ID's with generated links.
   string  	= { ["_d_"] = "" },		-- Use a custom string for generating links.
   subvert 	= { ["_d_"] = {} },		-- Table for subverted stuff.
   group   	= { ["_d_"] = {} },		-- A group name or names.  Default.
   alias   	= { ["_d_"] = {} },     -- Set an alias.
}

------------------------------------------------------
-- xmlhttp {}
--
-- Table to hold XMLHttpRequest transport parameters.
------------------------------------------------------
local xmlhttp = {
	-- Binding 
	autobind = { ["_d_"] = false },	-- Define each item that will dump resources at a location.
	bind 		= { ["_d_"] = false },	-- Bind resources to events. 

	-- Animation
	animate 	= { ["_d_"] = false },	-- Use basic animation when doing stuff.
	hide 		= { ["_d_"] = false },
	show 		= { ["_d_"] = false },

	-- Publisher-subscriber
	listen 	= { ["_d_"] = false },	-- Set up a publisher-subscriber system with resources.

	-- HTTP Requests
	post 		= { ["_d_"] = false },  -- POST something over XMLHttp.
	get 		= { ["_d_"] = false },  -- GET something via XMLHttp.
	head     = { ["_d_"] = false },  -- Make HEAD request via XMLHttp.

	-- Frontend / Backend Interaction
	shuttle  = { ["_d_"] = false },  -- Send something in the backend to the frontend.
	validate = { ["_d_"] = false },  -- Validate some area of input fields.
}


------------------------------------------------------
-- xmlhttp_settings {}
--
-- One-time settings for XMLHttp requests.
------------------------------------------------------
local xmlhttp_settings = {
	-- Settings
	unique 		= false, -- Use unique identifiers as classes.
	inline 		= false, -- Use inline styles instead of raw Javascript to locate elements.
	namespace   = "",  	-- Set up a different namespace for classes.
	wait 			= false, -- Wait until a response is received before moving further.
	dump 			= false, -- Dump generated Javascript as the result of an XMLHttp call.
	dump_to  	= "", -- Dump generated Javascript as the result of an XMLHttp call to file.
}

------------------------------------------------------
-- eval {}
--
-- Table to hold elements used to evaluate the HTTP
-- request.
------------------------------------------------------
local eval = {
	level 		= 1,              	-- Should automatically be 1. 
	resources 	= false,					-- ?
	done 			= false,			   	-- Change to true when eval_eval() is done. 
	fs_root 		= "/",					-- Serve relative to here?
	execution 	= {["_d_"] = {} },  	-- Store execution blocks. 
	group 		= {["_d_"] = {} },	-- Set a place for resources.
	href 			= {["_d_"] = {} },	-- Set a place for resources.
	order 		= {"skel","html"},	-- Default order for finding files.
	xmlhttp 		= {["_d_"] = {}}  	-- Which groups get XMLHttp requests?
}

------------------------------------------------------
-- js_dump str
--
-- A large string that will hold the contents of 
-- a script used to generate XMLHttp and basic 
-- Javascript scaffolding. 
------------------------------------------------------
local js_dump = {}

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
	-- Set the E module.
	------------------------------------------------------
	set = function (t)
		-- Die if t isn't a table.
		die.xtype(t, "table", "E.set")

		-- Iterate through t.
		for k,v in pairs(t)
		do
			-- 
			if type(k) == 'string'
			then
				-- Both functions and strings can be executed upon.
				if type(v) == 'function' or type(v) == 'string'
				then
					table.insert(eval.group._d_, k)	-- Add the name only to eval.group
					eval.execution._d_[k] = v			-- Reference function v with k

				-- Evaluate the differences in tables.
				elseif type(v) == 'table'
				then
					eval.group[k] = {} 		-- Create a new link group for this key.
					eval.execution[k] = {}	-- Create a new execution block for this key. 

					-- Cycle through the values in the group's table. 
					for kk,vv in pairs(v)
					do
						if type(kk) == 'string'
						then
							if type(vv) == 'string' or type(vv) == 'function'
							then
								-- Add this string to the new group. 
								table.insert(eval.group[k], kk)
								eval.execution[k][kk] = vv

							elseif type(kk) == 'number'
							then
								-- v must always be a string, or bad shit will happen.
								if type(vv) == 'string'
								then
									table.insert(eval.group[k], vv)
								else
									die({fn = "E.set", tn = "string", 
										msg = "Expected %t at index ["..kk.."] at " .. 
										"index ["..k.."] in %f."})
								end
						
							elseif type(vv) == 'table'
							then
								die.xerror({
									fn = "E.set",
									msg = "%f does not support tables more than 1 level deep. "..
									"Please check the value at index [" .. kk .. "] within " ..
									"index [" .. k .. "] at table supplied to %f." 
								})
							else
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

						elseif type(kk) == 'number'
						then
							-- v must always be a string, or bad shit will happen.
							if type(vv) == 'string'
							then
								-- Add this string to a default group. 
								table.insert(eval.group[k], vv)
							else
								die({fn = "E.set", tn = "string", 
									msg = "Expected %t at index ["..k.."] at %f."})
							end

						else
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
				else
					die({ fn = "E.set", msg = "Expected %o at index ["..k.."] in %f." })
				end

			-- Evaluate numbers.
			elseif type(k) == 'number'
			then
				-- v must always be a string, or bad shit will happen.
				if type(v) == 'string'
				then
					-- Add this string to a default group. 
					table.insert(eval.group._d_, v)
				else
					die({fn = "E.set", tn = "string", 
						msg = "Expected type string at index ["..k.."] at %f. Got %t."})
				end
			end
		end
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

		-- Copy defaults
		local defaults = table.clone(href) 

		-- If [t] is blank, then output the links 
		-- as a string.
		if not t
		then
			-- Shut down if E.set() was not called yet.
			die.xempty(eval.group._d_)
			
			-- Output a very simple link list.
			for k,v in pairs( eval.group._d_ )
			do
				linkstr = string.gsub(
					'<a href="' .. href.url_root._d_ .. '%s">%s</a>', '%%s', v)
				-- check if v is a string, if so, reject. 	
				-- table.insert(tt, tostring(k) .. ": "..  tostring(v)) 
				table.insert(tt, linkstr)
			end

			-- Return the links.
			return table.concat(tt)

		-- If [t] is a string, then output the links for the 
		-- group represented by that string. Dying with an 
		-- error if that group does not exist.
		elseif type(t) == 'string'
		then
			-- Shut down if the group asked for does not exist.
			die.xnil(eval.group[t])
			
			-- Output a very simple link list.
			for k,v in ipairs( eval.group[t] )
			do
				linkstr = string.gsub(
					'<a href="' .. href.url_root._d_ .. '%s">%s</a>', '%%s', v)
				table.insert(tt, linkstr) 
			end

			-- Return the links.
			return table.concat(tt)

		-- If [t] is a table, then you'll be handling more complex
		-- functionality.
		elseif type(t) == 'table'
		then
			-- Refer to interface/extension/shuffler.lua for more on
			-- this big baby of a table.
			local validation = {
				-- Handle classes.
				class = { 
					datatypes = { "string", "atable", "ntable" }, 
					_string = function (x)
						href.class["_d_"] = x
						return false
					end,
					_atable = function (x)
						for xx,yy in pairs(x) do
							if is.value(xx, table.keys(eval.group)) then
								if type(yy) == 'table' and is.ni(yy) then
									href.class[xx] = table.concat(yy," ")
								elseif type(yy) == 'string' then
									href.class[xx] = yy
								end
							end
						end	
						return false 
					end,
					_ntable = function (x) -- Are the typechecks done here?
						if is.ni(x) then
							href[v]["_d_"] = table.concat(x," ")
						end
						return false 
					end,
				},

				url_root = { 
					datatypes = { "string", "atable" },
					_string = function (x)
						href.url_root["_d_"] = x
					end,
					_atable = function (x) 
						for xx,yy in pairs(x) do
							if is.value(xx, table.keys(eval.group)) then
								href.url_root[xx] = yy 
							end
						end
					end,
				},

				id = { 
					datatypes = { "atable", "boolean" },
					_boolean = function (x) 
						href.id["_d_"] = x 
					end,
					_atable = function (x)
						for xx,yy in pairs(x) do
							if is.value(xx, table.keys(eval.group)) then
								if type(yy) == "boolean" then
									href.id[xx] = yy 
								end
							end
						end
					end,
				},

				string = { 
					datatypes = { "string", "atable" },
					_string = function (x)
						href.string["_d_"] = x 
					end,
					_atable = function (x) 
						for xx,yy in pairs(x) do
							if is.value(xx, table.keys(eval.group)) then
								href.string[xx] = yy 
							end
						end
					end,
				},

				subvert = { 
					datatypes = { "string", "atable", "ntable" }, 
					_string = function () 
					end,
					_table = function () 
					end,
				},

				alias = { 
					datatypes = "atable", 
					_atable = function () 
					end,
				},
			}
			
         ------------------------------------------------------
			-- Get the keys from [t]
         ------------------------------------------------------
			t = table.retrieve(table.keys(href), t)

         ------------------------------------------------------
			-- Check if the group exists, and set something for
			-- our final link output loop.
         ------------------------------------------------------
			local groupnames
			if t and t.group
			then
				-- Do a quick type check.
				-- die.xtype(t.group, { "string", "table" }, "E.links")
				if type(t.group) ~= "string" and type(t.group) ~= "table"
				then
					die.xerror({ fn = "E.links", on = { "string", "table" },
						msg = "Value at index [group] in %f must be either a %o." })
				end

				if type(t.group) == 'table'
				then
					-- Move through each making sure they exist in set.
					for xx,yy in pairs(t.group)
					do 
						-- Must be numerically indexed.	
						if type(xx) == 'string'
						then
							die.xerror({ fn = "E.links",
								msg = "Table supplied at index [group] in %f " ..
									"must be a numerically indexed table."
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
					if not is.key(t.group, eval.group)
					then
						die.xerror({
							fn = "E.links",
							msg = "Group name '" .. t.group .. "' does not "
							.. "exist at %f."
						})
					end
				end
				groupnames = t.group -- or eval.group
			else
				groupnames = { "_d_" }
			end -- if t and t.group

         ------------------------------------------------------
         -- Process each of the members below that were part 
         -- of the table in [t].
         ------------------------------------------------------
			local aa = {}
			for xxnn,v in ipairs({
				"class", "url_root", "id","string" -- ,"subvert","alias"	
			})
			do
				if t[v]
				then
					shuffle(validation, t[v], v, "E.links")
				end
			end

			local links = {}
			for __,v in ipairs(groupnames) -- href.group[href.group] )
			do
				-- Move through strings doing replacements.
				if t and t.string and t.string[v]
				then
					-- Will use a custom syntax.
					for __,vv in ipairs(eval.group[v])
					do
						new_string = string.gsub(tostring(t.string[v]), '%%s', vv)
						table.insert(links, new_string) 
					end

				-- Move through the rest.
				else
					for __,vv in ipairs(eval.group[v])
					do
					table.insert(links, table.concat({
						'<a href=',    -------------------------------------------- Start the tag.
						'"' .. tostring(href.url_root[v] or href.url_root._d_), --- Relative root. 
						vv .. '"',     -------------------------------------------- Resource name.
						-- string.set(href.class[v] or href.class._d_," class"), ----- Class name.
						-- " class=" .. tostring(href.class[v] or href.class._d_),
						string.set(href.class[v] or href.class._d_, " class"), 
						(function ()															-- ID name.
							if href.id[v] or href.id._d_ then 							--
								return string.set(vv, " id")								--
							else return "" end     											-- 
						end)(),                                                  --
						">",           -------------------------------------------- Close the opening tag.
				--		href.alias[v][vv] or vv, ---------------------------------- Resource name or alias
						vv,            -------------------------------------------- Resource name only.
						"</a>\n"       -------------------------------------------- Close the entire tag.
					}))	
					end -- for __,vv in ipairs(eval.group[v])
				end -- if t and t.string and t.string[v]
			end -- for __,v in ipairs(group)

			-- My processing is done.
			href = defaults		-- Reset to defaults.
--			  response.abort({200}, table.as_string(defaults["class"]))
			local as = t.as or href.as
			if as == 'string' 
			then 
				return table.concat(links,"\n")
			else 
				return links
			end
	
		-- Catch bad arguments to E.links()
		else
			die.xtype(t, { "string", "table" })
		end -- if not t 
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
		if t
		then
			------------------------------------------------------
			-- Pull each of the parameters out. 
			------------------------------------------------------
			
			------------------------------------------------------
			-- Start the Javascript dump.
			------------------------------------------------------
			table.insert(js_dump, '<script type="text/javascript">')

			------------------------------------------------------
			-- arrayify(t, name)
			--
			-- Store in [name] all elements in [t].	
			--
			-- *string
			------------------------------------------------------
			local function arrayify( t, name ) 
				local js = {}
				local rsrc = "var " .. name .. " = [" 
				for _,v in ipairs(t) 
				do
					-- Should I be chekicing if this is the right table type?
					-- 
					if type(v) ~= "string"
					then
						die.xerror({
							fn = "xmlhttp",
							msg = "local function <i>arrayify()</i> expects strings"
							 .. " within it's first argument in %f"
						})
					end 
					table.insert(js, "'" .. v .. "'")
				end 

				return table.concat( {rsrc, table.concat(js,","), "];"} )
			end

			------------------------------------------------------
			-- Set up all the datatypes.
			------------------------------------------------------
			local datatypes = {
				autobind = {
					"atable", 
					{ "string", "table" }, 
					"string" },
				animate = {
					{ "atable", "boolean" }, 
					{ "ntable", "string", "boolean" }, 
					"string" },
				hide = {
					{ "atable", "number" }, 
					{ "atable", "number" }, 
					"number" },
				show = {
					{ "atable", "number" }, 
					{ "atable", "number" }, 
					"number" },
			}

			------------------------------------------------------
			-- function () end
			------------------------------------------------------
			local functions = {
				autobind = function (x) end,
				animate = function (x) end,
				hide = function (x) end,
				show = function (x) end,
			}

			------------------------------------------------------
			-- check_types(e, a, s)
			--
			-- Check the values at every index in e, dying if
			-- the value is not matching, and returning if it's 
			-- right. 
			--
			-- e is the table or value we want to analyze.
			-- a is the type to validate.
			-- s is a possible value to assign e to.
			--
			-- *any type but nil
			------------------------------------------------------
			--[[
			local function check_types(e, a, s)
				-- If a says atable, then move through each index.
				-- Test if it's
				if s then s = s + 1 end
				if a == 'atable' then
					for n,x in pairs(e) do
					-- Error out if a number is encountered.
						if type(n) == 'number' then
							die.xerror({
								fn = "xmlhttp", 
								msg = "Expected alphabetically indexed table at %f."
							})	
						end
					end
				elseif a == 'ntable' then
					for n,x in pairs(e) do
						-- Error out if a number is encountered.
						if type(n) == 'string' then
							die.xerror({
								fn = "xmlhttp", 
								msg = "Expected numerically indexed table at %f."
							})	
						end
					end
				else
				end	
			end
			--]]

			-- Clone your defaults.
			local original = {
				xmlhttp = table.clone(xmlhttp),
				settings = table.clone(xmlhttp_settings),
			}

			-- Extract settings.
			local settings = table.retrieve(table.keys(xmlhttp_settings), t)
			
			-- Typecheck and validate.
			if settings then
				for k,v in pairs(settings) do
					if type(v) ~= type(xmlhttp_settings[k])
					then
					die.xerror({ 
						fn = "E.xmlhttp", tn = type(xmlhttp_settings[k]),
						msg = "Expected type %t at index ["..k.."] in %f." 
					})
					end
				end	
			end	

			-- Get all keys from t.	
			t = table.retrieve(table.keys(xmlhttp), t)

			-- Cycle through each.
			for n,k in pairs(t)
			do
				-- Autobind id's / classes from links to places on page.
				if t.autobind 
				then 
					-- Type check the autobind stuff.
					if type(t.autobind) ~= "string" and type(t.autobind) ~= "table"
					then
						die.xerror({
							fn = "xmlhttp", on = {"string", "table"}, 
							msg = "Expected %o at index ["..n.."] at %f."})

						if is.ni(t.autobind)
						then
							die.xerror({fn = "xmlhttp", 
								msg = "Expected alpha table at index ["..n.."] at %f."})
						end
					end

					-- If it's a table, move through and:
					-- 1. Add key to __LOCATION__ 
					-- 2a. If value is a key-value table, then assign elements from
					-- group named by key into table
					-- 2b. 
					if type(t.autobind) == 'table'
					then
						-- Iterate through each group and set the things.
						for kk,vv in pairs(t.autobind)
						do
							if type(vv) == 'string'
							then
								table.insert( xmlhttp.autobind, vv )
							elseif type(vv) == 'table'
							then
							end
						end

					-- If it's a string, automatically open payloads from
					-- everything in the same field.
					elseif type(t.autobind) == 'string'
					then
						die.quick( table.dump(eval.group) )	
					end
				end
			end

			if settings.dump then
				return "\n" .. table.concat(js_dump) .. "</script>\n"
			end
		end
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
		local int = int or table.maxn(data.url) 
		local active_url = data.url[int]
		local snames = names[request.selection] or names

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
		-- Check groupnames supplied in xpath, dying if 
		-- they haven't been used before.
		------------------------------------------------------
		local groupnames = {}
		if xpath and type(xpath) == 'string' then
			table.insert(groupnames, xpath)
		elseif xpath and type(xpath) == 'table' then
			if not is.ni(xpath) then 
				die.xerror({ fn = "E.serve", msg = "Not correct type at %f" })
			end
			for xx,vv in ipairs(xpath) do
				if is.value(xpath, table.keys(eval.group)) then
						table.insert(groupnames, vv)
				else 
					die.xerror({ fn = "E.serve", 
						msg =  "No group named "..vv.." at %f" })
				end
			end
		elseif not xpath
		then
			table.insert(groupnames, "_d_")
		else
			-- incorrect type or argument has been thrown
			die.xerror({ fn = "E.serve", 
				msg =  "Incorrect argument 2 at %f." })
		end

		------------------------------------------------------
		-- Evaluate whatever code is tied to the function.
		------------------------------------------------------
		for kk,yy in ipairs(groupnames)
		do
			if is.value(active_url, eval.group[yy])
			 and is.key(active_url, eval.execution[yy])
			then
				return x_or_not( active_url, eval.execution[yy][active_url]() ) or nil

			------------------------------------------------------
			-- Do a file include.
			------------------------------------------------------
			elseif is.value(active_url, eval.group[yy])
			then
				if request.xpath and type(request.xpath) == 'string' then
				--	return find_file( string.format("%s/%s",request.xpath, active_url) )
					return x_or_not( request.xpath, 
						find_file( string.format("%s/%s", request.xpath, active_url) )) or nil
				else
				--	return find_file( active_url ) end
					return x_or_not( active_url, find_file( active_url )) or nil 
				end
			end
		end
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
	nserve = function (int,xpath)
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
