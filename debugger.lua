------------------------------------------------------
-- debug.lua 
--
-- Debugging stuff. 
------------------------------------------------------

local time = { 
	start = 0, 
	finish = function () return os.time() end
} 

return {
	console = function (s)
		-- I can bag this style with the framework.
		P(
			_.style({type = 'text/css'},[[
.__console { 
	position: fixed;
	bottom: -10px;
	left: 0px;	
	z-index: 99;
	height: 50px;
	width: 100%;
	padding: 10px;
	background-color: black;
	color: white;
}

.__timing {
	color: green;
	width: 100px;
}
.__server_side {
}
.__tables {
}
.__external {
}
			}]]) ..

		_.div("__console", table.concat({ 
			"???" .. tostring(s),
			_.div("__timing", "Page load time: " .. 19.12312312312213 .. 
				(os.time() - TIME) ),
			_.div("__external", "Application Information: " .. _.i("none")),
			}))	
		)
	end,
}
