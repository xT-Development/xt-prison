if not lib.checkDependency('ND_Core', '2.0.0') then return end

RegisterNetEvent('ND:characterLoaded', function()
    TriggerEvent('xt-prison:client:onLoad')
end)

RegisterNetEvent('ND:characterUnloaded', function()
    TriggerEvent('xt-prison:client:onUnload')
end)