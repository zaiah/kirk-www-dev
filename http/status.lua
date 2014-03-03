------------------------------------------------------
-- status.lua
--
-- List of status codes.
-- 
-- // More
-- We'll never be doing this.  But we might
-- parse responses based on these messages.
-- We may also send these back depending on
-- certain situations.
------------------------------------------------------
return {
[100] = "Continue",				-- When sending large requests.
[101] = "Switching Protocols", -- Ummm...

[200] = "OK",
[201] = "Created",				-- Server object successfully created.
[202] = "Accepted",				-- 
[204] = "No Content",			-- May save a request or server round.
[206] = "Partial Content",		-- This helps, but is rarely used in practice.

[300] = "Multiple Choices",	-- Send back list of request options.
[301] = "Moved Permanently",	-- URL has been permanently moved.
[302] = "Found",
[303] = "See Other",
[304] = "Not Modified",
[305] = "Use Proxy",
[307] = "Temporary Redirect",	-- Temporary relocation of resource.

[400] = "Bad Request",			-- Bad Request made.
[401] = "Unauthorized",			-- Ask requestor to authenticate.
[403] = "Forbidden",				-- NO!  Bad Monkey!
[404] = "Not Found",				-- Can't find this resource.
[405] = "Method Not Allowed",
[406] = "Not Acceptable",
[407] = "Proxy Authentication Required",
[408] = "Request Timeout",
[409] = "Conflict",
[410] = "Gone",
[411] = "Length Required",
[412] = "Precondition Failed",
[413] = "Request Entity Too Large",  -- Is this ever used?
[414] = "Request URI Too Long",
[415] = "Unsupported Media Type",
[416] = "Requested Range",
[417] = "Expectation Failed",

[500] = "Internal Server Error",
[501] = "Not Implemented",
[502] = "Bad Gateway",
[503] = "Service Unavailable",
[504] = "Gateway Timeout"
}
