------------------------------------------------------
-- debug.lua 
--
-- Debugging stuff. 
------------------------------------------------------
------------------------------------------------------
-- time {} 
--
-- Clocking. 
------------------------------------------------------
local time = { 
	start = 0, 
	finish = function () return os.time() end
} 

-- Set up the style block.
local d_style_block = {}

------------------------------------------------------
-- cdef {} 
--
-- Console defaults. 
------------------------------------------------------
local cdef = {	
	name = {
		console 	= "__console",		-- Debugging console
		timing 	= "__timing",		-- Timing data.
		backend 	= "__backend",		-- Backend data. (Append w/ console.out())
		frontend = "__frontend",	-- Frontend data. (Append w/ stdout_debug())
		vault 	= "__vault",		-- Secure data like cookies and sessions.
	},
	right = "1%",
	padding = "1%",
	bg = "black",
	mh = "14px",
	fg = "white",
	family = "monospace",
	size = "11px"	-- If this is a number, then px should be auto, maybe.
}

------------------------------------------------------
-- tags {} 
--
-- Each tag.  Populate these from the above.
------------------------------------------------------
local tags = {
	-- All types of the following are strings or integers
	-- Configure the div.
	"name",

	-- Configure positioning.
	"left", 
	"right", 
	"width", 
	"height",
	"padding",

	-- Font messing abouts. 
	"color", "fgcolor", "fg",
	"size",

	-- Background styling.
	"background-color", "bgcolor", "bg",
	"background-image", "img",

	-- Type of "omit" can be a table (or string) 
	"omit",
	"family",
}


return {
	------------------------------------------------------
	-- .vert(t)
	--
	-- Use a vertical console by default.  Configure any 
	-- specific items via table [t].
	--
	-- *nil 
	------------------------------------------------------
	vertical = function (t)
		-- die.xnil(t, "console.vertical")
		
		local ctags = table.union(tags, {
			-- Bools
			"bottom",
			"top",
		})

		local this = {}
		if t then 
			this = table.retrieve( ctags, t )
		end

		-- Add to the defaults
		cdef.height = "90%"
		cdef.width = "300px"

		-- bottom or top?
		if this.bottom then 
		elseif this.top then
		end

		-- Color stuff.  
		-- fg = { ... } -- you need something that can check multiple levels of or clauses
				-- to elaborate a lil more:
				-- text-color or fgcolor or fg or ...	

		-- Send an inline style. 
		table.insert( d_style_block, 
			_.style({ type = "text/css" },

				table.concat({
					-- Entire console window.
					"\n#" .. ((cdef.name.console) .. " {\n\t") ..
					table.concat({
						-- (this.name or cdef.name.console) .. " {\n\t",
							"position: fixed",
							"overflow: auto",
							"z-index: 99",
							"border-radius: 10px",
							"-moz-border-radius: 10px",
							"opacity: 0.8",
							"filter:alpha(opacity=80)",
							"-webkit-border-radius: 10px",
							"top: 2.5%",
							(function()
								if this.left then
									return "left: " .. (this.left or cdef.left)
								elseif this.right then
									return "right: " .. (this.right or cdef.right)
								else return "right: " .. cdef.right
								end
							end)(),					
							"height: " .. (this.height or cdef.height),
							"width: " .. (this.width or cdef.width),						
							"padding: " .. (this.padding or cdef.padding),
							"font-size: " .. (this.size or cdef.size),
							"font-family: " .. (this.family or cdef.family),
							"background-color: " .. (this.bg or cdef.bg),
							"color: " .. (this.fg or cdef.fg),
							"margin-bottom: " .. (this.mh or cdef.mh),
						},";\n\t")
					.. ";\n}\n",

					-- Timing window.
					"\n#" .. ((cdef.name.timing) .. " {\n\t") ..
					table.concat({
						"background-color: white",
						"color: black",
						"padding: 5px",
						"margin: 5px",
					},";\n\t")
					.. ";\n}\n",

					-- Details window.
					"\n#" .. ((cdef.name.vault) .. " {\n\t") ..
					table.concat({
						"background-color: gray", 
						"padding: 5px",
						"margin: 5px"
					},";\n\t")
					.. ";\n}\n",
						
						-- Frontend window.
					"\n#" .. ((cdef.name.backend) .. " {\n\t") ..
					table.concat({
						"background-color: green", 
						"padding: 5px",
						"margin: 5px"
					},";\n\t")
					.. ";\n}\n",

					"\n#" .. ((cdef.name.frontend) .. " {\n\t") ..
						table.concat({
						"background-color: red",
						"padding: 5px",
						"margin: 5px"
						},";\n\t")
					.. ";\n}\n",

					"\n.__smallish { font-size: 8px; letter-spacing: 1px; text-transform: uppercase;}",
					"\na.__debugging { font-size: 7px; letter-spacing: 1px; }",
					"\nli.__debugging { list-style-type: none; }"
				}) -- table.concat({ 
			)) 
	end,

	------------------------------------------------------
	-- .horiz(t) 
	--
	-- Use a horizontal console by default.  Configure any 
	-- specific items via table [t].
	--
	-- *nil 
	------------------------------------------------------
	horizontal = function (t)
		local this = table.retrieve({
			"name",
			"left", "l",
			"right", "r",
			"width", "w",
			"height", "h",
			"padding", "p",
			"background-color", "bgcolor", "bg",
			"text-color", "fgcolor", "fg",
			"omit"
		},t)

		-- Send an inline style. 
		table.insert( d_style_block, 
			_.style({ type = "text/css" },
				table.concat({
					"position: fixed",
					";\n}"
				},";\n")))
	end,

	------------------------------------------------------
	-- .timing(t)
	--
	-- Fine tune as much data as possible when using the
	-- timing library.
	--
	-- *nil
	------------------------------------------------------
	timing = function (t)
	end,

	------------------------------------------------------
	-- .config(t)
	--
	-- Don't let kirk configure any console styling for
	-- you.  Do it all yourself.
	--
	-- *nil 
	------------------------------------------------------
	config = function (t)
	end,

	------------------------------------------------------
	-- .show() 
	--
	-- Show the configured console.
	--
	-- *string 
	------------------------------------------------------
	show = function (s)
		return table.concat({
			table.concat( d_style_block ),
			_.id("__console", table.concat({ 

				-- Show timing information.
				_.id("__timing", 
					_.span("__smallish", "Request generation time: ") .. 
					19.123123123 ..  " secs "), 
				--	(os.time() - TIME) ),

				-- Application information.
				_.id("__backend", 
					_.div("__smallish", "Backend: ") .. 
					"Application Information: " .. _.i("none")),

				-- Show JS.
				_.id("__frontend", 
					_.div("__smallish", "Frontend: ") .. 
					"Application Information: " .. _.i("none")),

				-- Show session.
				_.id("__vault", 
					_.div("__smallish", "Private Data: ") .. 
					"Application Information: " .. _.i("none")),
			})),
[[
<script type="text/javascript">
	init_debug();
//	ab_break();
</script>
]]	
		},"\n")
	end,
}
