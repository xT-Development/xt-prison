if GetResourceState('es_extended') ~= 'started' then return end

--[[
    TO-DO:
    - Add compat events for jailing (if there is any)
]]

RegisterNetEvent('esx:playerLoaded', function()
    TriggerEvent('xt-prison:client:onLoad')
end)

RegisterNetEvent('esx:onPlayerLogout', function()
    TriggerEvent('xt-prison:client:onUnload')
end)