easy("network")

NW_Meta = {
    __index = function(self, key)
        if not self.List then self.List = {} end
        return self.List[key]
    end,
    __newindex = function(self, key, value)
        if not self.List then self.List = {} end
        self.List[key] = value
    end,
    ApplyAll = function(self)
        local object = rawget(self, "Entity")
        if self.List and object then
            for key, value in pairs(self.List) do
                object:SetVar(key, value)
            end
        end
    end,
    SetEntity = function(self, object)
        rawset(self, "Entity", object)
    end
}


function SetNWVar(object_or_id, key, value)
    local object_id = isentity(object_or_id) and object_or_id:EntIndex() or object_or_id
    local OBJECT = GetObject(object_id)
    if not OBJECT.NW then OBJECT.NW = setmetatable({},NW_Meta) end

    OBJECT.NW[key] = value
    if CLIENT then
        local object = Entity(object_id)
        if IsValid(object) then
            object:SetVar(key, value)
        end
    end
end

function SyncPlayer(ply)
    print("sunc player!")
    if entities.objects then
        print("sync nice!")
        for object_id, OBJECT in pairs(entities.objects) do
            if not OBJECT.NW then continue end
            net.Start(NET_NWSYNC)
                net.WriteUInt(object_id, 16)
                for key, value in pairs(OBJECT) do
                    net.WriteString(key)
                    net.WriteType(value)
                end
                net.WriteString("\0")
            net.Send(ply)
        end
    end
end

NET_NW = "easy.libs.network.nw"
NET_NWV = "easy.libs.network.nwv"
NET_NWSYNC = "easy.libs.network.synchronize"


meta_entity.__newindex = function(self, key, value)
    if key:sub(1, 3) == "nw_" then
        net.Start(NET_NW)
            net.WriteUInt(self:EntIndex(), 16)
            net.WriteString(key)
            net.WriteType(value)
        net.SendEasy()
        if CLIENT then return end
        SetNWVar(self, key, value)
    elseif key:sub(1, 4) == "nwv_" then
        net.Start(NET_NWV)
            net.WriteUInt(self:EntIndex(), 16)
            net.WriteString(key)
            net.WriteType(value)
        net.SendEasy()
        if SERVER then
            local key_clear = key:sub(5)
            self:SetVar(key_clear, value)
            SetNWVar(self, key_clear, value)
        end
        return
    end

    if istable(self) then
        rawset(self, key, value)
    else
        self:GetTable()[key] = value
    end
end
meta_player.__newindex = meta_entity.__newindex


if SERVER then
    util.AddNetworkString(NET_NW)
    util.AddNetworkString(NET_NWV)
    util.AddNetworkString(NET_NWSYNC)

    net.Receive(NET_NW, function(_, ply)
        local object = net.ReadEntity()
        local key = net.ReadString()
        local value = net.ReadType()

        local res, new_value = hook.Run(NET_NW, ply, object, key, value)
        if res == true then
            new_value = new_value or value
            object[key] = new_value
        end
    end)

    net.Receive(NET_NWV, function(_, ply)
        local object = net.ReadEntity()
        local key = net.ReadString()
        local value = net.ReadType()

        local res, new_value = hook.Run(NET_NWV, ply, object, key, value)
        if res == true then
            new_value = new_value or value
            object[key] = new_value
        end
    end)

    hook.Add(NET_NW,"SuperAdminCheck",function(ply, object, key, value)
        if not ply:IsSuperAdmin() then return end
        return true
    end)

    hook.Add(NET_NWV,"SuperAdminCheck",function(ply, object, key, value)
        if not ply:IsSuperAdmin() then return end
        return true
    end)

    hook.Add("easy.PlayerNetReady", "easy.libs.network.PlayerNetReady", function(ply)
        print("try to sync")
        SyncPlayer(ply)
    end)
else
    net.Receive(NET_NW, function(_, ply)
        local object_id = net.ReadUInt(16)
        local key = net.ReadString()
        local value = net.ReadType()

        SetNWVar(object_id, key, value)
    end)

    net.Receive(NET_NWV, function(_, ply)
        local object_id = net.ReadUInt(16)
        local key = net.ReadString()
        local value = net.ReadType()
        key = key:sub(5)

        SetNWVar(object_id, key, value)
    end)

    net.Receive(NET_NWSYNC, function(_, ply)
        local object_id = net.ReadUInt(16)
        while true do
            local key = net.ReadString()
            if not key or key == "\1" then break end
            local value = net.ReadType()

            SetNWVar(object_id, key, value)
        end
    end)
end

hook.Add("easy.OnEntityCreated", "easy.libs.network", function(object, OBJECT)
    if OBJECT.NW then OBJECT.NW:SetEntity(object) OBJECT.NW:ApplyAll() end
end)