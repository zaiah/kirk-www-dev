------------------------------------------------------
-- content-types.lua 
--
-- Short content type names. 
--
-- There is not much code here, but rather short names and 
-- long names that correspond to different file types.
-- Some of the extensions can be used to create your
-- own custom functions for content-type negotiation. 
--
-- For example: 
-- - filtering binary data from POST</li>
-- - Sending file data through JSON to a client-side
-- validator (like a Javascript file)</li>
-- 
-- A user can check use the `exists` function to see
-- if there is already a default type handler built in
-- for your data.  If not it can be register with the
-- `register` function.
------------------------------------------------------

------------------------------------------------------
-- content_types {}
--
-- List of common content types alongside a common
-- extension.
------------------------------------------------------
local content_types = {
-- HTTP
["text/javascript"] = "js",
["text/html"] = "html",

-- Audio
["audio/mp3"] = "mp3",
["audio/wav"] = "wav",
["audio/ogg"] = "ogg",
["audio/flac"] = "flac"

-- Images
}

------------------------------------------------------
-- meta {}
--
-- Sensible groupings of content_types, so that a user
-- does not have to check over an unnecessarily long
-- list, especially when crafting sites that do
-- roughly the same thing. 
------------------------------------------------------

return {
	register = function ()
	end,
	content_type = content_types,
	meta = meta,
}
