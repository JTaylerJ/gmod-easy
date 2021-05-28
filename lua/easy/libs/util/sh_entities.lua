easy("entities")

objects = objects or {}

function GetObject(object_id)
    if objects[object_id] then return objects[object_id] end
    objects[object_id] = {}
    return objects[object_id]
end

function meta_entity:GetObject()
    local object_id = self:EntIndex()
    return GetObject(object_id)
end



if SERVER then
    util.AddNetworkString("easy.libs.util.entities.ent_created")
    util.AddNetworkString("easy.libs.util.entities.ent_removed")
    util.AddNetworkString("easy.libs.util.entities.net_ready")

    hook.Add("OnEntityCreated", "easy.libs.util.entities", function(object)
        hook.Run("easy.OnEntityCreated", object)
        net.Start("easy.libs.util.entities.ent_created")
            net.WriteUInt(object:EntIndex(), 16)
        net.Broadcast()
    end)

    hook.Add("EntityRemoved", "easy.libs.util.entities", function(object)
        hook.Run("easy.OnEntityRemoved", object)
        net.Start("easy.libs.util.entities.ent_removed")
            net.WriteUInt(object:EntIndex(), 16)
        net.Broadcast()
    end)

    net.Receive("easy.libs.util.entities.net_ready", function(_, ply)
        print('require sync')
        if ply:cooldown("net_ready", 600) then return end
        print('give sync')
        hook.Run("easy.PlayerNetReady", ply, ply:GetObject())
    end)
end

if CLIENT then
    local OnEntityCreated = function(object)
        local OBJECT = object:GetObject()
        hook.Run("easy.OnEntityCreated", object, OBJECT)
    end

    net.Receive("easy.libs.util.entities.ent_created", function()
        local object_id = net.ReadUInt(16)
        objects[object_id] = GetObject

        local object = Entity(object_id)
        if IsValid(object) then OnEntityCreated(object) end
    end)

    hook.Add("NetworkEntityCreated", "easy.libs.util.entities.OnEntityCreated", function(object)
        if objects[object:EntIndex()] then
            OnEntityCreated(object)
        end
    end)

    net.Receive("easy.libs.util.entities.ent_removed", function(_, ply)
        local object = net.ReadEntity()
        local OBJECT = object:GetObject()
        if not IsValid(object) then return end
        hook.Run("easy.OnEntityRemoved", object, OBJECT)
    end)

    hook.Add("InitPostEntity", "easy.libs.util.entities.InitPostEntity", function()
        net.Start("easy.libs.util.entities.net_ready")
        net.SendEasy()
        hook.Run("easy.PlayerNetReady")
    end)
end
