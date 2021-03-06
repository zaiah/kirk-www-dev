------------------------------------------------------
-- eval.lua
--
-- Creates an interface for crafting the response to
-- resource requests.
--
-- By this definition, E.links() does not belong here.
------------------------------------------------------
------------------------------------------------------
-- types {} 
--
-- A table of different types. 
------------------------------------------------------
local types = {}						-- Table of datatypes.
local routes = {}						-- Table of routes.
local groups = {} 					-- Table of groups.
local bounds = {} 					-- Table of bounds.
local default = uuid.alnum(10) 	-- A default namespace.

------------------------------------------------------
-- lookup {} 
--
-- Some stuff for name lookups. 
------------------------------------------------------
local lookup = {names = {}, xids = {}}	-- Table of names.
local lname = function (x) 
	-- Find a name, there will be conflicts here.
	if x then
		-- If this doesn't exist, no error...
		return lookup.names[ table.index( lookup.xids, x ) ]
	end
end

local lxid = function (n) 	-- Find an xid.
	if n then
		-- If this doesn't exist in table, no error...
		return lookup.xids[ table.index( lookup.names, n ) ]
	end
end

local ladd = function (x) 	-- Add a new record.
	local xid = uuid.alpha(6)
	table.insert(lookup.names, x)
	table.insert(lookup.xids, xid)
	return xid
end

lookup.name = lname
lookup.xid = lxid
lookup.add = ladd

------------------------------------------------------
-- group {}
--
-- Group scaffolding.. 
------------------------------------------------------
local group = {
	name = false,		-- Name of a particular group.
	fs_root = false,	-- When serving resources, this fragment will tell Kirk where to find the file.
	members = {},		-- A list of members that belong to this group.
	default = false,	-- A default resource for a group.
	class = false,		-- The class to use on a group of resources.
	string = false,	-- A custom string to use instead of auto-generation.
	url_root = false,	-- When presenting links, this fragment will be prepended to the resource name or alias.
	fail = {
		level = false,	-- Fail at a different level from the one you're trying to serve.
		message = {
			[404] = false,	-- A 404 Not Found Message to subvert the standard one that ships with Kirk.
			[500] = false,	-- A 500 Not Found Message to subvert the standard one that ships with Kirk.
		},
		handler = {
			[404] = false,	-- A resource whose sole purpose is to handle 404 Not Found statuses. 
			[500] = false,	-- A resource whose sole purpose is to handle 500 Internal Server Error statuses. 
		},
		except = false,	-- Members in this list that do not exist in a current group will be allowed through.
	},
	names = {},			-- ... Is this used?

	-- Types
	types = {
		name = "string",
		url_root = "string",
		fs_root = "string",
		members = "ntable",
		names = "atable",
		class = { "string", "ntable", "atable" },
		fail = {
			level = "number",
			message = {
				[404] = "string",
				[500] = "string",
			},
			handler = {
				[404] = "string",
				[500] = "string",
			},
			except = { "string", "ntable" }
		}
	}
}

------------------------------------------------------
-- local gcreate(t,g) 
--
-- Create a new group. 
------------------------------------------------------
local gcreate = function (name, t)
	-- Create an ID.
	local name = name or default	

	-- Create the new group if it doesn't exist.
	if not groups[name] then
		groups[name] = {}

		-- Create a scaffold table for the new route.
		local new_group = table.clone(group)
		local scaffold = table.retrieve_non_matching({ 
			"create", 
			"modify", 
			"types", 
			"member",
			"exists",
			"clone", 
			"inherit", 
			"names" 
		}, new_group)

		-- Pull valid types and set.
		-- Catch if the group doesn't exist?
		if t and type(t) == 'table' then
			for kk,vv in pairs(t) do
				if t[kk] then
					if type(vv) == group.types[kk] or type(vv) == 'table' 
					 or is.value(type(vv), group.types[kk]) then
						groups[name][kk] = vv 
					-- else die.xerror( type of something is bad... )
					end
				end
			end
		end

		-- Set a couple of defaults.
		for kk,vv in pairs(scaffold) do
			if not groups[name][kk] then
				groups[name][kk] = vv 
			end
		end
	end
end

------------------------------------------------------
-- gmodify 
--
-- Modify a group. 
------------------------------------------------------
local gmodify = function (g,t)
	-- Only move forward if the group exists.
	if g and groups[g] then
		for kk,vv in pairs(t) do
			if t[kk] then
				if type(vv) == group.types[kk] or type(vv) == 'table' 
				 or is.value(type(vv), group.types[kk]) then
				-- if kk == 'class' then die.quick(type(groups[g][kk])) end
					groups[g][kk] = vv 
				end
			end
		end
	end
end

------------------------------------------------------
-- local gduplicate(g,n) 
--
-- ... 
------------------------------------------------------
local gclone = function(g, n)
	-- Clone a table. 
	groups[n] = table.clone(groups[g])
end

------------------------------------------------------
-- local ginherit
--
-- Inherit from an existing group. Make no copy.
------------------------------------------------------
local ginherit = function(g, n)
	if groups[g] then
		-- Clone a table. 
		groups[n] = {}

		-- Need a way to do this and skip over certain values.
		groups[n]["class"] 	= groups[g]["class"] 
		groups[n]["default"] = groups[g]["default"] 
		groups[n]["fail"] 	= groups[g]["fail"] 
		groups[n]["fs_root"]	= groups[g]["fs_root"] 
		groups[n]["name"] 	= groups[g]["name"] 
		groups[n]["string"] 	= groups[g]["string"] 
		groups[n]["url_root"] = groups[g]["url_root"] 

		-- ...
		groups[n]["members"]	= {}
	end
end

