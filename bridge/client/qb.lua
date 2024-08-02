if GetResourceState('qb-core') ~= 'started' then return end

local prisonModules = require 'modules.client.prison'

-- Compat Events --
RegisterNetEvent('police:SetCopCount', function(amount)
    CurrentCops = amount
end)

RegisterNetEvent('prison:client:Enter', function(setTime)
    prisonModules.enterPrison(setTime)
end)

RegisterNetEvent('prison:client:Leave', function()
    prisonModules.exitPrison(false)
end)

RegisterNetEvent('prison:client:UnjailPerson', function()
    prisonModules.exitPrison(true)
end)

-- Load / Unload Events --
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    TriggerEvent('xt-prison:client:onLoad')
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    TriggerEvent('xt-prison:client:onUnload')
end)