easy("util.time")


function object_cooldown(object, name, time)
	if not object.__CoolDowns then object.__CoolDowns = {} end

	if time == nil then
		object.__CoolDowns[name] = nil
		return
	end

	if object.__CoolDowns[name] and (object.__CoolDowns[name] + time) > SysTime() then
		return true, math.Round(object.__CoolDowns[name] - SysTime(), 2)
	end

	object.__CoolDowns[name] = SysTime()
end

cooldown_data = cooldown_data or {}

function cooldown(name, time)
	if time == nil then
		cooldown_data[name] = nil
		return
	end

	if cooldown_data[name] and (cooldown_data[name] + time) > SysTime() then
		return true, math.Round(cooldown_data[name] - SysTime(), 2)
	end

	cooldown_data[name] = SysTime()
end