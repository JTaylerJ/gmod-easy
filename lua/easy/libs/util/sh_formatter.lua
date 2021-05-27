easy("formatter")

read_types = {
	["ply"] = function(var) return isentity(var) and var.Nick and (var:Nick() or "NIL") or tostring(var) end,
	["ent"] = function(var) return tostring(var) end,
	["n"] = function(var) return string.Comma(tostring(var)) end,
	["s"] = function(var) return tostring(var) end,
	["wallet"] = function(var) return string.Comma(tostring(var)) .. "$" end,
	["date"] = function(var) return os.date("!%H:%M %m.%d.%y", var) end,
}

read_types_nil = read_types_nil or {}
read_types_arg = {
	["ply"] = function(var) return Color(255,125,0), isentity(var) and var.Nick and (var:Nick() or "NIL") or tostring(var) end,
	["ent"] = function(var) return Color(255,125,0), tostring(var) end,
	["n"] = function(var) return Color(125,100,0), string.Comma(tostring(var)) end,
	["s"] = function(var) return Color(100,255,100), "<", tostring(var), ">" end,
	["wallet"] = function(var) return Color(25,125,25), string.Comma(tostring(var)) .. "$" end,
	["date"] = function(var) return Color(100, 100, 255), os.date("!%H:%M %m.%d.%y", var) end,
}
read_types_arg_nil = {}

function RegisterTypeNil(name, func, funcArg)
	read_types_nil[name] = func
	read_types_arg_nil[name] = funcArg
end


function Interpolate(self, tab)
	for k, v in pairs(tab) do
		local key = string.match(k,"%a+")
		if read_types[key] then
			tab[k] = read_types[key](v)
		end
	end

	self = self:gsub('#[^%s]+',function(w) return language and language.GetPhrase(w) or w end)


	self = self:gsub('($%b{})', function(w) local value = w:sub(3, -2) return tab[value] or (read_types_nil[value] and read_types_nil[value]() or w) end)

	return self
end

function InterpolateArg(self, tab, clr)
	clr = clr or color_white
	for k, v in pairs(tab) do
		local key = string.match(k,"%a+")
		if read_types_arg[key] then
			tab[k] = {read_types_arg[key](v)}
		else
			tab[k] = {v}
		end
	end


	self = self:gsub('#[^%s]+',function(w) return language and language.GetPhrase(w) or w end)

	local args = {}

	self = self:gsub('($%b{})', function(w) local value = w:sub(3, -2) table.insert(args, tab[value] or (read_types_arg_nil[value] and {read_types_arg_nil[value]()} or {w}) ) return "\1" end)

	local result = {}
	table.insert(result, clr)

	local args_n = 0
	local word = ""
	for i = 1, string.len(self) do
		local char = self[i]
		word = word .. char
		if char == "\1" then
			word = string.sub(word,1,-2)
			args_n = args_n + 1
			table.insert(result, word ); word = ""

			for _, var in ipairs( args[args_n] ) do
				table.insert(result,  var)
			end

			table.insert(result, clr)
		end
	end
	if word != "" then table.insert(result, word) end

	return unpack(result)
end
