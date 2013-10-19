------------------------------------------------------
-- log.lua 
--
-- Control logging and what not. 
------------------------------------------------------
local logfile = pg.log or "local/kirk.log"
local prefix, suffix

return {
------------------------------------------------------
-- .prefix (text) 
--
-- Prefix our log files with some text. 
------------------------------------------------------
["prefix"] = function (text,time)
	if not text and time then
		prefix = os.date()
	elseif text and not time then
		prefix = text
	elseif text and time then
		prefix = text .. os.date()
	end 
end,
["suffix"] = function (text)
	suffix = text
end,

------------------------------------------------------
-- .table (t) 
--
-- Prefix our log files with some text. 
------------------------------------------------------
["table"] = function (t)
	F.asset("private")
	local enc = { prefix or "", suffix or "" }
	if type(t) == 'table' 
	then
		if is.ni(t)
		then
			for x,n in ipairs(t) do 
				F.write(string.format("%s %s %s\n",enc[1],tostring(x),enc[2]), logfile)
				F.write(": ", logfile)
				F.write(string.format("%s %s %s\n",enc[1],tostring(n),enc[2]), logfile)
			end
		else
			for x,n in pairs(t) do 
				F.write(string.format("%s %s %s\n",enc[1],tostring(x),enc[2]), logfile)
				F.write(": ", logfile)
				F.write(string.format("%s %s %s\n",enc[1],tostring(n),enc[2]), logfile)
			end
		end
	else
		F.write("Error at LOG.table, cannot work with data supplied:\n",logfile)
		F.write("Data supplied is not a table.\n",logfile)
	end
end,
["file"] = function (thing_to_log)
	local enc = { prefix or "", suffix or "" }
	F.asset("private")
	F.write(string.format("%s %s %s\n",enc[1],tostring(thing_to_log),enc[2]), logfile)
end,

["db"] = function ()
end,
}

