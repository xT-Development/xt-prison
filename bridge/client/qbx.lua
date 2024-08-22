if GetResourceState('qbx_core') ~= 'started' then return end

-- Load / Unload Events --
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    TriggerEvent('xt-prison:client:onLoad')
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    TriggerEvent('xt-prison:client:onUnload')
end)