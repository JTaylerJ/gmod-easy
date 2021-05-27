easy()

meta_string.__bad = function(self)
	
end

meta_string.__mod = function(self, value)
	if istable(value) then
		return easy.formatter.Interpolate(self, tab)
	end
	
	local tab_str = self .. " #{"
	for k, v in pairs(tab) do
		local key = string.match(k,"%a+")
		if write_type[key] then
			v = write_type[key](v)
		end
		tab_str = tab_str .. k .. ":" .. v .. ";"
	end
	tab_str = tab_str .. "}#"
	
	
	return tab_str
end
meta_string.__unm = function(self)
	local data_str
	self = self:gsub(' #{[^}#]+}#',function(w) data_str = w return "" end)
	local data = {}
	if data_str then
		local new_data = data_str:sub(3,-3)
		new_data = new_data:gsub('(%w+):([^;]+);', function(key, var)
			local clear_key = key:match("%a+")
			if read_types[clear_key] then
				var = read_types[clear_key](var)
			end
			data[key] = var
		end)
	end
	
	self = self:gsub('#[^%s]+',function(w) return language and language.GetPhrase(w) or w end)
	
	self = self:gsub('($%b{})', function(w) return data[w:sub(3, -2)] or w end)
	
	return self
end