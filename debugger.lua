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
		console = "__console",
		timing = "__timing",
		server_side = "__server_side",
		tables = "__tables",
		external = "__external",
	},
	left = "0px",
	padding = "10px",
	bg = "black",
	mh = "14px",
	fg = "white",
	size = "10px"	-- If this is a number, then px should be auto, maybe.
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
	"left", "l",
	"right", "r",
	"width", "w",
	"height", "h",
	"padding", "p",

	-- Font messing abouts. 
	"color", "fgcolor", "fg",
	"size",

	-- Background styling.
	"background-color", "bgcolor", "bg",
	"background-image", "img",

	-- Type of "omit" can be a table (or string) 
	"omit",
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
		local ctags = table.union(tags, {
			-- Bools
			"bottom",
			"top",
		})

		local this = table.retrieve( ctags, t )

		-- Add to the defaults
		cdef.height = "100%"
		cdef.width = "200px"

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
				"\n#" .. 
				((cdef.name.console) .. " {\n\t") ..
				table.concat({

					-- Console.
					-- (this.name or cdef.name.console) .. " {\n\t",
						"position: fixed",
						"overflow: auto",
						"z-index: 99",
						"left: " .. (this.left or cdef.left),						
				--		"right: " .. (this.right or cdef.right),						
						"height: " .. (this.height or cdef.height),						
						"width: " .. (this.width or cdef.width),						
						"padding: " .. (this.padding or cdef.padding),						
						"font-size: " .. (this.size or cdef.size),						
						"background-color: " .. (this.bg or cdef.bg),						
						"color: " .. (this.fg or cdef.fg),
						"margin-bottom: " .. (this.mh or cdef.mh),

					-- Timing if asked for.

					-- Other omits...
					},";\n\t")
			 .. ";\n}\n"
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
				_.div("__timing", "Page load time: " .. 19.12312312312213 .. 
					(os.time() - TIME) ),

				-- Application information.
				_.div("__external", "Application Information: " .. _.i("none")),

				-- Show JS.

				-- Show session.
			}))
		})
	end,
}
