----------------------------------------
-- uuid.lua
-- 
-- Generate a unique identifier.
-- For unique shit.
-- 
-- // More
-- To address the table generator bug
-- (where hex code changes but the rest
-- of the garbage is the same):
-- Getting rid of the table generator and
-- using a random key with punctuation and
-- numbers.
----------------------------------------

-- This needs some help. Got to be a better seed out there...
math.randomseed( os.time() * 60 ) 								
local stime = tonumber(os.time() * 30)
local ltime = tonumber(os.time() * 60)
local rtime = math.random(11111111,999999999)
-- This needs some help. Got to be a better seed out there...
--math.randomseed(stime,ltime) 

local seq = {
	----------------------------------------
	-- .alpha {}
	--
	----------------------------------------
	["alpha"] = { 
		'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 
		'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r' ,'s', 't', 
		'u', 'v', 'w', 'x', 'y', 'z',	'A', 'B', 'C', 'D', 
		'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 
		'O', 'P', 'Q', 'R' ,'S', 'T', 'U', 'V', 'W', 'X', 
		'Y', 'Z' 
	},

	----------------------------------------
	-- .beta {}
	--
	----------------------------------------
	["beta"] = {
		'!', '#', '?', '@', '%', '+', '^', '&', '-', '='
	},

	----------------------------------------
	-- .urlsafe {}
	--
	-- URL safe characters.
	----------------------------------------
	["urlsafe"] = {
		'!', '#', '?', '@', '%', '+', '^', '&', '-', '='
	},

	----------------------------------------
	-- .num {}
	--
	-- URL safe characters.
	----------------------------------------
	["num"] = {
		1, 2, 3, 4, 5, 6, 7, 8, 9 
	},
}

----------------------------------------
-- genSeq(t,int) local
--
-- Generates some sequence.
-- t 		= table for different types.
-- int 	= length of character.
----------------------------------------
local function genSeq(t,int)
	-- Kill yoself...
	if not t then
		return nil
	end

	-- Randomize stuff.
	local l = {}
	for x=1,int do 
		l[x] = t[math.random(1,#t)] 
	end

	return table.concat(l)
end

--[[
local letter	= alpha_seq()										-- Return some letters in the alphabet.
local num 		= math.random(10000000,99999999)				-- A really big number.
local rel		= beta_seq()

--local rel = string.gsub(tostring(xid),"table: ","")	-- Get a hexadecimal identifier.

local id = tostring(letter .. num .. rel)								-- Combine them all and you get something cool!
return id
--]]

local function amalgamate(t,int)
	local combo,inc = {},1
	-- you can break the salt into a table here too and really fuck shit up..
	for _,tt in ipairs(t)
	do
		for _,char in ipairs(tt)
		do
			combo[inc] = char
			inc		  = inc + 1
		end
	end
	return genSeq(combo,int)
end

local uuid = {
	----------------------------------------
	-- .alphanum()
	--
	-- Generate a sequence of non-alphanumeric
	-- characters.
	----------------------------------------
	["alnum"] = function (int)
		return amalgamate({seq.alpha,seq.num},int)	
	end,
	
	----------------------------------------
	-- .combo() 
	--
	-- Generate a sequence of non-alphanumeric
	-- characters.
	----------------------------------------
	["combo"] = function (int)
		return amalgamate({seq.alpha,seq.beta,seq.num},int)	
	end,

	----------------------------------------
	-- .num()
	--
	-- Generate a random number of some 
	-- sort.
	----------------------------------------
	["num"] = function (int)
		return amalgamate({seq.num},int)	
	end,

	----------------------------------------
	-- .beta()
	--
	-- Generate a sequence of non-alphanumeric
	-- characters.
	----------------------------------------
	["beta"] = function (int,salt)
		return genSeq(seq.beta,int)
	end,

	----------------------------------------
	-- .alpha(int,salt)
	--
	-- Generate a sequence of non-alphanumeric
	-- characters.
	----------------------------------------
	["alpha"] = function (int,salt)
		return genSeq(seq.alpha,int)
	end
}

return uuid 
