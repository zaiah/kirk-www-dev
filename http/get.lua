------------------------------------------------------
-- get.lua 
--
-- Basic GET proecessing.
------------------------------------------------------
-- Load in a query string.
return function (qs)
	-- Set aside memory.
	local tt = {}
	local xx

	-- Evaluate the strings and return as a purty table.
	if qs and string.len(qs) > 1 
	then
		if string.find(qs,'&')
		then
			for _,v in ipairs(table.from(qs,'&')) do
				xx = string.chop(v,'=')		-- Chop has to work at first match.
				tt[xx.key] = xx.value
			end
		else
			xx = string.chop(qs,'=')	
			tt[xx.key] = xx.value
		end
		return tt 
	end
end
