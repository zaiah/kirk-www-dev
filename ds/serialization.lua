------------------------------------------------------
-- serialization.lua 
--
-- Different items to control serialization. 
------------------------------------------------------
local function lifo(t,key)
	if t
	then
		return t[key] or key
	else
		return key
	end
end

local cs			-- Store our content here.


------------------------------------------------------
-- each of these modules needs that HTML string
-- matching function. 
------------------------------------------------------

return {
	------------------------------------------------------
	-- .xml(t)
	--
	-- Return t in XML format.
	-- *string
	------------------------------------------------------
	["xml"] = function (c,frame)
		return table.concat(table.encapsulate({
			["first"] = '<xml version "1.0" encoding="UTF=8">',
			["table"] = (function ()
				local tt = {}
				for ind,t in ipairs(c) do
					for k,v in pairs(t) do
						table.insert(tt,
							string.format("<%s>%s</%s>", 
							lifo(frame,k),v,lifo(frame,k)))		
					end
				end
				return tt
			end)(),
			["last"] = '</xml>'
		}))
	end,

	------------------------------------------------------
	-- .json(t)
	--
	-- Return t in JSON format. Needs work.
	-- *string
	------------------------------------------------------
	["json"] = function (c,frame)
		------------------------------------------------------
		------------------------------------------------------
		local count = 1

		-- What does this actually do?
		local function send_uuid(id) 
			local str = string.format("%s: {", id or count)
			count = count + 1
			return str
		end

		------------------------------------------------------
		-- Return our JSON block.
		------------------------------------------------------
		return table.concat(table.encapsulate({
			["first"] = '{',
			["table"] = (function ()
				local tt = {}
				for ind,t in ipairs(c) do

					-- Set a reference to the object.
					if frame and frame.uid then
						table.insert(tt, send_uuid( t[frame.uid] ))
					else
						table.insert(tt, send_uuid())	end

					-- Close the JSON.		
					for k,v in pairs(t) do
						table.insert(tt,string.format('%s: "%s",\n',lifo(frame,k),v))
					end
				
					-- Close the JSON.		
					table.insert(tt, "},") 
				end
				return tt
			end)(),
			["last"] = '}'
		}))
	end,
	
	------------------------------------------------------
	-- .html(t)
	--
	-- Return t in HTML format.
	-- *string
	------------------------------------------------------
	["html"] = function (c,frame)
		return table.concat(
			(function ()
				if c then
					local tt = {}
					for ind,t in ipairs(c) do
						for k,v in pairs(t) do
							table.insert(tt,
								html.class(lifo(frame,k),v))
						end
					end
					return tt
				else
					return {}
				end
			end)())
	end,

	------------------------------------------------------
	-- .html_table(t)
	--
	-- Return t in HTML table format.
	-- *string
	------------------------------------------------------
	["html_table"] = function (c,frame)
		if c
		then
			return table.concat(table.encapsulate({
				["first"] = '<table>',
					["table"] = (function ()
						-- Keep stuff.
						local tt = {}

						-- Add some tables.
						if frame and frame.header then
							for k,v in pairs(c[1]) do
								table.insert(tt, string.format("<th>%s</th>",k)) end 
							end
							
						-- Keep stuff.
						for ind,t in ipairs(c) do
							table.insert(tt, "<tr>")
							for k,v in pairs(t) do
								table.insert(tt, string.format("<td>%s</td>",v))		
							end
						table.insert(tt, "</tr>")
						end
					return tt
				end)(),
				["last"] = '</table>'
			}))
		end
	end,

	------------------------------------------------------
	-- .html(t)
	--
	-- Return t in JSON format.
	-- *string
	------------------------------------------------------
	["html_by_class"] = function (c,frame)
		if c
		then
			return (function ()
				local tt = {}
				------------------------------------------------------
				-- If we want to wrap the content, 
				------------------------------------------------------
				if frame and frame.wrap 
				 and type(frame.wrap) == 'string' then
					for ind,t in ipairs(c) do
						table.insert(tt, html.class(frame.wrap, 
							(function()
								local xx = {}
								for k,v in pairs(t) do
									table.insert(xx,
										html.class(lifo(frame,k),v))
								end
								return table.concat(xx)
								--return xx
						end)()))
					end

				------------------------------------------------------
				-- Just do a simple dump.
				------------------------------------------------------
				elseif frame
				then
					for ind,t in ipairs(c) do
						for k,v in ipairs(t) do
							table.insert(tt, html.class(frame[k],v)) 
						end
					end
				else
					for ind,t in ipairs(c) do
						for k,v in pairs(t) do
						--	table.insert(tt, v) --html.class(ind,v))
							--table.insert(tt, v) --html.class(ind,v))
							table.insert(tt, html.class(k,v))
						end
					end
				end
				return table.concat(tt)
			end)()
		end
	end,

	------------------------------------------------------
	-- .html(t)
	--
	-- Return t in JSON format.
	-- *string
	------------------------------------------------------
	["html_by_class_and_id"] = function (c,frame)
		return table.concat(
			(function ()
				local tt = {}
				for ind,t in ipairs(c) do
					for k,v in pairs(t) do
						table.insert(tt,
							html.class(lifo(frame,k),v))
					end
				end
				return tt
			end)())
	end,

	------------------------------------------------------
	-- alpha(t) 
	--
	-- Turn a content table into one long alphanumericallyb
	-- indexed table, using the value as the alphanumeric
	-- index.
	------------------------------------------------------
	alpha = function (t,i)
		local tt = {}
		for __,val in ipairs(t)
		do
			for num,val2 in pairs(val) 
			do
				tt[val2] = val2
			end
		end	
		return tt
	end,


	------------------------------------------------------
	-- sequence(t) 
	--
	-- Turn a content table into one long alphanumerically
	-- indexed table, using the column name and a counter
	-- to keep track of the table. 
	------------------------------------------------------
	sequence = function (t,i)
		local tt = {}
		for num,val in ipairs(t)
		do
			for alpha,val2 in pairs(val) 
			do
				tt[alpha .. ":" .. num] = val2
			end
		end	
		return tt
	end,
	------------------------------------------------------
	-- numeric (t) 
	--
	-- Turn a content table into one long numerically 
	-- indexed table.
	------------------------------------------------------
	numeric = function (t,i)
		local tt = {}
		for __,val in ipairs(t)
		do
			for __d,val2 in pairs(val) 
			do
				table.insert(tt,val2)
			end
		end	
		return tt
	end,
}