------------------------------------------------------
-- member {} 
--
-- Member functions. 
------------------------------------------------------
local gmember = {
	add = function (x,u,g)
		if not x or not u or not g then
			die.xerror({
				fn = "group.member.add",
				msg = "%f requires three arguments denoting the " .. 
				 "resource name, a unique id and a group."
			})
		else
			groups[g]["members"][x] = u 
		end
	end,

	remove = function (x,g) 
		local id = g or default
		groups[id]["members"][x] = nil 
	end,

	list = function (g)
		local id = g or default
		table.concat( groups[id]["members"])
	end,
}

------------------------------------------------------
-- exists 
--
-- Does a group exist? 
------------------------------------------------------
local gexists = function (n)
	if groups[n] then return true else return false end
end

group.create = gcreate
group.modify = gmodify
group.member = gmember 
group.clone = gclone 
group.inherit = ginherit 
group.exists = gexists


------------------------------------------------------
-- route {} 
--
-- Table for routing handler.  This is imposed
-- on new members when creating a route.  Reference
-- its members with route[name][item]
------------------------------------------------------
local route = {			-- Group names can be unique so there is no trouble.
	autobound = false,	-- Where is a payload bound to?
	execution = false, 	-- Function content of a resource.
	include = false,		-- Include a file or not.
	name = false,			-- The name of the route.
	alias = false,   		-- An alias for this route.
	id = false,				-- Boolean indicating when items should have an ID tag or not.
	hover = false,			-- String or function to populate a CSS drop down window.
	href = false,			-- hypertext reference of where the route should lead
	order = false,			-- Number defining the order of interpreted links.
	member_of = {},		-- String or table containing the group(s) that a route is associated with.
	xhr_req_type = false, -- HTTP method to use for XMLHttpRequests
	xhr_preferred = false,-- Preference of XMLHttpRequest versus a regular server-side dump.
	xhr_pre = false,		-- A Javascript function to run before serving the resource.
	xhr_post = false,		-- A Javascript funciton to run after serving the resource.
	xhr_mask = false,		-- The mask name of a "fake" group made to serve XHR.
	xhr_show = false,		-- Number defining how fast a resource should be shown after injection.
	xhr_hide = false,		-- Number defining how fast a resource should be hidden after dejection.
	xhr_animate = false,	-- Turn on or turn off animation when injecting/dejecting autobound payloads.
	xhr_name = false,		-- A unique name for the XHR field.
	xhr_href = false,		-- A hypertext reference.

	-- All types.
	types = {
		autobound = { "string", "ntable", "atable" },
		execution = "function",
		include = "string",
		name = "string",
		alias = "string",
		id = { "boolean", "atable" },
		pre = "function", 
		post = "function", 
		hover = { "string", "ntable", "atable" },
		href = "string",
		order = "number",
		member_of = { "string", "ntable" },
		xhr_req_type = "string",
		xhr_preferred = "boolean",
		xhr_pre = { "string", "function" },
		xhr_post = { "string", "function" },
		xhr_mask = "string",
		xhr_name = "string",
		xhr_show = "number",
		xhr_hide = "number",
		xhr_animate = "boolean",
		xhr_href = "function",
	}
}

------------------------------------------------------
-- local rcreate(t,g) 
--
-- Creates a new route.
------------------------------------------------------
local rcreate = function (t, return_xid)
	if t then
		-- Create an XID and track the name.
		local xid = lookup.add( t.name, xid )

		-- Create a scaffold table for the new route.
		local new_route = table.clone(route)
		local scaffold = table.retrieve_non_matching({ 
			"create", 
			"modify", 
			"names",
			"types", 
			"named", 
			"ns", 
			"xid"
		}, new_route)

		-- Create a new table for the route in question.
		routes[xid] = {}

		-- Pull valid types from t and set.
		for kk,vv in pairs(t) do
			if t[kk] then
				if type(vv) == route.types[kk] or type(vv) == 'table' 
				 or is.value(type(vv), route.types[kk]) then
					routes[xid][kk] = vv 
				-- else die.xerror( type of something is bad... )
				end
			end
		end

		-- Set the rest of the defaults.
		for kk,vv in pairs(scaffold) do
			if not routes[xid][kk] then
				routes[xid][kk] = vv 
			end
		end

		-- Set href from here.
		routes[xid]["href"] = routes[xid]["name"]

		-- Also add an info group for static information.
		routes.info = { 
			ns = "__ROUTES__",		-- Javascript namespace.
			types = route.types		-- Datatypes supported.
		}

		-- Assign a group.
		local gid = t.group or default 
		group.member.add( t.name, xid, gid )
		table.insert(routes[xid]["member_of"], gid)

		-- Return that handle or not.
		if return_xid then return xid end

	-- Routes need some data.
	else
		die.xerror({
			fn = "route.create",
			msg = "Cannot create a new route without at least a name."
		})
	end
end

------------------------------------------------------
-- rnamed(name, g) 
--
-- Retrieve a resource named 'name' in a group g. 
------------------------------------------------------
local rnamed = function (name, g)
	local groupn = g or default
	if name and group.exists(groupn) then
		return groups[groupn]["members"][name]
	end
end

------------------------------------------------------
-- rmodify() 
--
-- Update routes.
------------------------------------------------------
local rmodify = function (t)
	local xid 
	if t.where then
		xid = rnamed(t.where[1], t.where[2])
		t.where = nil

	-- Allow direct supply of the name or lookup by
	-- group and name.
	elseif t.xid then
		xid = t.xid  -- or rnamed(t.name) 
	end

	-- Catch if the group doesn't exist?
	for kk,vv in pairs(t) do
		if t[kk] then
			if type(vv) == route.types[kk] or type(vv) == 'table' 
			 or is.value(type(vv), route.types[kk]) then
				routes[xid][kk] = vv 
			-- else die.xerror( type of something is bad... )
			end
		end
	end
end

