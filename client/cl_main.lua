local xTc = require('modules.client')
local Utils = require('modules.shared')

jailTime = 0
PrisonBreakBlip = nil
PrisonBreakRadiusBlip = nil
PrisonZone = nil

-- Enter / Leave Prison (Keep Backwards Compat) --
RegisterNetEvent('prison:client:Enter', function(TIME) xTc.EnterPrison(TIME) end)
RegisterNetEvent('prison:client:Leave', function() xTc.ExitPrison() end)

-- Sync Alarm / Toggle Alarm --
RegisterNetEvent('xt-prison:client:AlarmSync', function(BOOL) xTc.PrisonAlarm(BOOL) end)

-- Jail Player Input Menu --
if Config.EnableJailCommand then
    RegisterNetEvent('qb-policejob:client:JailPlayerInput', function()
        local input = lib.inputDialog('Jail Player', {
            { type = 'number', label = 'Player Server ID', description = '', icon = 'hashtag' },
            { type = 'number', label = 'Jail Time', description = 'Months ( Minutes )', icon = 'hashtag' },
        })
        if not input then return end
        TriggerServerEvent("police:server:JailPlayer", input[1], tonumber(input[2]))
    end)
end

-- Player Load --
local function playerLoaded()
    jailTime = lib.callback.await('xt-prison:server:GetJailTime', false)
    if jailTime ~= 0 and jailTime > 0 then TriggerEvent('prison:client:Enter', jailTime) end
    if GlobalState.PrisonAlarms then xTc.PrisonAlarm(true) else xTc.PrisonAlarm(false) end
    xTc.PrisonZone()
    xTc.HackZones()
end

-- Player Unload --
local function playerUnload()
    xTc.RemoveHackZones()
    PrisonZone:remove()
    if DoesBlipExist(PrisonBreakBlip) then RemoveBlip(PrisonBreakBlip) end
end

AddEventHandler('onResourceStart', function(resource) if resource == GetCurrentResourceName() then playerLoaded() end end)
AddEventHandler('onResourceStop', function(resource) if resource == GetCurrentResourceName() then playerUnload() end end)
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function() playerLoaded() end)
RegisterNetEvent('QBCore:Client:OnPlayerUnload', function() playerUnload() end)