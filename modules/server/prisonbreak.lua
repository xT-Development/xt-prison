local globalState       = GlobalState
local db                = require 'modules.server.db'
local prisonBreakcfg    = require 'configs.prisonbreak'
local utils             = require 'modules.server.utils'
local ox_doorlock       = exports.ox_doorlock

local prisonModules = {}

-- Breakout of Prison --
function prisonModules.prisonBreakout(src)
    local playerState = Player(src)?.state
    if not playerState then return end

    setJailTime(src, 0) -- Set jail time to zero

    -- Delete Confiscated Inv --
    local CID = getCharID(src)
    local confiscatedItems = MySQL.scalar.await(db.GET_ITEMS, { CID })
    if next(confiscatedItems) then
        MySQL.query.await(db.CLEAR_CONFISCATED_ITEMS, { CID })
    end

    return (playerState.jailTime == 0)
end

-- Countdown for Alarms to Turn Off --
function prisonModules.alarmCountdown()
    return SetTimeout((prisonBreakcfg.AlarmLength * 60000), function()
        globalState.prisonAlarms = false
        for x = 1, #prisonBreakcfg.HackZones do
            local door = ox_doorlock:getDoorFromName(prisonBreakcfg.HackZones[x].gate)
            TriggerEvent('ox_doorlock:setState', door.id, true)
        end
    end)
end

-- Set Terminal Hacked State --
function prisonModules.setTerminalHackedState(src, terminalID, setState)
    local dist = utils.terminalDistanceCheck(src, terminalID)
    if not dist then return end

    if globalState[('PrisonTerminal_%s'):format(terminalID)].isHacked == setState then return end

    if globalState[('PrisonTerminal_%s'):format(terminalID)].lastHacker ~= src then
        local cid = getCharID(src)
        utils.banPlayer(src, cid)
        return
    end

    local isBusy = globalState[('PrisonTerminal_%s'):format(terminalID)].isBusy
    globalState[('PrisonTerminal_%s'):format(terminalID)] = {
        isHacked = setState,
        isBusy = isBusy,
    }

    if setState then
        local door = ox_doorlock:getDoorFromName(prisonBreakcfg.HackZones[terminalID].gate)
        TriggerEvent('ox_doorlock:setState', door.id, false)
        prisonModules.setTerminalCooldown(terminalID)
    end

    return (globalState[('PrisonTerminal_%s'):format(terminalID)].isHacked == setState)
end

-- Set Terminal Busy State --
function prisonModules.setTerminalBusyState(src, terminalID, setState)
    local dist = utils.terminalDistanceCheck(src, terminalID)
    if not dist then return end

    if globalState[('PrisonTerminal_%s'):format(terminalID)].isBusy == setState then return end

    local isHacked = globalState[('PrisonTerminal_%s'):format(terminalID)].isHacked
    globalState[('PrisonTerminal_%s'):format(terminalID)] = {
        isHacked = isHacked,
        isBusy = setState,
        lastHacker = src
    }

    return (globalState[('PrisonTerminal_%s'):format(terminalID)].isBusy == setState)
end

-- Set Terminal Cooldown --
function prisonModules.setTerminalCooldown(terminalID)
    SetTimeout((prisonBreakcfg.TerminalCooldowns * 60000), function()
        local door = ox_doorlock:getDoorFromName(prisonBreakcfg.HackZones[terminalID].gate)
        globalState[('PrisonTerminal_%s'):format(terminalID)] = {
            isHacked = false,
            isBusy = false,
            lastHacker = nil
        }
        TriggerEvent('ox_doorlock:setState', door.id, true)
    end)
end

return prisonModules