-- get the url root for a particular group.
local rget_url_root = function ()
	
end

route.create = rcreate
route.modify = rmodify
route.named = rnamed 
route.get_url_root = rget_url_root 


------------------------------------------------------
-- bounds {} 
--
-- Table for different DOM markers. 
------------------------------------------------------
local bound = {
	dom_element = false,		-- A spot on the DOM.
	is_class = false,			-- Is it a class?
	is_id = false,				-- Is it an ID?
	name = false,				-- Give a bound a human name.
	animate = false,			-- Should this particular bound be animated?
	hide = false,				-- The hide speed for this bound.
	show = false,				-- The show speed for this bound.
	listen = false,			-- Should this bound be listening for anything.
	types = {
		dom_element = "string",	
		animate = "boolean",		
		hide = "number",
		show = "number",
	}
}

------------------------------------------------------
-- bcreate() 
--
-- Create a new bound. 
------------------------------------------------------
local bcreate = function (t, return_xid)
	if t then
		-- Create a scaffold table for the new route.
		-- local new_bound = table.clone(bound)
		local scaffold = table.retrieve_non_matching({ 
			"create", 
			"modify", 
			"remove",
			"types", 
		}, table.clone(bound))

		-- Create a new table for the bound in question.
		local xid = uuid.alpha(10)	
		bounds[xid] = {}

		-- Pull valid types from t and set.
		for kk,vv in pairs(t) do
			if t[kk] then
				if type(vv) == bound.types[kk] or type(vv) == 'table' 
				 or is.value(type(vv), bound.types[kk]) then
					bounds[xid][kk] = vv 
				end
			end
		end

		-- Check if it's an ID or class.
		if t.dom_element then 
			if string.sub(t.dom_element, 0, 1) == '#' then
				bounds[xid]["is_id"] = true
				bounds[xid]["dom_element"] = table.concat({
					"document.getElementById('",
					string.sub(t.dom_element, 2, string.len(t.dom_element)),
					"')"
				})
			elseif string.sub(t.dom_element, 0, 1) == '.' then
				bounds[xid]["is_class"] = true
				bounds[xid]["dom_element"] = table.concat({
					"document.getElementsByClassName('",
					string.sub(t.dom_element, 2, string.len(t.dom_element)),
					"')"
				})
			else
				-- Assume ID if # or . is omitted.
				bounds[xid]["dom_element"] = t.dom_element 
			end
		end

		-- Set the rest of the defaults.
		for kk,vv in pairs(scaffold) do
			if not bounds[xid][kk] then
				bounds[xid][kk] = vv 
			end
		end

		-- Also add an info group for static information.
		bounds.info = { 
			ns = "__BOUNDS__",		-- Javascript namespace.
			types = bound.types		-- Datatypes supported.
		}

		-- Return that handle or not.
		if return_xid then return xid end

	-- Routes need some data.
	else
		die.xerror({
			fn = "bound.create",
			msg = "Cannot create a new bound without at least a name."
		})
	end
end

local bmodify = function ()
end

local bremove = function ()
end

local bexists = function (n)
	if bounds[n] then return true else return false end
end

bound.create = bcreate
bound.modify = bmodify
bound.remove = bremove
bound.exists = bexists


------------------------------------------------------
-- xhr {} 
--
-- XMLHttpRequest settings and information.
------------------------------------------------------
xhr = {
	status = false,		-- Boolean to indicate whether or not developer has
								-- requested XHR.
	js = {},					-- Table for Kirk's dynamically generated Javascript.
	location = {}, 		-- Key-Value table mapping DOM elements to unique IDs
	resources = {}, 		-- Table of resources expected to be served over XHR.
	mapping = {},  		-- Key-Value table mapping resource payloads to DOM 
								-- elements.
	ns = "joe_x_x_",		-- A url root name. (I wonder what 2 and 3 are...)
	default = "",			-- An XHR default name.
	name = function(x)	-- Return a properly formatted name.
		return "__" .. x
	end,
	unique 		= false, -- Use unique identifiers as classes.
	namespace   = "",  	-- Set up a different namespace for classes.
	wait 			= false, -- Wait until a response is received before moving further.
	dump 			= false, -- Dump generated Javascript as the result of an XMLHttp call.
	dump_to  	= "", 	-- Dump generated Javascript to a certain place. 
}

------------------------------------------------------
-- local convert {}
--
-- Convert to different Javascript types.
------------------------------------------------------
convert = {
	------------------------------------------------------
	-- array()
	--
	-- Convert something to an array.
	------------------------------------------------------
	array = function (t)
	end,

	------------------------------------------------------
	-- object()
	--
	-- Convert something to an object.  (JSON)   If set
	-- is called, then the object will be set to a value
	------------------------------------------------------
	object = function (t, set, encaps)
		local js, js_str = {}, ""
	
		if set and encaps then
			js_str = "var " .. set .. " = {" 
		elseif set then
			js_str = set .. ":{" 
		else
			js_str = "{"
		end
		
		for k,v in pairs(t) do
			if not is.value(type(v), {"string", "boolean", "number"}) 
			then
				die.xerror({
					fn = fname,
					msg = "local %f expects strings within supplied table."
				})
			end 

			local kv
			if type(v) == 'string' and k ~= "dom_e" then
				kv = '"' .. v .. '"'
			else
				kv = tostring(v)
			end	
			table.insert(js, table.concat({k, ":", kv}))
		end 

		-- Evaluate again.
		if set and encaps then
			return table.concat( {js_str, table.concat(js,","), "};"} )
		elseif set then
			return table.concat( {js_str, table.concat(js,","), "}"} )
		else
			return table.concat( {js_str, table.concat(js,","), "}"} )
		end
	end,

	------------------------------------------------------
	-- collection()
	--
	-- Convert a table to a collection.
	------------------------------------------------------
	collection = function (t)
	end,
}

