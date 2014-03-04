E.autobind({
	point = {					-- Set some points.
		x = "#wallace",					-- An ID field
		y = ".prizm",					-- Another
		z = { ".4sdf", ".sdfsdf" }, 	-- Multiple classes.
		g = ".julius"  
	},
	
	to = {						-- Define what exactly to bind to.
		x = { "var", "var2", "var3" },	-- We defined "#wallace" as x above.  All values in the
		                                -- table will return their payloads there.
		y = { g = { "v4", "v5" } }, 	-- Only values belonging to group "g" will 
		                                -- return their payloads to .prizm.
		z = { peter = "*" } 			-- Everything in the group peter will return their
	},	                                -- payloads to classes .4sdf and .sdfsdf
})


E.xhr({
	bind...
	...
	...
	...
	autobind = {
		point = {					-- Set some points.
			x = "#wallace",					-- An ID field
			y = ".prizm",					-- Another
			z = { ".4sdf", ".sdfsdf" }, 	-- Multiple classes.
			g = ".julius"  
		},
		
		to = {						-- Define what exactly to bind to.
			x = { "var", "var2", "var3" },	-- We defined "#wallace" as x above.  All values in the
											-- table will return their payloads there.
			y = { g = { "v4", "v5" } }, 	-- Only values belonging to group "g" will 
											-- return their payloads to .prizm.
			z = { peter = "*" } 			-- Everything in the group peter will return their
		},
		
		class = {
			jaybob = "__jaybob"     -- Either for clarity or to save space.
			                        -- A resource named jaybob will have a class called __jaybob??
		}
	},
	
	autobind = "#julius"            -- Everything will open at #julius
})