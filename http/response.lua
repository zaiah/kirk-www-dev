------------------------------------------------------
-- response.lua 
--
-- Code needed to create a decent response. 
------------------------------------------------------
------------------------------------------------------
-- send_response(t,x) 
--
-- Deliver codes and responses in t. Throw messages in 
-- x. Messages refer to any deliverable message. 
-- Typically errors and warnings.
--
-- More:
-- t can contain a number of different fields which
-- will be documented here and Pagan's website.
--
-- *nil
------------------------------------------------------
local function send_response(t,emsg)
	
	------------------------------------------------------
	-- Evaluate header information from [t].
	------------------------------------------------------
	local hdin, statcodes = {}, require("http.status")
	if t 
	 and is.ni(t)
	then
		hdin = { ["status"] = string.format("%d %s",
						t[1], statcodes[ t[1] ]),
					["ctype"] = t[2] or "text/html" }
	elseif t
	then
		hdin = { ["status"] = string.format("%d %s",
						t.status, statcodes[ t.status ]),
					["ctype"] = t.ctype or t.content_type }
	else
		hdin = { ["status"] = 200,
					["ctype"] = "text/html" }
	end

	------------------------------------------------------
	-- Set some default headers.
	-- You'll want to reorder these two.
	-- And test POST and GET.
	------------------------------------------------------
	HEADERS.DEFAULT = {
		["Content-Type"] 	 = hdin.ctype,
		["Status"] 	 		 = hdin.status,
--		["Content-Length"] = string.len(table.concat(STDOUT)) + 1,
--		["Date"] 			 = string.format("%s",date.asctime())
	}

	------------------------------------------------------
	-- Send whatever headers we've got.
	-- 
	-- This is the second occurrence of if in table then 
	-- return index...
	-- Add this to tests...
	------------------------------------------------------
	if next(HEADERS.USER)
	then
		if not HEADERS.USER["Content-Type"]
		then
			HEADERS.USER["Content-Type"] = "text/html"
		end
		
		for n,y in pairs(HEADERS.USER) do
			print(string.format('%s: %s',n,y))
		end
	else
		for n,y in pairs(HEADERS.DEFAULT) do
			print(string.format('%s: %s',n,y))
		end
	end

	------------------------------------------------------
	-- Send the response body.
	------------------------------------------------------
	print("\n")
	if emsg then print(emsg)
		else print(table.concat(STDOUT,"\n")) end
end

return {
	------------------------------------------------------
	-- .abort(t,msg) 
	--
	-- Send a response and abort.
	-- *nil 
	------------------------------------------------------
	["abort"] = function (t,msg)
		send_response(t,msg)
		os.exit()				-- Cease all execution.
	end,

	------------------------------------------------------
	-- .send(t,msg) 
	--
	-- Send a response.
	-- *nil 
	------------------------------------------------------
	["send"] = function (t,msg)
		send_response(t,msg)
	end,
}
