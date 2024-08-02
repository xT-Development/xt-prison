local globalState       = GlobalState
local prisonBreakcfg    = require 'configs.prisonbreak'
local prisonModules     = require 'modules.server.prisonbreak'

-- Toggle Prison Alarms --
lib.callback.register('xt-prison:server:setPrisonAlarms', function(source, setState)
    if globalState.prisonAlarms == setState then return end

    globalState.prisonAlarms = setState

    if setState then
        prisonModules.alarmCountdown()
    end

    return (globalState.prisonAlarms == setState)
end)

-- Prisonbreak Terminal States --
lib.callback.register('xt-prison:server:setTerminalHackedState', function(source, terminalID, setState)
    return prisonModules.setTerminalHackedState(source, terminalID, setState)
end)

lib.callback.register('xt-prison:server:setTerminalBusyState', function(source, terminalID, setState)
    return prisonModules.setTerminalBusyState(source, terminalID, setState)
end)

-- Remove Hacking Item(s) --
lib.callback.register('xt-prison:server:removePrisonbreakItems', function(source)
    local callback = false
    local requiredItems = prisonBreakcfg.RequiredItems
    local removedCount = 0

    for requiredItem, requiredCount in pairs(requiredItems) do
        if exports.ox_inventory:RemoveItem(source, requiredItem, (requiredCount or 1)) then
            removedCount += 1
            if removedCount == #requiredItems then
                callback = true
                break
            end
        end
    end

    return callback
end)

-- Can Hack Terimnal Check --
lib.callback.register('xt-prison:server:canHackTerminal', function(source, terminalID)
    local terminal = globalState[('PrisonTerminal_%s'):format(terminalID)]
    return (not terminal?.isHacked and not terminal?.isBusy) and true or false
end)

-- Breakout of Prison --
lib.callback.register('xt-prison:server:triggerBreakout', function(source)
    return prisonModules.prisonBreakout()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    globalState.prisonAlarms = false

    -- Reset Hack Zones & Doors --
    for x = 1, #prisonBreakcfg.HackZones do
        local door = exports.ox_doorlock:getDoorFromName(prisonBreakcfg.HackZones[x].gate)
        if door then
            TriggerEvent('ox_doorlock:setState', door.id, true)
        end

        globalState[('PrisonTerminal_%s'):format(x)] = nil
    end
end)

-- Create Hacking Terminals --
AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for x = 1, #prisonBreakcfg.HackZones do
        globalState[('PrisonTerminal_%s'):format(x)] = {
            isHacked = false,
            isBusy = false
        }
    end
end)