------------------------------------------------------
-- arg.lua 
--
-- Parse and mess with arguments.
--
-- More
-- Some basic logic dealing with arguments / types
-- goes here.  Whereas module [is] is good for
-- testing what something is, this module is better
-- for actually doing work based on the results.
------------------------------------------------------


------------------------------------------------------
-- pseudo get_arg_types ( e1, e2 )
--
-- Check supplied arguments and return types for 
-- quick testing.
--
-- Returns a table with the following indices: 
-- .table 		= only one element and it's a table.
-- .string 		= only one element and it's a table.
-- .strings		= both elements are strings.
-- .tables		= both elements are tables.
-- .string_and_table = first element is string, second is table.
-- .table_and string = first element is string, second is table.
--
-- *table
------------------------------------------------------
return function( e1, e2 )
	local types,t = {},{}

	-- Neither.
	if not e1 
	then
		types.boolean = true
		return types

	-- Only e1
	elseif e1 and not e2
	then
		if type(e1) == 'string' then
			types.string = true
		elseif type(e1) == 'function' then 
			types["function"] = true
		elseif type(e1) == 'table' then 
			types.table = true
		elseif type(e1) == 'nil' then 
			types["nil"] = true
		elseif type(e1) == 'boolean' then 
			types.boolean = true
		elseif type(e1) == 'userdata' then 
			types.userdata = true
		elseif type(e1) == 'number' then 
			types.number = true
		end
		return types

	-- e1 & e2
	elseif e1 and e2
	then
		if type(e1) == 'boolean' then
			-- Maybe create the arguments on the fly?
			-- type(e1) .. "_and_" .. type(e2)
			if type(e2) == 'string' then types.boolean_and_string = true
			elseif type(e2) == 'table' then types.boolean_and_table = true
			elseif type(e2) == 'function' then types.boolean_and_function = true
			elseif type(e2) == 'number' then types.boolean_and_number = true
			elseif type(e2) == 'boolean' then types.booleans = true
			elseif type(e2) == 'userdata' then types.boolean_and_userdata = true
			elseif type(e2) == 'nil' 
			 or type(e2) == 'false' then types.boolean_and_nil = true
			end

		elseif type(e1) == 'table' then
			if type(e2) == 'string' then types.table_and_string = true
			elseif type(e2) == 'table' then types.tables = true
			elseif type(e2) == 'function' then types.table_and_function = true
			elseif type(e2) == 'number' then types.table_and_number = true
			elseif type(e2) == 'boolean' then types.table_and_boolean = true
			elseif type(e2) == 'userdata' then types.table_and_userdata = true
			elseif type(e2) == 'nil' 
			 or type(e2) == 'false' then types.table_and_nil = true
			end

		elseif type(e1) == 'string' then
			if type(e2) == 'string' then types.strings = true
			elseif type(e2) == 'table' then types.string_and_table = true
			elseif type(e2) == 'function' then types.string_and_function = true
			elseif type(e2) == 'number' then types.string_and_number = true
			elseif type(e2) == 'boolean' then types.string_and_boolean = true
			elseif type(e2) == 'userdata' then types.string_and_userdata = true
			elseif type(e2) == 'nil' 
			 or type(e2) == 'false' then types.string_and_nil = true
			end

		elseif type(e1) == 'function' then
			if type(e2) == 'string' then types.function_and_string = true
			elseif type(e2) == 'table' then types.function_and_table = true
			elseif type(e2) == 'function' then types.functions = true
			elseif type(e2) == 'number' then types.function_and_number = true
			elseif type(e2) == 'boolean' then types.function_and_boolean = true
			elseif type(e2) == 'userdata' then types.function_and_userdata = true
			elseif type(e2) == 'nil' 
			 or type(e2) == 'false' then types.function_and_nil = true
			end

		elseif type(e1) == 'number' then
			if type(e2) == 'string' then types.number_and_string = true
			elseif type(e2) == 'table' then types.number_and_table = true
			elseif type(e2) == 'function' then types.number_and_function = true
			elseif type(e2) == 'boolean' then types.number_and_boolean = true
			elseif type(e2) == 'number' then types.numbers = true
			elseif type(e2) == 'userdata' then types.number_and_userdata = true
			elseif type(e2) == 'nil' 
			 or type(e2) == 'false' then types.number_and_nil = true
			end

		elseif type(e1) == 'nil' then
			if type(e2) == 'string' then types.nil_and_string = true
			elseif type(e2) == 'table' then types.nil_and_table = true
			elseif type(e2) == 'function' then types.nil_and_function = true
			elseif type(e2) == 'number' then types.nil_and_number = true
			elseif type(e2) == 'boolean' then types.nil_and_true = true
			elseif type(e2) == 'userdata' then types.nil_and_userdata = true
			end

		elseif type(e1) == 'userdata' then
			if type(e2) == 'string' then types.userdata_and_string = true
			elseif type(e2) == 'table' then types.userdata_and_table = true
			elseif type(e2) == 'function' then types.userdata_and_function = true
			elseif type(e2) == 'number' then types.userdata_and_number = true
			elseif type(e2) == 'boolean' then types.userdata_and_boolean = true
			-- Grammar nazis,  SHUT UP!
			elseif type(e2) == 'userdata' then types.userdatas = true
			elseif type(e2) == 'nil'
			 or type(e2) == 'false' then types.userdata_and_nil = true
			end

		end
		return types

	elseif not e1 and not e2
	then
		types.nils = true
		return types
	end
end
