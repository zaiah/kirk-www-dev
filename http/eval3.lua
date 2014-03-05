------------------------------------------------------
-- eval.lua
--
-- Creates an interface for crafting the response to
-- resource requests.
--
-- By this definition, E.links() does not belong here.
------------------------------------------------------

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
-- serve
--
-- Defaults for serving.
------------------------------------------------------
local serve = {
	fail = { ["_d_"] = false },
	autobind = { ["_d_"] = false },
	default = { ["_d_"] = false },	
	level = { ["_d_"] = false },	
	tolerant = false,
}

------------------------------------------------------
-- fail
------------------------------------------------------
local fail = {
	level = {},							-- If failing, use this as a guide for when.
	except = { ["_d_"] = false },		-- Do not fail at receipt of these resources.
	message = { ["_d_"] = false },		-- Define a different message, w/ no handler. 
	handler = { ["_d_"] = false	},		-- Use a totally different handler.
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
	bind_points = {},  -- Empty table for items to bind to.
	bind_resources = {}, -- Empty table for binding resources.
	
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

local xhr = {
	location = {}, -- Table for locations and unique names.
	resources = {}, -- Accept requests for these?
	mapping = {},  -- ...
	resmaps = {},   -- Have to access this from links to set the classes.
}

------------------------------------------------------
-- eval {}
--
-- Table to hold elements used to evaluate the HTTP
-- request.
------------------------------------------------------
local eval = {
	level 		= 1,              	-- Should automatically be 1. 
	default     = { ["_d_"] = false },		-- ?
	resources 	= false,					-- ?
	done 			= false,			   	-- Change to true when eval_eval() is done. 
	fs_root 		= "/",					-- Serve relative to here?
	execution 	= {["_d_"] = {} },  	-- Store execution blocks. 
	group 		= {["_d_"] = {} },	-- Set a place for resources.
	href 			= {["_d_"] = {} },	-- Set a place for resources.
	order 		= {"skel","html"},	-- Default order for finding files.
	xmlhttp 		= {["_d_"] = {}},  	-- Which groups get XMLHttp requests?
	
	xhr = { ["_d_"] = {} },
	xhr_names = {},  --
	xhr_maps = {},   -- Unique names, but remember that resources may NOT be unique
}

------------------------------------------------------
-- js_dump str
--
-- A table that will hold the contents of 
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
		-- Die if term is not a string.
		die.xtype(term, {"string", "table"}, "E.default")
		
		-- Set a default resource
		if type(term) == 'string' then
			eval.default._d_ = term
		elseif type(term) == 'table' then
			if is.ni(term) then
				die.xerror({
					fn = "E.default",
					msg = "Received numerically indexed table at %f. "  
					 .. "Expected alphabetically indexed table."
				})
			end
			
			-- die.xntable(term, "E.default") | die.xatable(term, "E.default")
			for xx,yy in pairs(term) do
				if type(xx) == "number" then
					eval.default._d_ = yy
				else
					eval.default[xx] = yy
				end
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
		die.xtype(f, "function", "E.run")

		-- Might need some function safety, in case it just
		-- totally fails...
		if data.url[level]
		then
			return f(data.url[level])
		elseif eval.default
		then 
			return f(eval.default._d_)
		else
			return ""
		end
	end,

	------------------------------------------------------
	-- .set(t)
	--
	-- Set the E module.
	-- *nil
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
					eval.execution._d_[k] = v		-- Reference function v with k

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
	--    url_root    = [string]        	-- Creates href relative to [root].
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
				if t[v] then
					shuffle(validation, t[v], v, "E.links")
				end
			end

			local links = {}
			for __,link_group in ipairs(groupnames) -- href.group[href.group] )
			do
				-- Move through strings doing replacements.
				if t and t.string and t.string[link_group]
				then
					-- Will use a custom syntax.
					for __,link_value in ipairs(eval.group[link_group])
					do
						new_string = string.gsub(tostring(t.string[link_group]), '%%s', link_value)
						table.insert(links, new_string) 
					end

				-- Move through the rest.
				else
					for __,link_value in ipairs(eval.group[link_group])
					do
					table.insert(links, table.concat({
						-- Start the tag.
						'<a href=', 
						-- Relative root.
						'"' .. tostring(href.url_root[link_group] or href.url_root._d_), 
						-- Resource name.
						link_value .. '"',   
						-- Class Name.
						(function ()
							-- local xhr_name = string.append(xhr.resources[link_value], " ") 
							return string.set(table.concat({
								string.append(xhr.resources[link_value], " "), 
								href.class[link_group] or href.class._d_
							}), " class")
						end)(),
						-- ID name
						(function ()
							if href.id[link_group] or href.id._d_ then
								return string.set(link_value, " id")
							else return "" end
						end)(),
						-- Close the opening tag.
						">",
						-- Resource name or alias.
				--		href.alias[link_group][link_value] or link_value, 
						-- Resource name only.
						link_value, 
						-- Close the entire tag.
						"</a>\n"
					}))	
					end -- for __,link_value in ipairs(eval.group[link_group])
				end -- if t and t.string and t.string[link_group]
			end -- for __,link_group in ipairs(group)

			-- Reset to defaults, letting another link chain do work if specified.
			href = defaults
			
			-- Finally output everything new.
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
	-- .js()
	--
	-- Returns a table of Javascript resource names 
	-- while we work out the logistics of including xhr.
	-- *table
	------------------------------------------------------
	js = function ()
		return {
		   "/js/kirk-js/debug",
		   "/js/kirk-js/autobind",
		   "/js/kirk-js/variables",
		   "/js/kirk-js/xmlhttp",
		   "/js/kirk-js/send_test_req",
		-- "/js/kirk-js/get",
		   "/js/kirk-js/json",
		-- "/js/kirk-js/kirk",
		-- "/js/kirk-js/os",
		   "/js/kirk-js/send_get_req",		-- Amalgamate into requestor.js
		   "/js/kirk-js/send_multipart_post_req",
		   "/js/kirk-js/send_www-url-form-enc-post_req",
		-- "/js/kirk-js/testjs",
		   "/js/kirk-js/init",
		}
	end,

	------------------------------------------------------
	-- .xhr()
	--
	-- Bind resources to XMLHttpRequests. 
	-- 
	-- Example and Usage:
	--
	-- <pre>
	-- E.xmlhttp ({
	-- 	autobind = {	-- Choose to bind resources to ID's or classes...
	-- 	bounds   = {	-- Define "aliases" for elements to bind to.
	-- 		[x] = ".fool", -- The class .fool can be referenced by [x] now.
	-- 		[y] = "#mega", -- The ID mega can be referenced by [y] now.
	-- 	},
	-- 	animate  = {   -- Bind an animation to some elements.
	-- 		[x] = [number or table],
	-- 		[y] = 300 or { start = 300, end = 300}
	-- 	},
	--  [show,hide] = [number or table],  -- Set show and hide speed 
	-- 	post 	= [string or table]
	-- 	get = [string or table]
	-- })
	-- </pre>
	--
	-- *nil
	------------------------------------------------------
	xhr = function (t)
		local fname = "E.xhr"
		
		if t then
			------------------------------------------------------
			-- Start the Javascript dump.
			------------------------------------------------------
			table.insert(js_dump, '<script type="text/javascript">')

			-- These will probably be moved to js or something
			------------------------------------------------------
			-- arrayify(t, name)
			--
			-- Store in [name] all elements in [t].  Otherwise
			-- return string representation of Javascript array.
			-- *string
			------------------------------------------------------
			local function arrayify( t, name ) 
				fname = "arrayify"
				local js, js_str = {}, ""

				if name then
					js_str = "var " .. name .. " = [" 
				else
					js_str = "["
				end
				for _,v in ipairs(t) do
					if type(v) ~= "string" then
						die.xerror({
							fn = fname,
							msg = "local %f expects strings"
							 .. " within supplied table."
						})
					end 
					table.insert(js, "'" .. v .. "'")
				end 

				return table.concat( {js_str, table.concat(js,","), "];"} )
			end
			
			------------------------------------------------------
			-- objectify(t, name)
			-- 
			-- Store in [name] all elements in [t].  Otherwise
			-- return string representation of Javascript object.
			-- Turn a table into a js object.
			------------------------------------------------------
			local function objectify( t, name ) 
				fname = "objectify"
				local js, js_str = {}, ""
				
				if name then
					js_str = "var " .. name .. " = {" 
				else
					js_str = "{"
				end
				
				for k,v in pairs(t) do
					if type(v) ~= "string" then
						die.xerror({
							fn = fname,
							msg = "local %f expects strings within supplied table."
						})
					end 
					table.insert(js, table.concat({k, ": ", "'", v, "'"}))
				end 

				return table.concat( {js_str, table.concat(js,","), "};"} )
			end
			
			
			------------------------------------------------------
			-- Set up all the datatypes.
			------------------------------------------------------
			local validation = {
				autobind = {
					datatypes = { "atable", "string" },
					_atable = function (x)
						for xx,yy in pairs(x) do
							-- Set the location name.
							local location_name, class_name = uuid.alpha(4), ""
							xhr.location[ location_name ] = xx

							-- Set any available resources.
							if type(yy) == 'table' and is.ni(yy) then
								for __,v in ipairs(yy) do
									-- Must take groups into account.
									
									-- Save a record of the new class association.
									xhr.resources[v] = "_" .. string.lower(uuid.alpha(7))
									-- Also save how it's mapped for JS dump.
									xhr.mapping[ xhr.resources[v] ] = location_name 
									-- Save a record of the link needing presentation over XHR.
									table.insert(eval.xhr._d_, v)
								end
							-- Set all the resources' class names.
							elseif type(yy) == 'string' then
								xhr.resources[yy] = "_" .. string.lower(uuid.alpha(7))
								xhr.mapping[ xhr.resources[yy] ] = location_name 
								table.insert(eval.xhr._d_, yy)
							end
						end
					end,

					_string  = function (x)
						-- One "sink" is going to get all your resources.   
						-- Don't care from where.
						xhr.location[ uuid.alpha(4) ] = x
						
						-- You need to set ALL the classes here.
						table.insert(xhr.resources, x)
					end,
				},
			}

			-- Clone your defaults.
			--[[
			local original = {
				xmlhttp = table.clone(xmlhttp),
				settings = table.clone(xmlhttp_settings),
			}
			--]]

			-- Extract settings.
			local settings = table.retrieve(table.keys(xmlhttp_settings), t)
			
			-- Typecheck and validate.
			if settings then
				for k,v in pairs(settings) do
					if type(v) ~= type(xmlhttp_settings[k]) then
						die.xerror({ 
							fn = fname, tn = type(xmlhttp_settings[k]),
							msg = "Expected type %t at index ["..k.."] in %f." 
						})
					end
				end	
			end	

			-- Get all keys from t.	
			t = table.retrieve(table.keys(xmlhttp), t)

			-- Cycle through each.
			for n,v in pairs(t) do	
				if n == 'autobind' then
					if t[n] then
						shuffle(validation, t[n], n, fname)
					end
				end
			end

			-- Generate the JS.
			table.insert(js_dump, arrayify( table.values(xhr.resources), "__RESOURCES__" ))
			table.insert(js_dump, objectify( xhr.location, "__LOCATION__" ))
			table.insert(js_dump, objectify( xhr.mapping, "__MAPPING__" ))

			-- Dump the Javascript.
			if settings.dump then
				return "\n" .. table.concat(js_dump, "\n") .. "\n</script>\n"
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
	-- E.fail({     -- Fail with a 404 if resources at n are not found.
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
	-- level
	-- default ?
	-- fail ?
	-- fs_root
	-- order
	-- autobind? - forces XMLHttp requests...?
	-- group
	--
	-- *nil or *string
	------------------------------------------------------
	serve = function (t, group_sel)
		------------------------------------------------------
		-- local srv_req( xblock )
		--
		-- Execute or present string returned by [xblock] 
		-- either by using XMLHttpRequest or a typical return.
		--
		-- *string or *nil
		------------------------------------------------------
		local function srv_req( req, group_sel )
			-- die.quick(tostring(req))
			-- Define some starter details.
			local payload
			local group = group_sel or "_d_"
			local req = req or eval.default[group]

			-- Die on no default.
			if not eval.default[group] then
				-- If there is a group specified, this will change.
				die.xerror({
					fn = "E.serve",
					msg = "No default payload mapped to resource "..
					 tostring(int).." at %f."
				})
			end

			-- Die if the group doesn't exist.
			if group_sel and not is.value(group_sel, table.keys(eval.group)) then
				die.xerror({
					fn = "E.serve",
					msg = "No default payload mapped to resource "..
				 	tostring(int).." at %f."
				})
			end
			
			-- 404 or proceed if the name isn't a listed resource.
			if not is.value(req, eval.group[group]) then
				if fail.level[int] then
					-- Throw auto 404
					if fail.group[group] and not is.value(req, fail.except[group]) then
						die.with(404, {msg = "Cannot find page: " .. req .. "."})
					end
				else
				end
			end

			-- Can set order from E.serve
			-- Default is to find functions first.
			if type(eval.execution[group][req]) == 'function' 
			then
				-- If there's an error, payload will die here.
				payload = interpret.funct( eval.execution[group][req] ) or "" 
			-- Then skels.
			-- elseif bla then -- F.exists()
			-- Then htmls.
			else
				-- One of these HAS to work. If not, it's an error.
				for _,inc in ipairs({"skel","html"})
				do
					payload = add[inc]( req )
					if payload then break end 
				end

				-- Die if payload's still not present.
				if not payload
				then
					die.xerror({
						fn = "E.serve",
						msg = "%f did found neither a skel file " ..
						 "nor an html file titled "..req.." at this instance."
					})
				end
			end
 
			-- Serve over xmlhttp if asked.
			if eval.xhr[group] and is.value(req, eval.xhr[group]) 
			then
				response.abort({200}, payload)

			-- If not serve like normal.
			else
				return payload 
			end
		end

		------------------------------------------------------
		-- Define the rest.  Takes alternate syntax.
		------------------------------------------------------
		local int
		local active_url 
		local group = group_sel or "_d_"

		-- Serve per resource. 
		if type(t) == 'number' -- and type(group_sel) == 'string'
		then
			active_url = data.url[t] or nil

		-- Evaluate your table and serve something more complex.
		elseif type(t) == 'table'
		then
			------------------------------------------------------
			-- I do need to evaluate some stuff.
			------------------------------------------------------
			local validation = {	
				level = {
					datatypes = "number",
					_number = function (x) t.level = x end,
				},
				default = {
					datatypes = "number",
					_number = function () end,
				},
				fail = {
					datatypes = { "boolean", "atable" },
					_boolean = function () end,
					_atable = function () end,
				},
				fs_root = {
					datatypes = { "string", "atable" },
					_number = function () end,
				},
				order = {
					datatypes = { "ntable" }, 
					_number = function () end,
				},
			}
	
			------------------------------------------------------
			-- Start returning that cray shit.
			------------------------------------------------------
			int = t.level -- or table.maxn(data.url)
			active_url = data.url[int] or nil
		-- Catch all others.	
		else
			die.xerror({
				fn = "E.serve",
				tn = type(t),
				on = { "number", "table" },
				msg = "Received %t at %f.  Expected either %o."
			})
		end
		
		return srv_req(active_url, group_sel or nil)
	end,
}
