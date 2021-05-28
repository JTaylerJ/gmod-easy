function debug.GetUpvalues( func )
	local info = debug.getinfo( func, "uS" )
	local variables = {}

	-- Upvalues can't be retrieved from C functions
	if ( info != nil && info.what == "Lua" ) then
		local upvalues = info.nups

		for i = 1, upvalues do
			local key, value = debug.getupvalue( func, i )
			variables[ key ] = value
		end
	end

	return variables
end