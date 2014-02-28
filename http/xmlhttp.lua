------------------------------------------------------
-- xmlhttp.lua 
--
-- Standard XML HTTP requests.
-- 
-- More
-- XML Http
--
-- Conceptual Details
-- *Planning
-- This module needs to be as close to pure Lua as
-- possible to reduce code negotiation when setting up
-- new instances.  Adding Javascript to the mix when
-- updating applications and instance interfaces will
-- make Pagan too complex and moreover overextend it's
-- reach.  Pagan is still a server-side framework and
-- it's problem domain will always be web server to 
-- application interaction.
-- 
-- That said, Javascript and the ubiquity of asynchronous
-- socket calls makes having some way to integrate Javascripts
-- very important to the success of the project.  In
-- order to accomplish this, Pagan supports two structures
-- that make interaction with Javascript and any other
-- solid front-end frameworks as simple as possible.  
-- 
-- Frameworks like Backbone.js, Zepto, jQuery, Express
-- and so on already handle the issue of MVC in the 
-- Javascript world fairly well.  There is no good 
-- reason for this server-side framework to complicate
-- that.   
--
-- *How it works
-- Because of the requirements above, Pagan handles core
-- Javascript functionality like XmlHTTPRequests and data
-- interchange through specific modules.  
--
-- Data interchange is handled by interface/http/serialization.lua, 
-- where JSON, XML, and other open formats with some sort of ubiquity
-- are well supported.
-- 
-- The actual XMLHttpRequest handling is done via server-side
-- requests in a way that is nearly transparent to the user.
-- It also takes into account the concept of graceful degradation,
-- where browsers with limited and/or no Javascript functionality
-- will still be able to access and browse the resources on a 
-- site in a normal fashion.
--
-- Note that these functions will not actually create static files
-- to handle the front end work (unless generated ahead of time 
-- that is).  Script includes call a resource that returns a document
-- of type "text/javascript" to keep your front-end, HTML and backend
-- source code clean and seperate.
-- 
-- pg.xhr will control the default behavior here.  And of course,
-- options will control whether or not to include this by default.
--
-- *Extending eval.lua to accomodate XHR
-- Option one is to bind __js__ to evals that require it.
-- The xmlhttp script must do this in order to work, and additionally
-- be able to be disabled.  You also must modify E.serve to search
-- for a __js__ request and still work with "single" resources.
------------------------------------------------------
local xhr = E.xhr()

------------------------------------------------------
-- js {}
--
-- Functions dealing with Javascript interaction. 
------------------------------------------------------
local js = {
	------------------------------------------------------
	-- local set( e, name ) 
	--
	-- Assign [e] to variable [name]  
	-- *nil
	------------------------------------------------------
	set = function( e, name )
		return name .. ' = "' .. e .. '"'
	end,


	------------------------------------------------------
	-- local pkg( )
	--
	-- Wrap what you're doing in <script> tags.
	-- *string
	------------------------------------------------------
	pkg = function ( e )
		--return _.script({ type = "text/javascript" }, e )
		return string.format("<script type='text/javascript'>%s</script>",e) 
	end,

	------------------------------------------------------
	-- local arrayify(t) 
	--
	-- Turn everything in [t] into a Javascript array.
	-- *string
	------------------------------------------------------
	arrayify = function ( t, name ) 
		-- Store in [name] all elements in [t].	
		local js, rsrc = {}, "var " .. name .. " = [" 
		for _,v in ipairs(t) do
			table.insert(js, "'" .. v .. "'")
		end 

		return table.concat( {rsrc, table.concat(js,","), "];"} )
	end,


	------------------------------------------------------
	-- .test()
	--
	-- Modify an object and see if we get a response
	-- back.
	-- *boolean
	------------------------------------------------------
	test = function () 
	end,


	------------------------------------------------------
	-- .serve(t, name) 
	--
	-- Serve some JS and let pagan.js work in the
	-- background. 
	-- *nil
	------------------------------------------------------
	serve = function (t,name)
		-- 200 only if no issues...
		response.abort({200,"text/javascript"}, arrayify( t ) )
	end
}


------------------------------------------------------
-- public methods {} 
------------------------------------------------------
return {
	------------------------------------------------------
	-- get() 
	--
	--  
	------------------------------------------------------
	get = function ()

	end,

	------------------------------------------------------
	-- post() 
	--
	--  
	------------------------------------------------------
	post = function ()

	end,


	------------------------------------------------------
	-- .autobind(t,location) 
	--
	-- Autobind your requests to resultant anchor tags from 
	-- E.links.  
	--
	-- // More 
	-- Fallbacks (or graceful degradation) are automatically 
	-- accounted for when throwing the autobind function.  
	-- 
	------------------------------------------------------
	autobind = function (t,location)
		------------------------------------------------------
		-- Test that XHR will work.
		------------------------------------------------------
		P( js.pkg( js.set( location, '__LOCATION__' ) ))
		P( js.pkg( js.arrayify( t, '__rsrc__' ) ))
		E.xhr(t)
	end,

	ab = function ()
		E.xhr(t)
	end,

	-- Everything here will override regular form submits. 
	post = function ()
	end,

	-- These map to functions, but div thing is not standard
	bind = function ()
	end,

	-- Use animation when doing basic requests.
	animate = function ()
	end,

	-- Set hide speed
	hide = function ()
	end,

	-- Set show speed
	show = function ()
	end,
}
