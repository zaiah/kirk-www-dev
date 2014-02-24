E.links({
   as      = [table, string] 		-- Output link list as table or string.
   root    = [string]        		-- Creates href relative to [root].
   class   = [string]       		-- A class name for each.
   id      = [bool]          		-- Use the resource name as an id.
   string  = [string]        		-- Use this string as the link dump.
   subvert = [string, table] 		-- Do not include these resources as links.
   group   = [string]        		-- Choose a resource group if many have
                            		-- been specified.
   alias   = [table]         		-- Choose which resources to serve
                            		-- with an entirely different link name.
})

E.xmlhttp = {
	autobind = {					-- Choose to bind resources to ID's or classes...
		[x] = [string or table],
		[y] = [string or table],
	},
	bounds   = {					-- Define "aliases" for elements to bind to.
		[x] = ".fool",              -- The class .fool can be referenced by [x] now.
		[y] = "#mega",              -- The ID mega can be referenced by [y] now.
	},
	animate  = {                    -- Bind an animation to some elements.
		[x] = [number or table],
		[y] = 300 or { start = 300, end = 300}
	},
 [show,hide] = [number or table],   -- Set show and hide speed for elements.
 [show,hide] = 300 -- or
 [show,hide] = { 
		[x] = 300
	},
	post 	= [string or table]
}

E.fail({                            -- Fail with a 404 if resources at n are not found.
	level 		= [number]          -- at level [number]
	resources 	= [string, table]   -- If these resources are received, then it's ok.
	group 		= [string]          -- Only fail with unavailable resources from this group.
	message     = [string]          -- Choose a different message for the default 404 page.
	resource    = [string]          -- Choose a particular resource for serving 404 pages.
	                                -- Keep in mind that pg can also serve custom error pages.
})              

E.default(x, [{a = "b", c = "d"}])  -- Set a default resource

E.include(n, "home")                -- Kind of like pg.pages, but instead of statically defining
                                    -- the pages table, use this to do it dynamically.

E.run(f, level)                  	-- Run a function on receipt of a resource.

E.serve(n, [group])             	-- Serve resource at data.url[n] (at group <group> if specified)

E.autobind(t, location)             -- Expect payloads over XMLHttp for each resource in [t], where
                                    -- [t] can be either string or table.