------------------------------------------------------
-- local arrayify(t, name)
--
-- Store in a Javascript array [name] all elements in [t].  
-- Otherwise return string representation of Javascript 
-- array. [t] must be a table.
--
-- *string
------------------------------------------------------
function arrayify( t, name ) 
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
-- local objectify(t, name)
-- 
-- Store in a Javascript object [name] all elements in [t].  
-- Otherwise return an anonymous string representation of 
-- a Javascript object. [t] must be a table.
--
-- *string
------------------------------------------------------
function objectify( t, name ) 
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
		table.insert(js, table.concat({k, ":", "'", v, "'"}))
	end 

	return table.concat( {js_str, table.concat(js,","), "};"} )
end

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
	default = function (...)
		-- Parse arguments in a smart way.
		local vararg = {...}
		local varstr = false

		-- Set a default resource
		for __,var in ipairs(vararg) do
			if type(var) == 'string' and not varstr then
				groups[default]["default"] = var 
				varstr = true 

			-- Set a default resource.
			elseif type(var) == 'table' then
				for xx,yy in pairs(var) do
					-- Specify a "global" default.
					if type(xx) == 'number' then
						groups[default]["default"] = yy
					-- Specify other defaults...
					elseif type(xx) == 'string' then
						if group.exists(xx) then
							groups[xx]["default"] = yy 
						end
					end
				end -- for xx,yy in pairs(term)
			end -- if type(term) == 'string'
		end -- for __,var in ipairs(vararg) do
	end,

	------------------------------------------------------
	-- .run( level, f )
	--
	-- ...
	------------------------------------------------------
	run = function (level, f)
		-- Should check if the default group exists.
		
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

		-- Create the default group if not done already.
		if not group.exists( default ) then
			group.create()
		end

		-- Iterate through t.
		for k,v in pairs(t) do
			-- 
			if type(k) == 'string' then
				-- Both functions and strings can be executed upon.
				if type(v) == 'function' then
					route.create({ name = k, execution = v })

				elseif type(v) == 'string' then
					route.create({ name = k, include = v })

				-- Evaluate the differences in tables.
				elseif type(v) == 'table' then
					-- Create a group.
					group.create(k)

					-- Cycle through the values in the group's table. 
					for kk,vv in pairs(v)
					do
						if type(kk) == 'string'
						then
							if type(vv) == 'string' then
								route.create({ name = kk, include = vv, group = k })
							elseif type(vv) == 'function' then
								route.create({ name = kk, execution = vv, group = k })
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
							if type(vv) == 'string' then
								-- Add this string to a default group. 
								route.create({ name = vv, include = vv, group = k })
							else
								die.xerror({
									fn = "E.set", tn = "string", 
									msg = "Expected %t at index ["..k.."] at %f."
								})
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
					die.xerror({ 
						fn = "E.set", 
						msg = "Expected %o at index ["..k.."] in %f." 
					})
				end

			-- Evaluate numbers.
			elseif type(k) == 'number'
			then
				-- v must always be a string, or bad shit will happen.
				if type(v) == 'string'
				then
					-- Add this route to the default group.
					route.create({ name = v, include = v })
				else
					die.xerror({
						fn = "E.set", tn = "string", 
						msg = "Expected type string at index ["..k.."] at %f. Got %t."
					})
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
	--   url_root = [string]    		-- Creates href relative to [root].
	--    class   = [string]    		-- A class name for each.
	--    id      = [bool]       		-- Use the resource name as an id.
	--    string  = [string]     		-- Use this string as the link dump.
	--    subvert = [table, string] 	-- Don't include these as links.
	--    group   = [string]        	-- Choose a resource group if many have
	--                             	-- been specified.
	--    alias   = [table]         	-- Choose which resources to serve
	--                             	-- with an entirely different link name.
	--    as      = [table]         	-- Omitting as will return a string.
	-- })
	-- </pre>
	--
	-- *nil
	------------------------------------------------------
	links = function (t)
		-- Create a blank table and some giant string.
		local tt, linkstr = {}, ""

		------------------------------------------------------
		-- If [t] is blank, then output the links 
		-- as a string.
		------------------------------------------------------
		if not t then
			-- Shut down if E.set() was not called yet.
			if not groups[default] then
				die.xerror({ 
					fn = "E.links", 
					msg = "<b>function</b> <i>E.set()</i> "..
					"has not been used to initialize any routing logic for %f."
				})
			end

			-- Output a very simple link list.
			for k,v in pairs( groups[default]["members"] ) do
				linkstr = string.gsub('<a href="/%s">%s</a>', '%%s', tostring(k))
				table.insert(tt, linkstr) 
			end

			-- Return the links.
			return table.concat(tt)

		------------------------------------------------------
		-- If [t] is a string, then output the links with a 
		-- url_root represented by that string. 
		-- error if that group does not exist.
		------------------------------------------------------
		elseif type(t) == 'string'
		then
			-- Does this group exist?
			-- If support different failure modes is built in, 
			-- it would come in handy right here.
			if group.exists(t) then
				-- Output a very simple link list.
				for k,v in pairs( groups[t]["members"] )
				do
					if type(k) == 'number' then
						if type(v) == 'string' then
							linkstr = string.gsub('<a href="/%s">%s</a>','%%s',tostring(v))
							table.insert(tt, linkstr) 
						else
							die.xerror({ fn = "E.set",
								msg = "Expected string at %f at index ["..k.."] at "..
								"index ["..t.."]"
							})
						end
					else
						linkstr = string.gsub('<a href="/%s">%s</a>', '%%s', tostring(k))
						table.insert(tt, linkstr) 
					end
				end

				-- Return the links.
				return table.concat(tt)
			end

		------------------------------------------------------
		-- If [t] is a table, then you'll be handling more 
		-- complex functionality.
		------------------------------------------------------
		elseif type(t) == 'table'
		then
			-- Refer to interface/extension/shuffler.lua for more on
			-- this big baby of a table.
			local validation = {
				class = { 
					datatypes = { "string", "atable", "ntable" }, 
					_string = function (x)
						groups[default]["class"] = x
						return false
					end,
					_atable = function (x)
						for xx,yy in pairs(x) do
							if group.exists(xx) then
								if type(yy) == 'table' then 
									if is.ni(yy) then
										groups[xx]["class"] = table.concat(yy," ")
									else
										die.xerror({
											fn = "E.links",
											msg = "Cannot support named tables at index [class]" 
										})
									end
								elseif type(yy) == 'string' then
									groups[xx]["class"] = yy
								end
							end
						end	
						return false 
					end,
					_ntable = function (x) -- Are the typechecks done here?
						for k,v in pairs(x) do
							if type(k) == 'number' then
								if type(v) == 'string' then
									groups[default]["class"] = v
									-- die.quick(orig)
								elseif type(v) == 'table' then
									die.xerror({
										fn = "E.links",
										msg = "Cannot support numerically indexed tables not associated "..
										"with a group at index [class] at index ["..k.."] in %f."
									})
								end
							elseif type(k) == 'string' then
								if type(v) == 'string' then
									groups[k]["class"] = v
								elseif type(v) == 'table' then
									for kk,vv in pairs(v) do
										if type(vv) == 'string' then
											groups[kk]["class"] = vv
										elseif type(vv) == 'table' then
											groups[kk]["class"] = table.concat(vv," ")
										end
									end
								end
							end
						end
						return false 
					end,
				},

				url_root = { 
					datatypes = { "string", "atable", "ntable" },
				
					-- Set a single URL root.
					_string = function (x)
						groups[default]["url_root"] = x
						return false
					end,

					-- Move through and set multiple url roots for different groups.
					_atable = function (x) 
						for xx,yy in pairs(x) do
							if group.exists(xx) then
								groups[xx]["url_root"] = yy 
							-- Another spot for strict errors.
							end
						end
					end,

					-- bla...
					_ntable = function (x)
						for xx,yy in pairs(x) do
							if type(xx) == 'number' then
								if type(yy) == 'string' then
									groups[default]["url_root"] = yy
								else
									die.xerror({
										fn = "E.set",
										tn = type(yy),
										msg = "Received %t at index ["..xx.."] at %f."
									})
								end	
							elseif type(xx) == 'string' then
								if type(yy) == 'string' then
									if group.exists(xx) then
										groups[xx]["url_root"] = yy
									else
										die.xerror({
											fn = "E.links", 
											msg = "Group "..xx.." does not exist at %f."
										})
									end
								end
							end
						end
					end,
				},

				id = { 
					datatypes = { "atable", "boolean" },
					_boolean = function (x) 
						groups[default]["id"] = x
					end,
					_atable = function (x)
						for xx,yy in pairs(x) do
							if group.exists(xx) then
								if type(yy) == "boolean" then
									groups[xx]["id"] = x
								end
							end
						end
					end,
				},

            ------------------------------------------------------
            -- string 
            --
				-- ...
            ------------------------------------------------------
				string = { 
					datatypes = { "string", "atable" },
					_string = function (x)
						groups[default]["string"] = x 
					end,
					_atable = function (x) 
						for xx,yy in pairs(x) do
							if groups.exists(xx) then 
								groups[xx]["string"] = yy 
							end
						end
					end,
				},

            ------------------------------------------------------
            -- subvert 
            --
            -- accepts: string, atable or ntable
				--
				-- If value for subvert is a string, then only that
				-- resource will not show.  If value is ntable, all
				-- those values won't show.  If value is atable,
				-- keys will point to a group.  No key will assign it
				-- to default.
            ------------------------------------------------------
				subvert = { 
					datatypes = { "string", "atable", "ntable" }, 
					_string = function (x)
					--	group.remove(x, default)
					end,
					_ntable = function (x) 
						for xx,yy in ipairs(x) do
					--		group.remove(yy, default)
						end
					end,
					_atable = function (x) 
						for xx,yy in pairs(x) do
							if type(xx) == 'number' then
								if type(yy) == 'table' and is.ni(yy) then
									for kk,vv in ipairs(yy) do
					--					group.remove(vv, default)
									end
								elseif type(yy) == 'string' then
					--				group.remove(yy, default)
								end
							elseif type(xx) == 'string' and group.exists(xx) then 
								if type(yy) == 'table' and is.ni(yy) then
									for kk,vv in ipairs(yy) do
						--				group.remove(vv, default)
									end
								elseif type(yy) == 'string' then
						--			group.remove(yy, default)
								end
							else
								die.xerror({
									fn = "E.links",
									msg = "Group name '" .. xx .. "' does"
								.. " not exist at %f."
							})
							end
						end
					end,
				},

            ------------------------------------------------------
            -- alias 
				--
				-- accepts: atable
            --
            -- Set alternate text for links.  By default, the 
				-- resource name is the text that will show up 
				-- hyperlinked.
            ------------------------------------------------------
				alias = { 
					datatypes = "atable", 
					_atable = function (x)
						for xx,yy in pairs(x) do
							-- If yy is string
							if type(yy) == 'string' then
								local xid = route.named(xx,default)
								if xid then 
									routes[xid]["alias"] = yy
								end
							-- If yy is table
							elseif type(yy) == 'table' then
								for kk,vv in pairs(yy) do
									if group.exists(xx) then
										local xid = route.named(kk,xx)
										if xid then 
											routes[xid]["alias"] = vv 
										end
									end
								end
							end
						end
					end,
				},
			}
			
			------------------------------------------------------
			-- Get the keys from [t]
			------------------------------------------------------
			t = table.retrieve(table.union(
				table.keys(validation),
				{ "group" }	
			), t)

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
							-- die.xval_in_table(msg, table)
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
								"[group] in %f is %t not <b>type</b> <i>string</i> as expected."
							})
						end

						-- Die if the group does not exist.
						if not group.exists(xx)
						then
							die.xerror({
								fn = "E.links",
								msg = "Group name '" .. xx .. "' does not "
								.. "exist at %f."
							})
						end
					end

					groupnames = t.group -- or eval.group
				-- Check if the string is actually a group member.
				else
					if not group.exists(t.group) then
						die.xerror({
							fn = "E.links",
							msg = "Group name '" .. t.group .. "' does not "
							.. "exist at %f."
						})
					end

					groupnames = { t.group } -- or eval.group
				end
			else
				groupnames = { default }
			end -- if t and t.group

         ------------------------------------------------------
         -- Process each of the members below that were part 
         -- of the table in [t].
         ------------------------------------------------------
			local aa = {}
			local keys = {
				"class", 
				"url_root", 
				"id", 
				"string",
				"alias",
				"subvert"
			}

			for xxnn,v in ipairs(keys)
			do
				if t[v] then
					shuffle(validation, t[v], v, "E.links")
				end
			end

         ------------------------------------------------------
			-- Run through logic here for different payload
			-- formats.
         ------------------------------------------------------
			local links = {}
			for __,link_group in ipairs(groupnames) -- href.group[href.group] )
			do
				-- Use a custom string for link dumps.
				if t and t.string and t.string[link_group]
				then
					local g = groups[link_group]

					for link_value, lxid in pairs(g.members) do
						local new_string = string.gsub(tostring(t.string[link_group]), '%%s', link_value)
						table.insert(links, new_string) 
					end

				-- Move through the rest.
				else
					local g = groups[link_group]
					local xg = groups[ xhr.ns .. link_group ] 

					-- Modify your xhr group here, this is an ugly hack...
					if xg and g.url_root then
						xg.url_root = g.url_root
					end

					for ltit, lxid in pairs(g.members) do
						-- Routes...
						local x = routes[lxid]

						-- Make a new link.
						table.insert(links, table.concat({
							-- Start the tag.
							'<a href=', 
							-- Relative root and resource name.
							'"', tostring(g.url_root or "/"), ltit, '"', 
							-- Class Name.
							(function ()
								return string.set(
									table.concat({x.xhr_mask or "",g.class or "",}," "), 
								" class")
							end)(),
							-- ID name
							(function ()
								-- ifthen(g.id, string.set(ltit, " id"), "")
								if g.id then
									return string.set(ltit, " id")
								else 
									return "" 
								end
							end)(),
							-- Close the opening tag.
							">",
							-- Resource name or alias.
							x.alias or ltit,
							-- Close the entire tag.
							"</a>\n"
						}))	
					end -- for __,link_value in ipairs(eval.group[link_group])
				end -- if t and t.string and t.string[link_group]
			end -- for __,link_group in ipairs(group)

			-- Reset to defaults, letting another link chain do work if specified.
			-- ??
			-- Return link list to environment.
			return table.concat(links,"\n")
	
		-- Catch bad arguments to E.links()
		else
			die.xtype(t, { "string", "table" })
		end -- if not t 
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
		-- Set a function name for errors.
		local fname = "E.xhr"

		-- Some xhr related functions that don't quite fit anywhere else yet.
		-- autobind is the first
		-- bind may be the second.
		-- Most of this stuff is static, so it shouldn't be a big deal.
	
		-- Pull everything out of t and start processing XHR logic.
		if t then
			------------------------------------------------------
			-- Start off a Javascript string.
			------------------------------------------------------
			table.insert(xhr.js, '<script type="text/javascript">')
			
			------------------------------------------------------
			-- Logic for all the accepted datatypes.
			------------------------------------------------------
			local validation = {
				------------------------------------------------------
				-- validation.autobind {} 
				--
				-- This table is intended to be used with the interface
				-- function 'shuffle'.  
				--
				-- If supplied by the developer, autobind will accept
				-- datatypes of alpha table and string.  If it is an
				-- alpha table; the table's keys can corresponds to 
				-- either an ID in the DOM or a symbolic name specified
				-- at [?](symbol or E.autobind). 
				--
				-- If the matching value for the key is a numerically 
				-- indexed table, then each value in that table is 
				-- expected to be a resource called in E.set(). If the
				-- value is an alphanumerically indexed table, then 
				-- each value's key should point to a group, while
				-- the value's value should point to that group's
				-- resources.
				--
				-- *nil
				------------------------------------------------------
				autobind = {
					datatypes = { "atable", "ntable", "string" },
					_ntable = function (x)
						local bound_name
						for xx,yy in pairs(x) do
							-- Set any available resources.
							if type(xx) == 'string' then
								-- Check if the bound exists in some propensity. 
								-- Create it if it doesn't.
								--[[
								bound.create({ dom_element = "yourmom" })
								die.quick(bounds[ (table.keys(table.retrieve_non_matching({"info"},bounds)))[1] ])
								if not bound.exists( xx ) then
									bound_name = bound.create({ dom_element = x }, true)
								end
								--]]
								bound_name = bound.create({ dom_element = xx }, true)

								-- Move through the table setting crap.
								if type(yy) == 'table' then
									for kk,vv in pairs(yy) do
										if type(kk) == 'string'
										then
											-- Check if an XHR group exists.  Create if not.
											xhr_n = xhr.ns .. kk 	-- XHR group name.  ifnot ifthen
											if not group.exists( xhr_n ) 
											then
										  		-- Create a fake group.
										  		group.clone( kk, xhr_n )
									  		end

											-- Group table lookup
											local glookup

											-- If it's a boolean, every member of group kk should be autobound.
											if type(vv) == 'boolean' then
												glookup = groups[xhr_n]["members"]

											-- If it's a table, every member in table belonging to group kk should be auto
											elseif type(vv) == 'table' then
												-- Break this up...
												glookup = vv
												-- You need to check these values too...
											-- If it's a string, only that single member of group kk should be auto
											elseif type(vv) == 'string' then
												glookup = { vv = groups[xhr_n]["members"][vv] }
											end
						
									  		-- Set up the new resources.	
									  		-- die.quick(groups[xhr.default]["members"])
									  		for mb_name, mb_xid in pairs(glookup) do
												local xmask = "__" .. mb_name -- Set up an xhr name.
										 		route.modify({
										 			xid = mb_xid, -- Modify resource in question.
										 			autobound = bound_name, -- Assign to bound name.
										 			xhr_name = "__" .. uuid.alpha(10), -- wtf is this?
										 			xhr_preferred = true, -- xhr preference is true for payload
										 			name = xmask, -- The original href.
										 			xhr_mask = mb_xid,  -- ???
										 			xhr_name = "__" .. uuid.alpha(10), -- Might be the location...
										 		-- xhr_href = xmask 	-- XHR href (that our JS will ask for)
													xhr_href = (function (gname)	-- XHR href (that our JS will ask for)
														return function ()
															return table.concat({groups[gname]["url_root"] or "/", xmask})
														end
													end)( xhr_n )
												})
											end

										-- Move through all the members of the table, binding them to payload. 
										elseif type(kk) == 'number'
										then 
											-- Check if an XHR group exists.  Create if not.
											xhr_n = xhr.ns .. default 
											if not group.exists( xhr_n ) then
										  		-- Create a fake group.
										  		group.clone( default, xhr_n )
									  		end

											if type(vv) == 'string' then
												-- Find 
												local xid = routes[route.named( vv, default )]
												if xid then
													route.modify({
													  	xid = xid, -- Modify resource in question.
													  	autobound = bound_name, -- Assign to bound name.
													  	xhr_preferred = true, -- xhr preference is true for payload
													  	name = xmask, -- The original href.
													  	xhr_mask = mb_xid,  -- ???
													  	xhr_name = "__" .. uuid.alpha(10), -- Might be the location...
														xhr_href = (function (gname)	-- XHR href (that our JS will ask for)
															return function ()
																return table.concat({groups[gname]["url_root"] or "/", xmask})
															end
														end)( xhr_n )
													})
												end	
											end
										end -- if type(kk) == 'string'

										-- Modify the default class that stuff can be done.
										group.modify( xhr_n, {
										-- Remove all the "original" members.
										members = (function ()
											local aa = {}
												for k,v in pairs(groups[xhr_n]["members"]) do
													aa["__" .. k] = v
													groups[xhr_n]["members"][k] = nil 
												end
												return aa
										end)()
										})
									end

								-- hi
								elseif type(yy) == 'string' then
									local xmask = "__" .. mb_name -- Set up an xhr name.
								 	route.modify({
								 		xid = mb_xid, -- Modify resource in question.
								 		autobound = bound_name, -- Assign to bound name.
								 		xhr_preferred = true, -- xhr preference is true for payload
								 		name = xmask, -- The original href.
								 		xhr_mask = mb_xid,  -- ???
								 		xhr_name = "__" .. uuid.alpha(10), -- Might be the location...
										--[[
								 		xhr_href = (	-- XHR href (that our JS will ask for)
								 			groups[xhr_n]["url_root"] or "/" ..
											xmask
								 		)
										--]]
										xhr_href = (function (gname)	-- XHR href (that our JS will ask for)
											return function ()
												return table.concat({groups[gname]["url_root"] or "/", xmask})
											end
										end)( xhr_n )
								 	})

									-- Modify the default class that stuff can be done.
									group.modify( xhr_n, {
										-- Remove all the "original" members.
										members = (function ()
											local aa = {}
											for k,v in pairs(groups[default]["members"]) do
												aa["__" .. k] = v
												groups[xhr_n]["members"][k] = nil 
											end
											return aa
										end)()
									})
								end

							
							elseif type(xx) == 'number' then
								-- String sets all defaults to autobind to the one. 
								if type(yy) == 'string' then
								-- Simple table to sets all defaults to autobind to each value in the table.
								elseif type(yy) == 'table' then
								else
									die.xerror({
										fn = "E.serve",
										msg = "%f"	
									})
								end
							-- Fail mightily on any other type.
							else
								die.xerror({
									fn = "E.serve",
									msg = "%f"	
								})
							end
						end
					end,

					_atable = function (x)
					end,

					_string  = function (x)
						-- Create an XHR group name for defaults.
						xhr.default = xhr.ns .. default

						-- Create a bound. 
						local bound_name = bound.create({ dom_element = x }, true)

						-- Create a fake group.
						-- group.clone( default, xhr.default )
						group.inherit( default, xhr.default )

						-- Set up the new resources.	
						-- die.quick(groups[xhr.default]["members"])
						for mb_name, mb_xid in pairs(groups[default]["members"]) do
							-- Set up an easy xhr name.
							local xmask = "__" .. mb_name

							-- Choose to modify the resource in question.
							route.modify({
								xid = mb_xid, 
								-- Match to the bound point.
								autobound = bound_name,
								-- Set XHR preferred value.
								xhr_preferred = true,
								-- Add the original name.
								name = xmask,
								-- Set an XHR mask.
								xhr_mask = mb_xid,
								-- Set an XHR class.
								xhr_name = "__" .. uuid.alpha(10),
								-- Set a new href.
								xhr_href = (function (gname)	-- XHR href (that our JS will ask for)
									return function ()
										return table.concat({groups[gname]["url_root"] or "/", xmask})
									end
								end)( xhr.default )
							})
						end

						-- Modify the default class that stuff can be done.
						group.modify( xhr.default, {
							-- Remove all the "original" members.
							members = (function ()
								local aa = {}
								for k,v in pairs(groups[default]["members"]) do
									aa["__" .. k] = v
									groups[xhr.default]["members"][k] = nil 
								end
								return aa
							end)()
						})
					end,
				} -- autobind
			}

			-- Get all keys from t.	
			-- t = table.retrieve(table.keys(xmlhttp), t)

			-- Cycle through each.
			for n,v in pairs(t) do	
				if n == 'autobind' then
					if t[n] then
						shuffle(validation, t[n], n, fname)
					end
				end
			end

			-- Dump the Javascript.
			xhr.status = true
		end
	end,


	------------------------------------------------------
	-- js_dump()
	--
	-- Return the javascript dump in oh so ghetto fashion.
	-- *string
	------------------------------------------------------
	js_dump = function ()
		-- Dump any Javascript scaffolding that's been generated.	
		for __,tt in ipairs({ bounds, routes }) 
		do
			if next(tt) then
				table.insert(xhr.js, 
				  -- "var x = { " ..  -- ".. tt.info.ns .." = {"..
				"var ".. tt.info.ns .." = {"..
				(function (t) 
				  -- Create an anonymous table.
				  local xt = {}
				  local ft = table.retrieve_non_matching({"info"}, t)	

				  -- Move through all indexes.
				  for ename, et in pairs(ft) do
					  if tt.info.ns == '__ROUTES__' and et.xhr_preferred 
					  then
						  table.insert(xt, 
							  convert.object({
								  location = et.autobound,
								  xhref = et.xhr_href(),
								  href = et.href,
							  }, ename))
					  elseif tt.info.ns == '__BOUNDS__' then
						  table.insert(xt, 
							  convert.object({
								  hide = et.hide,
								  show = et.show,
								  is_id = et.is_id,
								  is_class = et.is_class,
								  dom_e = "function () { return "..et.dom_element .."}",
								  animate = et.animate,
							  }, ename))
					  end
				  end
			  
				  -- Return payload.
				  return table.concat(xt,",") or ""
			  end)(tt)
			  .. "};")
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
			-- Define some starter details.
			local payload
			local groupn = group_sel or default
			local g = groups[groupn] 
			local xgn = xhr.ns .. groupn

			-- Better check if alternate groups exist first.
			if not g then
				die.xerror({
					fn = "E.serve",
					msg = "The group ["..tostring(groupn).."] does not exist at %f."
				})
			end

			-- Set defaults and stuff.
			local req = req or g["default"] 
			local gt = table.keys(
				table.retrieve_non_matching({default}, groups)
			)

			-- Die if grouped resoures were selected.
			if not groups[default] and gt and table.maxn(gt) > 0 then
				if not group_sel then
					die.xerror({
						fn = "E.serve", -- ifn links to internal functions
						msg = "Groups exist at <b>function</b> <i>E.set()</i>, " ..
							"but no default group "..
							"payload has been specified at %f."
					})
				end
			end

			-- Die on no default.
			if not g.default then
				if groupn == default then
					die.xerror({
						fn = "E.serve",
						msg = "No default payloads mapped for the "..
						" default group at %f."
					})
				else
					die.xerror({
						fn = "E.serve",
						msg = "No default payload has been mapped for the group '"..
						tostring(group).."' at %f."
					})
				end
			end

			-- if XHR true?
			local rxid, jxid, nxid
			-- If xhr is on, AND the resource is not in your main group, then look to see if it's 
			-- in another group.	
			if xhr.status then
				-- If you are just doing regular requests, this is your choice.
				nxid = routes[route.named(req, groupn)]
				-- XHR is this one.
				jxid = routes[route.named(req, xgn)]
				-- Set it properly.
				rxid = nxid or jxid
			-- XHR isn't on, so do regular stuff.
			else
				-- Routes
				rxid = routes[route.named(req, groupn)]
			end

			-- 404 or proceed if the name isn't a listed resource.
			-- die.quick(groups[groupn])
			-- local rxid = routes[route.named(req, groupn)]
			if not rxid then
				-- Fail with a 404.
				if g.fail.level and not is.value(req, g.fail.except) then
					die.with(404, {
						msg = "Cannot find page: " .. req .. "."
					})
				-- If not, just use the default resource.
				else
					rxid = routes[route.named(g.default, groupn)]
				end
			end

			-- Default is to find functions first...
			if type(rxid.execution) == 'function' 
			then
				-- If there's an error, payload will die here.
				payload = interpret.funct( rxid.execution ) or "" 
			elseif rxid.include 
			then
				-- ..then pages. Skels are searched for first, then html files.
				for _,inc in ipairs({"skel","html"})
				do
					payload = add[inc]( rxid.include )
					if payload then break end 
				end

				-- Die somehow if payload's still not present.
				-- 404 seems like the correct response.
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
		 --[[
		  die.quick(table.concat({
			  "default: " .. table.dump(groups[default]["members"],true),
			  xgn .. ": " .. table.dump(groups[xgn]["members"],true),
		  }))
		  --]]
			if groups[xgn] and is.key(req, groups[xgn]["members"])
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
		local group = group_sel or default

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
					_number = function (x) 
						fail.level = x 
					end,
				},
				default = {
					datatypes = "number",
					_number = function () 
					end,
				},
				fail = {
					datatypes = { "boolean", "atable" },
					_boolean = function () 
					end,
					_atable = function () 
					end,
				},
				fs_root = {
					datatypes = { "string", "atable" },
					_string = function () 
					end,
					_atable = function () 
					end,
				},
				order = {
					datatypes = { "ntable" }, 
					_number = function () 
					end,
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
