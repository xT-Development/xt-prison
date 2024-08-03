local globalState           = GlobalState
local prisonModules         = require 'modules.client.prison'
local prisonBreakModules    = require 'modules.client.prisonbreak'

lib.callback.register('xt-prison:client:enterJail', function(setTime)
    return prisonModules.enterPrison(setTime)
end)

lib.callback.register('xt-prison:client:exitJail', function(isUnjailed)
    return prisonModules.exitPrison(isUnjailed)
end)

-- Jail Player Input Menu --
lib.callback.register('xt-prison:client:jailPlayerInput', function()
    local input = lib.inputDialog('Jail Player', {
        { type = 'number', label = 'Player Server ID', icon = 'user' },
        { type = 'number', label = 'Jail Time', description = 'Months ( Minutes )', icon = 'hourglass' },
    })
    if not input then return end

    return input
end)

-- Player Load --
local function playerLoaded()
    prisonModules.createPrisonZone()
    prisonBreakModules.createHackZones()
    prisonBreakModules.setPrisonAlarm(globalState?.prisonAlarms or false)

    Wait(500)

    local jailTime = lib.callback.await('xt-prison:server:initJailTime', false)
    if jailTime ~= 0 and jailTime > 0 then
        prisonModules.enterPrison(jailTime)
    end
end

-- Handlers --
AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    playerLoaded()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    prisonModules.prisonCleanup()
end)

AddEventHandler('xt-prison:client:onLoad', function()
    playerLoaded()
end)

AddEventHandler('xt-prison:client:onUnload', function()
    prisonModules.prisonCleanup()
end)

AddStateBagChangeHandler('prisonAlarms', nil, function(bagName, _, value)
    if bagName ~= 'global' then return end
    prisonBreakModules.setPrisonAlarm(value)
end)