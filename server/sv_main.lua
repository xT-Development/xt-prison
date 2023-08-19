local xTs = require('modules.server')
local Utils = require('modules.shared')

-- Prisonbreak Terminal States --
RegisterNetEvent('xt-prison:server:TerminalHackedState', function(ID, BOOL) xTs.TerminalHackedState(ID, BOOL) end)
RegisterNetEvent('xt-prison:server:TerminalBusyState', function(ID, BOOL) xTs.TerminalBusyState(ID, BOOL) end)

-- Breakout of Prison --
RegisterNetEvent('xt-prison:server:Breakout', function() xTs.PrisonBreakout() end)

-- Remove Player Job --
lib.callback.register('xt-prison:server:RemoveJob', function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local callback = false
    if Player.PlayerData.job.name ~= "unemployed" then
        if Player.Functions.SetJob("unemployed") then
            QBCore.Functions.Notify(src, 'You lost your job!', 'error')
            callback = true
        end
    else
        callback = true
    end
    return callback
end)

-- Remove Items on Entry --
lib.callback.register('xt-prison:server:RemoveItems', function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(source)
    local callback = false
    if not Player then return callback end
    local CID = Player.PlayerData.citizenid

    local getInv = MySQL.query.await('SELECT * FROM ox_inventory WHERE owner = ? AND name = ?', { CID, CID })

    if getInv and getInv[1] then
        callback = true
    else
        if exports.ox_inventory:ConfiscateInventory(source) then
            QBCore.Functions.Notify(source, 'Your items were confiscated!', 'error')
            callback = true
        end
    end
    return callback
end)

-- Return Items Leaving --
lib.callback.register('xt-prison:server:ReturnItems', function(source)
    local callback = false
    if exports.ox_inventory:ReturnInventory(source) then
        QBCore.Functions.Notify(source, 'Your items were returned!', 'success')
        callback = true
    end
    return callback
end)

-- Can Hack Terimnal Check --
lib.callback.register('xt-prison:server:CanHackTerminal', function(source, ID)
    local zones = Config.PrisonBreak.hackZones
    local callback = false
    if not zones[ID].isHacked and not zones[ID].isBusy then callback = true end
    return callback
end)

-- Set Jail Time --
lib.callback.register('xt-prison:server:SetJailStatus', function(source, TIME)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local jailTime = Player.PlayerData.metadata['injail']
    local callback = false
    if jailTime == TIME then return true end
    if TIME < 0 then Player.Functions.SetMetaData('injail', 0) return end
    if jailTime > TIME then
        Player.Functions.SetMetaData('injail', TIME)
        callback = true
    else
        callback = true
    end
    return callback
end)

-- Get Jail Time --
lib.callback.register('xt-prison:server:GetJailTime', function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local jailTime = Player.PlayerData.metadata['injail']
    return jailTime
end)

-- Toggle Prison Alarms to GlobalState --
lib.callback.register('xt-prison:server:PrisonAlarms', function(source, BOOL)
    if GlobalState.PrisonAlarms == BOOL then return end
    GlobalState.PrisonAlarms = BOOL
    if BOOL then TriggerClientEvent('xt-prison:client:AlarmSync', -1, true) xTs.AlarmCountdown() end
    return
end)

-- Check if Player is a Lifer --
lib.callback.register('xt-prison:server:LiferCheck', function(source) return xTs.LiferCheck(source) end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for x = 1, #Config.PrisonBreak.hackZones do
            local door = exports.ox_doorlock:getDoorFromName(Config.PrisonBreak.hackZones[x].gate)
            TriggerEvent('ox_doorlock:setState', door.id, true)
        end
    end
end)

GlobalState.PrisonAlarms = false