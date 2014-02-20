------------------------------------------------------
-- strings.lua 
--
-- Some proper extensions and additional string
-- functions. 
------------------------------------------------------


------------------------------------------------------
-- lib {} 
--
-- Methods to extend regular string library. 
------------------------------------------------------
local lib = {
	------------------------------------------------------
	-- .chop(t,d)
	--
	-- Chop some string according to a delimiter? 
	-- *string
	------------------------------------------------------
	chop = function (t,d)
		local s,c = {},1

		if type(t) == 'table'
		then
			local tt = {}
			for i,term in ipairs(t)
			do
				tt[i] = {	
					["key"] = ({ string.find(term,string.format("(.*)%s",d)) })[3],
					["value"] = ({ string.find(term,string.format("%s(.*)",d)) })[3]
				}
			end
			return tt
		elseif type(t) == 'string'
		then
			return {
				["key"] = ({ string.find(t,string.format("(.*)%s",d)) })[3],
				["value"] = ({ string.find(t,string.format("%s(.*)",d)) })[3]
			}
		end	
	end,

	------------------------------------------------------
	-- .set(text,key) 
	--
	-- If text is a value, then set it and return a string
	-- with it set.
	-- [id] is optional key to set text to.
	--
	-- Should return a status as well.
	--
	-- TODO: ALL tests should return a bool (or nil)
	-- *string
	------------------------------------------------------
	set = function (text,key)
		local rt = ""
		if text and key
		 and text ~= ''
		 and key ~= ''
		then
			rt = string.format("%s=%s",key,text)
		elseif text
		 and text ~= ''
		then
			rt = text
		else
			rt = '' -- nil??? 
		end
		return rt
	end,

	------------------------------------------------------
	-- .modfield(t)
	--
	-- Modify some tag field.
	-- *string
	------------------------------------------------------
	modfield = function (text,t)
		-- Wrap "open" tags. 
		-- Example: <input id="mama">
		if string.find(text," ")
		then
			return (string.gsub(text,"(<[a-z]*)\ ",
				function(x)
					local tt = {}
					for k,v in ipairs(t) 
					do 
						tt[k] = v .. " " 
					end
					return string.format('%s%s',x,table.concat(tt,"")) 
				end))
		else
			-- Wrap closed tags.
			-- Example: <xml>
			return (string.gsub(text,	
				string.sub(text,1,string.find(text,'>')), -- <xml>
				function(x) 
					local tt = {}
					for k,v in ipairs(t) 
					do 	
						tt[k] = v .. " " 
					end
					return string.format('%s>',
						string.gsub(x,'>'," " .. table.concat(tt," ")))
				end))
		end
	end,

	------------------------------------------------------
	-- .linebreak(_os) 
	--
	-- Setter for string decoding.
	-- *nil 
	------------------------------------------------------
	linebreak = function (str,brk)
		local brktypes = {
			["browser"] = function () 
				return string.gsub(str,"\n","<br />") end,
			["unix"]    = function () 
				return string.gsub(str,"\n","\n") end,
			["windows"] = function () 
				return string.gsub(str,"\n","\n\r") end,
			["mac"] 		= function () 
				return string.gsub(str,"\n","\r") end,
			["none"] 	= function () 
				return string.gsub(str,"\n","") end,
		}

		if str
		 and is.key(brk,brktypes)
		then
			return brktypes[brk]()
		else
			if type(brk) == 'string' then
			return string.gsub(str,"\n",brk) end
		end
	end,

	------------------------------------------------------
	-- .decode(str)
	--
	-- Decode a string. 
	-- Both should evolve to selectively find characters.
	-- *string
	------------------------------------------------------
	decode = function (str)
		-- The characters [ "*", "-", "_", "." ] are never encoded.
		for key,val in pairs({
			["%%21"] = "!",
			["%%40"] = "@",
			["%%23"] = "#",
			["%%24"] = "$",
			["%%25"] = "%",
			["%%5E"] = "^",
			["%%26"] = "&",
			["%%28"] = "(",
			["%%29"] = ")",
			["%%2B"] = "+",
			["%%3D"] = "=",
			["%%7E"] = "~",
			["%%60"] = "`",
			["%%5B"] = "[",
			["%%5D"] = "]",
			["%%7B"] = "{",
			["%%7D"] = "}",
			["%%7C"] = "|",
			["%%3A"] = ":",
			["%%3B"] = ";",
			["%%27"] = "'",
			["%%3C"] = "<",
			["%%2C"] = ",",
			["%%3E"] = ">",
			["%%3F"] = "?",
			["%%2F"] = "/",
			["%%0D%%0A"] = "\n",
			["%%5C"] = "\\", -- \
			["%%22"] = '%"', -- "
		}) do
			str = string.gsub(str,key,val)
		end
		str = string.gsub(str,'+',' ')
		return str
	end,

	------------------------------------------------------
	-- .extract(block,t) 
	--
	-- Decode (unencode) block and extract terms in t 
	-- from block.
	------------------------------------------------------
	extract = function (block,t,d)
		---[[
		local delim = d or '&'
		local tt = {}
		if t -- Find the & after the end of these..
		 and type(t) == 'table'
		then
			for _,name in ipairs(t) do
				local s,lim = { string.find(block,name) },""
				if next(s) 
				then  			-- Only proceed if string was found.
					if string.find(block,delim,s[2]) 
					then
						lim = tonumber(string.find(block,delim,s[2]) - 1)
					else
						lim = string.len(block)
					end
					tt[name] = string.sub(block,s[2] + 2,lim)
				else 	
					-- Log this.
					err = string.format('Error: string "%s" not found...',name)
				end	
			end
		elseif t and type(t) == 'string'
		then
		end
	end,

	------------------------------------------------------
	-- .encode(str)
	--
	-- Encode a string. 
	-- *string
	------------------------------------------------------
	encode = function (str)
		-- Find percents first...
		if string.find(str,"%%")
		then
			str = string.gsub(str,"%%","%%25")
		end	
	
		-- ...then do the rest of the encodings...	
		for key,val in pairs({
			["%%21"] = "!",
			["%%40"] = "@",
			["%%23"] = "#",
			["%%24"] = "%$",
			["%%5E"] = "%^",
			["%%26"] = "&",
			["%%28"] = "%(",
			["%%29"] = "%)",
			["%%2B"] = "%+",
			["%%3D"] = "=",
			["%%7E"] = "~",
			["%%60"] = "`",
			["%%5B"] = "%[",
			["%%5D"] = "%]",
			["%%7B"] = "{",
			["%%7D"] = "}",
			["%%7C"] = "|",
			["%%3A"] = ":",
			["%%3B"] = ";",
			["%%27"] = "'",
			["%%3C"] = "<",
			["%%2C"] = ",",
			["%%3E"] = ">",
			["%%3F"] = "%?",
			["%%2F"] = "/",
			["%%5C"] = "\\", -- \
			["%%22"] = '%"', 
		}) do
			if string.find(str,val)
			then
				str = string.gsub(str,val,key)
			end	
		end

		-- ...while we reserve space characters last.
		str = string.gsub(str,' ','+')
		return str
	end,

	------------------------------------------------------
	-- .entity (str)
	--
	-- Encode [str] according to its HTML encoding.
	-- Will encode the entire string if [indchars] is
	-- omitted. 
	-- Will only encode chars in [indchars] otherwise.
	-- *string
	------------------------------------------------------
	entity = function (str,indchars)
		if string.len(str) == 1
		then
			if str == '\t'
			then
				return '&#160;'
			elseif str == '\n'
			then
				return '<br />'
			else
				return string.format("&#%d;",string.byte(str))
			end

		else
			local chars = {}
			for char=1,string.len(str)
			do
				chars[char] = string.format("&#%d;",string.byte(string.sub(str,char)))
			end
			return table.concat(chars)
		end
	end,
	
	------------------------------------------------------
	-- .escape 
	--
	-- Escape certain characters in strings.
	-- *string 
	------------------------------------------------------
	escape = function (str,chars)
		if str and chars 
		then
		 	if type(chars) == 'string'
			then
				return ({string.gsub(str, chars, string.entity(chars))})[1]
			elseif type(chars) == 'table'
			then
				local strrep = str
				for _,char in ipairs(chars)
				do
					strrep = ({
						string.gsub(strrep, char, string.entity(char))})[1]
				end
				return strrep
			end
		end
	end,
	
	------------------------------------------------------
	-- .clean (str,t)
	--
	-- Clean up a string if bad characters exist. 
	-- *string
	------------------------------------------------------
	clean = function (str,t)
		for x,terms in ipairs(t)
		do 
			if string.match(str,string.sub(terms,1,1))
			then
				if string.len(terms) == 1
				then
					str = string.gsub(str,terms,"")
				elseif string.len(terms) == 3
				then
					str = string.gsub(str,
						string.sub(terms,1,1),string.sub(terms,3,3))
				end	
			end
		end
		return str 
	end,

	------------------------------------------------------
	-- .url(t)
	--
	-- Output a URL formatted string when thrown a table.
	--
	-- *string
	------------------------------------------------------
	url = function (t)
		die.when_type_not(t, "table")
		return "/" .. table.concat(t,"/")
	end,

	------------------------------------------------------
	-- .filepath(t)
	--
	-- Output a string formatted as filepath when given 
	-- a table.
	--
	-- *string
	------------------------------------------------------
	filepath = function (t)
		die.when_type_not(t, "table")

		-- Must evaluate os.
		-- if within( string.lower(os.name), "windows" ) 
		return table.concat(t, "/")
	end,

	------------------------------------------------------
	-- .trim(str,char) 
	--
	-- Trim char(s) from beginning or end of str. 
	-- Omitting char will search for white space.
	-- *string
	------------------------------------------------------
	trim = function (str)
		-- You can look for numerical code or look for whitespace.
		-- These aren't portable so we have to be careful...
		local t,d = {},1

		-- Crude way to start at beginning and then jump to end.
		local strst, strend = 0, 0 

		-- Get rid of CR LF's.
		str = string.gsub(str,"%%0D%%0A","")
		
		-- Find end.
		for c=tonumber(string.len(str)),1,-1
		do
			if string.sub(str,c,c) ~= " "
			then
				strend = c
				break
			end 
		end

		-- Find start.
		for c=1,string.len(str)
		do
			if string.sub(str,c,c) ~= " " 
			then
				strst = c	
				break
			end 
		end

		return string.sub(str, strst, strend)
	end,

}

-- Add string library to Lua strings.
for x,n in pairs(string)
do
	lib[x] = n
end

return lib
