if GetResourceState('es_extended') ~= 'started' then return end

--[[
    TO-DO:
    - Add compat events for jailing (if there is any)
]]

AddEventHandler('esx:playerLoaded', function()
    TriggerEvent('xt-prison:client:onLoad')
end)

AddEventHandler('esx:onPlayerLogout', function()
    TriggerEvent('xt-prison:client:onUnload')
end)