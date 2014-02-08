------------------------------------------------------
-- date.lua 
--
-- Date parsing functions. 
------------------------------------------------------
-- Complicated date conversion.
-- Move somewhere else.
local function pad(n) 
	if n and string.len(n) == 1 and type(n) == 'number'
	then
		return tostring(0 .. n)
	elseif n
	then
		return n
	end
end


-- Seems like you need both time and date.
-- time should return current tick time.
-- date should return today's date and some other stuff.

-- Date is really for formatting,
-- while time is really for numbers.
--
-- Since this is so, automatic padding makes more sense.
-- Also, all the returns will be strings.
-- 
-- Some examples:
-- You'll need a table for adjustment.
-- { 	time 		= n, 	  -- Supply a time.
--   	tz 		= gmt,  -- Account for timezone changes.
--  	[unit] 	= n	  -- Output offset?
-- }	
-- 
-- date.tz( x )									-- Change timezone temporarily.
-- date.now()  - Does this make sense?  No... time.now() is a better idea.
-- date.unix()										-- Outputs '1234123123'
-- date.gmt()										-- Outputs Wed, 13 Jan
-- date.second()									-- Outputs '01'
-- date.minute()									-- Outputs '01'
-- date.hour()										-- Outputs '01'
-- date.milliseconds()							-- Outputs '0.001'
-- date.epoch()									-- Should return the epoch.
-- date.[etc]()
-- date.[after,before](nil, {[unit] = 7}) -- Outputs date incrementing 
														-- or decrementing by [unit]
														-- where [unit] = units of time.
-- This can become an application
--
-- You can return a range, but you'll hvae to format it, figure out how
-- you want iterate over the range (every day, every hour, every second?, etc)
--	
-- dotevery will need it.
-- date.range( x, y )							-- Returns a range of dates as a table.

-- Time functions are relative to unix time like date, but
-- an argument changes it.
-- time.seconds()									-- Returns 1
-- time.hour()										-- Returns 1
-- time.now()										-- Returns unix time
-- time.milliseconds()							-- Returns 111
-- time.epoch()									-- Should return 0.
-- time.nanoseconds()							-- Returns 12312312321

-- Something like
-- date.gmt( time.now() + time.days(9) )
-- would handle the Expires= string for a cookie.

-- .after, .before, {
-- 	sec = 9,
-- 	min = 9,
-- 	year = 9,
-- 	day = 9,
-- 	wday = 9,
-- }

------------------------------------------------------
-- days {} 
--
-- List of English days.
-- These will be locale specific in the future.
------------------------------------------------------
local days = {
	"Sunday", 
	"Monday", 
	"Tuesday", 
	"Wednesday", 
	"Thursday", 
	"Friday",
	"Saturday"
}

------------------------------------------------------
-- months {} 
--
-- Locale specific months. 
------------------------------------------------------
local months = {
	"January",
	"February",
	"March",
	"April",
	"May",
	"June",
	"July",
	"August",
	"September",
	"October",
	"November",
	"December"
}


local date_tbl -- Hold the date table.


------------------------------------------------------
-- diff {} 
--
-- Local methods for calculating different time
-- units.
------------------------------------------------------
local function diff_secs(n)
	if type(n) == 'number'
	then
	return n * 86400
	else
		response.abort({500}, "Argument supplied to diff_secs() is not a number!")
		die.with(500, "Argument supplied to diff_secs() is not a number!")
	end
end

------------------------------------------------------
-- public methods {} 
------------------------------------------------------
return { 
	cookie = function ( n )
		-- Set a date source.
		local date_src = n or os.time()

		-- This outputs Coordinated Universal Time (GMT?)
		-- local date_tbl = os.date( "*t", date_src )
		
		-- This outputs local time.
		local date_tbl = os.date( "*t", date_src )

		-- ...
		return table.concat({
			string.sub(days[date_tbl.wday],1,3), ", ",
			pad( date_tbl.day ), " ",
			string.sub(months[date_tbl.month],1,3), " ",
			date_tbl.year, " ",
			pad( date_tbl.hour ), ":",
			pad( date_tbl.min ), ":",
			pad( date_tbl.sec )
		})
	end
}
