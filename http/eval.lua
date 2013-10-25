------------------------------------------------------
-- eval.lua
--
-- Standardizes the response to resource requests.
--
-- // Rules 
-- eval.lua is globally included as E.  No additional
-- calls are needed to introduce it within the scope 
-- of your application. 
--
-- // More
-- When eval.lua is properly set within an application,
-- at least three functions will be called.   
--
-- First, E.set({t}) with a table [t], will stage a 
-- list of available resources to be used with an 
-- application.  
--
-- If [t] is a numerically indexed table,
-- like <pre>{ "john", "mary", "joan" }</pre>, then
-- there are no other rules needed to reference that
-- block of resources.  
--
-- If [t] is an alphabetically indexed table, <pre>
-- { ["joan"] = "x", ["joe"] = "bob" }</pre>, then
-- subsequent calls to eval.lua will need you to
-- explicitly define which module you'd like to modify.
--
-- Second, you'll have to utilize E.default(t). When
-- E.set() has been used to define a numerically indexed
-- set of resources, a string [t] must be used to 
-- define a default resource.  However, if E.set() was
-- used to define alphabetically indexed resources, then
-- [t] must be a table (or more specifically a key-value
-- pair) defining a default resource. 
--
-- Finally, E.serve([t],n) must be called to return
-- the body of the resource defined under E.set().  
-- This form of E.serve([t],n), is only used when 
-- E.set() has been used to define an alphabetically 
-- indexed table of resources.   The [t] may be omitted
-- when E.set() has been used to define numerically 
-- indexed resources. 
--
-- The [n] portion of E.serve() will always reference
-- a number that defines which portion of the URL to use
-- as the "resource trigger" (if you will).  So calls 
-- like:
-- <pre>
-- E.serve(2) 
-- </pre>
-- would search a URL (http://pagan.vokayent.com/x/y/z) 
-- for the second node.  (In this case, "y".).  E.serve()
-- will then check the table supplied in E.set() for
-- anything mapped to "y".  If nothing is available, 
-- E.serve() will supply the results of whatever is mapped
-- as default by E.default(). 
--
-- Any additional functions and modules work this way.
-- If modifying resources in alphabetically referenced
-- tables, the name of the module you want modified
-- will always be the first argument.
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
local rsrc

-- XHR has to be accessible to a few different members.
-- This may possibly be something that needs to be handled
-- another way.
-- like:
-- members = { 'x' 'y' 'z' } where members are "required()" during serving 

------------------------------------------------------
-- eval {}
--
-- Public functions for serving pages. 
------------------------------------------------------
return {
	------------------------------------------------------
	-- alias(t)
	--
	-- Set aliases (for pages that are not document root).
	-- [t] must be a named table pointing to some key
	-- defined within E.set().
	--
	-- *nil
	------------------------------------------------------
	alias = function (t)
		if t 
		 and not request.alias
		then
			request.alias = {}
		end 

		for k,v in pairs(t) do 
			request.alias[k] = v 
		end
	end,

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
	-- .order( t )
	--
	-- Reorder links. 
	-- *table
	------------------------------------------------------
	order = function (t)
		local o = {}
		table.sns(t,o)
		return o	
	end,

	------------------------------------------------------
	-- .run( f, level, map )
	--
	-- Run a function according to a specific resource.
	--
	-- *string, *table, *number or *nil
	------------------------------------------------------
	run = function (f,level,map)
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
	-- .set(t)
	--
	-- Set up what routes we'd like to work with.
	--
	-- *nil
	------------------------------------------------------
	set = function (e)
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
	-- .subvert(t)
	--
	-- Removes resource defined by [t] from the list of
	-- available links shown by E.links(). [t] can be
	-- a string when E.set() has been used with a 
	-- numerically indexed table.  Otherwise, [t] must be 
	-- a {[key] = value} pair in which [key] points to the
	-- resource set you'd like to run E.subvert() on.
	--
	-- *nil
	------------------------------------------------------
	subvert = function (t)
		-- One value to subvert, you lucky guy you...
		if type(t) == 'string' then
			request['subvert'] = t 

		-- Many values to subvert, you lucky guy you...
		elseif type(t) == 'table' then
			if is.ni(t) then
				request['subvert'] = t 
			else
				for k,v in pairs(t) do
					request['subvert'] = {}
					request["subvert"][k] = v 
				end
			end
		end
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
	links = function (map,reps)
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
	-- .serve(int,xpath)
	--
	-- Serves resource requested.
	-- No (int) means serve a primary resource.  int can be
	-- 2,3 or 4 -- indicating how deep you want Pagan to
	-- delve into the url structure.
	--
	-- Does not serve private data.
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
 
	------------------------------------------------------
	-- request {}
	--
	-- Pieces of the request that should be publicly
	-- available.
	------------------------------------------------------
	request = {
		block = function () return request.block end,
		default = request.default,
	},
		
	------------------------------------------------------
	-- .on_error(err)
	--
	-- Set an error for general inclusion and execution
	-- errors.
	------------------------------------------------------
	["error"] = function (err)
		if err
		then
			request.err = err
		end
	end,

	------------------------------------------------------
	-- .on(r,f) 
	--
	-- For everything in a table, execute this function. 
	-- Subverts default .serve method.
	--
	-- *table, *string or *number
	------------------------------------------------------
	on = function (r,f)

	end,

	------------------------------------------------------
	-- .xhr {} 
	--
	-- Shuttle the XHR table.
	-- No argument returns it, supplying t will inject
	-- it.
	--
	-- Critical: Must handle strings...
	--
	-- *nil
	------------------------------------------------------
	xhr = function (t) 
		if type(t) == 'table' then 
			xhrt = t
		elseif not t then
			return xhrt 
		else
			response.abort({500}, "xhr() received wrong type.")
		end
	end,
}
