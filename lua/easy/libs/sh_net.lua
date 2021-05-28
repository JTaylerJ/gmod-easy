net.SendEasy = function(object)
    if SERVER then
        if object then
            net.Send(object)
        else
            net.Broadcast()
        end
    else
        net.SendToServer()
    end
end