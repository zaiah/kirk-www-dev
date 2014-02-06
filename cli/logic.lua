------------------------------------------------------
-- logic.lua
--
-- Logic evaluation.
------------------------------------------------------
return function ( opt )

	if opt.backend.run
	then
		-- Debug?
		-- print( pg.backend )

		-- Choose a different backend.
		if is.value( string.lower(opt.backend.argv), { "cgi", "fcgi", "wsapi" })
		then
			pg.backend = string.lower(opt.backend.argv)
		end	
	end

	if opt.suspend.run
	then
		-- Check that a user has asked for the right thing.

		-- Probably will want to load the results of this first, since it could be a performance hit.
	end	

	if opt.get.run
	then
		if type( opt.get.argv ) == 'string'
		then
			-- If , exists.
			print( table.concat( table.from( opt.get.argv, "," ) ))
		end	
	end

	if opt.post.run
	then
		-- What is the argument type.
		-- print( type(opt.post.argv) )

		-- Check what has been supplied.

		if type( opt.post.argv ) == 'table'
		then
			-- print( table.maxn(opt.post.argv) )
		 	if table.maxn(opt.post.argv) == 1
			then
				-- print( type(opt.post.argv[1]) )
				print( table.concat( table.from(opt.post.argv[1], ",")) )
			end

			-- Move through all the tables and make sure that they're strings.

			-- Chop all the tables by a comma to make sure that they become table values.

			-- Add the keys to POST, and submit each string.
		end

		-- POST tables should be done like this.
		-- An enterprising Bash script can do the 
		-- table conversions.
	end

	if opt["suspend-group"]["run"]
	then
	end

	if opt["dump-pg"]["run"]
	then
	end

	if opt["list-modules"]["run"]
	then
	end
end
