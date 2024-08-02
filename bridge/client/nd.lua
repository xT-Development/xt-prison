if not lib.checkDependency('ND_Core', '2.0.0') then return end

--[[
    TO-DO:
    - Add compat events for jailing (if there is any)
]]

AddEventHandler('ND:characterLoaded', function()
    TriggerEvent('xt-prison:client:onLoad')
end)

AddEventHandler('ND:characterUnloaded', function()
    TriggerEvent('xt-prison:client:onUnload')
end)