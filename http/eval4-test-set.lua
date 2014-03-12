return function()
	group.create()
	c = route.create({ name = "tammy", id = true },true)

	route.modify({ 
		autobound = "#tobal", 
		name = "tammy", 	
		where = { "tammy", default }
	})

	-- Show the members of the routes table for this new resource
	-- tammy.
	--[[
	die.quick(table.concat({
		table.dump(routes[c],true),
		"Member of: " .. table.dump(routes[c]["member_of"]),
	}))
	--]]

	d = route.create({ name = "loud", id = true }, true)
	--[[
	-- Show what all is in both of my routes so far.
	die.quick(table.concat({
		table.dump(routes[c],true),
		table.dump(routes[d],true),
	}))
	--]]

	route.create({ name = "jen", id = true })
	route.create({ name = "joe", id = true })
	route.create({ name = "lucy", id = true })

	-- At this point, only five members should be in my
	-- default route group.
	--[[
	die.quick(table.concat({
		"In default group (" .. default .. "):",
		table.dump(groups[default],true),
		"Members of: "..table.dump(groups[default]["members"],true),
	}, '<br />'))
	--]]

	group.create("xbob")
	route.create({ name = "juice", group = "xbob" })
	route.create({ name = "twelve", group = "xbob" })

	-- There should be only two members in group xbob.
	--[[
	die.quick(table.concat({
		"In group xbob:",
		table.dump(groups.xbob,true),
		"Members of: "..table.dump(groups.xbob["members"],true),
	}, '<br />'))
	--]]

	-- Show our new groups.
	--[[
	die.quick(
	table.concat({
		default .. "(default) contents: ",
		table.dump(groups[default]["members"],true),
		"xbob contents: ", 
		table.dump(groups.xbob.members,true)
	}, '<br />'))
	--]]
end
