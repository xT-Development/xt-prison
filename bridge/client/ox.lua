if GetResourceState('ox_core') ~= 'started' then return end

AddEventHandler('ox:playerLoaded', function()
    TriggerEvent('xt-prison:client:onLoad')
end)

AddEventHandler('ox:playerLogout', function()
    TriggerEvent('xt-prison:client:onUnload')
end)