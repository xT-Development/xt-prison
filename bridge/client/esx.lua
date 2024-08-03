if GetResourceState('es_extended') ~= 'started' then return end

RegisterNetEvent('esx:playerLoaded', function()
    TriggerEvent('xt-prison:client:onLoad')
end)

RegisterNetEvent('esx:onPlayerLogout', function()
    TriggerEvent('xt-prison:client:onUnload')
end)