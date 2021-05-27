/*
	gmod-easy Loaded
	GitHub: https://github.com/JTaylerJ/gmod-easy
*/

easy = {}
easy.CopyVar = function(self, key, value)
	rawset(self, key, value)
	return value
end
easy.CopyTable = function(self, tbl)
	local copied = {}
	if not tbl then return end
	for k, v in pairs(tbl) do
		if copied[k] then continue end
		copied[k] = true
		if istable(v) then
			if not copied[v] then continue end
			copied[v] = true

			local new_tbl = easy.CopyVar(self, k, {})
			easy.CopyTable(new_tbl, v)
			continue
		end

		easy.CopyVar(self, k, v)
	end
	return self
end
easy.L = easy.L or {}
easy.L.L = easy.L
easy.L.easy = easy
easy.L.debug = debug
easy.LL = easy.LL or {}
easy.LL.easy = nil
easy.LL.L = L
easy._G = easy._G or easy.CopyTable({}, _G)
easy.L._G = _G
easy._meta = {
	__index = function(self, key)
		if not rawget(rawget(self, "L"), key) then
			if easy.L[key] then
				return easy.L[key]
			elseif rawget(easy._G,key) or rawget(_G, key) then
				easy.L[key] = easy._G[key] or _G[key]
				return easy.L[key]
			end
		end

		return rawget(rawget(self, "L"), key)
	end,
	__newindex = function(self, key, value)
		if value then
			local tp = type(value)
			if tp == "string" then
				local start = value[1]
				if start == ":" then
					value = value
				elseif value == ">" then
					value = CompileString(value:sub(2), "")
				end
			end
		end
		self.L[key] = value
	end,
	__tostring = function(self, key, value)
		return "gmod-easy"
	end,
	__call = function(self, module_name)
		if module_name == "easy" then return setfenv(1, easy) end
		if module_name == "_G" then return setfenv(1, _G) end

		if module_name then
			easy.LL[module_name] = easy.LL[module_name] or {}
			local your_module = easy.LL[module_name]
			your_module.L = your_module.L or {}
			your_module.LL = your_module.LL or {}

			easy.L[module_name] = rawget(your_module, "L")
			debug.setmetatable(your_module, easy._meta)
			return setfenv(1, your_module)
		else
			return setfenv(1, easy)
		end
	end,
	__metatable = function(self)
		return nil
	end
}
debug.setmetatable(easy, easy._meta)


easy()


if not debug.getmetatable(function() end) then
	debug.setmetatable(function() end, {})
end

_registry = debug.getregistry()
meta_color = _registry.Color
meta_player = _registry.Player
meta_panel = _registry.Panel
meta_entity = _registry.Entity
meta_string = debug.getmetatable("")
meta_function = debug.getmetatable(function() end)


easy("color")


function meta_color:Alpha(value)
	self.a = value
end

function meta_color:Copy()
	return Color(self.r, self.g, self.b)
end


easy("log")

function console(...)
	MsgC(COLOR_RED, "«", COLOR_RED,"¡", COLOR_ReD, "»")
end


easy("config")
configs = configs or {}

function setConfig(project, data)
	configs[project] = data
end

function getConfig(project, index, ifnil)
	return configs[project] and configs[project][index] or ifnil
end

easy("loader")

rules_file = {
	sh_ = 1,
	sv_ = 2,
	cl_ = 3,

	["sh_loader.lua"] = 1,
	["sh_init.lua"] = 2,
	["sh_config.lua"] = 3,

	["sv_loader.lua"] = 1,
	["sv_init.lua"] = 2,
	["sv_config.lua"] = 3,


	["cl_loader.lua"] = 1,
	["cl_init.lua"] = 2,
	["cl_config.lua"] = 3,
}


function sortFiles(tbl)
	table.sort(tbl, function(a, b)
		local exp1, exp2 = a:sub(1,3), b:sub(1,3)
		if exp1 != exp2 then
			if rules_file[exp1] and rules_file[exp2] then
				return rules_file[exp1] < rules_file[exp2]
			else
				return rules_file[exp1] or false
			end
		end
		if rules_file[a] and rules_file[b] then
			return rules_file[a] < rules_file[b]
		elseif rules_file[a] and not rules_file[b] then
			return true
		elseif not rules_file[a] and rules_file[b] then
			return false
		end


		return a < b
	end)
end

rules_folder = {
	autorun = 0,
	lib = 1,
	libs = 2,

	modules = 3,
	core = 4,
}

function sortFolders(tbl)
	table.sort(tbl, function(a, b)
		if rules_folder[a] and rules_folder[b] then
			return rules_folder[a] < rules_folder[b]
		elseif rules_folder[a] and not rules_folder[b] then
			return true
		elseif not rules_folder[a] and rules_folder[b] then
			return false
		end

		return a < b
	end)
end

function readConfig(config)
	local name = config.project
	local data = config.data
	setConfig(name, data)
end

custom_load_file = {}
custom_load_file["config.json"] = function(self, dir)
	local data = file.Read(dir)
	if not data then return end
	local data = util.JSONToTable(data)
	if not data then return end
	readConfig(data)
end


function loadFile(dir)
	print("loading", dir)
	local fl = string.GetFileFromFilename(dir)
	if custom_load_file[fl] then
		custom_load_file(fl)
		return
	end

	local ext = string.GetExtensionFromFilename(dir)

	if ext == "lua" then
		local start = fl:sub(1,3)
		if start == "sv_" then
			if SERVER then include(dir) end
		elseif start == "sh_" then
			AddCSLuaFile(dir)
			include(dir)
		elseif start == "cl_" then
			AddCSLuaFile(dir)
			if CLIENT then include(dir) end
		elseif start == "lg_" then
			AddCSLuaFile(dir)
			include(dir)
		end
	end
end

function loadDir(dir)
	local files, folders = file.Find(dir .. "/*", "LUA")
	if not files then error("Path not found!") end


	sortFiles(files)
	for k, v in pairs(files) do
		loadFile(dir .. "/" .. v)
	end

	sortFolders(folders)
	for k, v in pairs(folders) do
		loadDir(dir .. "/" .. v)
	end
end

loadDir("easy")