local Utils = require('modules.shared')
local xTs = {}

function xTs.LiferCheck(source)
    local Player = QBCore.Functions.GetPlayer(source)
    local CID = Player.PlayerData.citizenid
    local jailTime = Player.PlayerData.metadata['injail']
    local callback = false
    for _,x in pairs(Config.Lifers) do
        if CID == x then
            if jailTime ~= 999 then Player.Functions.SetMetaData('injail', 999) end
            callback = true
            break
        end
    end
    return callback
end

-- Server Log --
function xTs.Log(logName, color, title, text)
    TriggerEvent("qb-log:server:CreateLog", logName, title, color, text, false, cache.resource) -- Added resource for better logging
end

-- Check if is Cop --
function xTs.isCop(source)
    local Player = QBCore.Functions.GetPlayer(source)
    local callback = false
    local type = type(Config.PoliceJobs)
    if type == 'string' then
        if Player.PlayerData.job.name == Config.PoliceJobs then callback = true end
    elseif type == 'table' then
        for _, t in pairs(Config.PoliceJobs) do
            if Player.PlayerData.job.name == t then callback = true break end
        end
    end
    return callback
end

-- Breakout of Prison --
function xTs.PrisonBreakout()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local name = Player.PlayerData.charinfo.firstname..Player.PlayerData.charinfo.lastname
    local CID = Player.PlayerData.citizenid
    local jailTime = Player.PlayerData.metadata['injail']

    if jailTime ~= 0 and jailTime > 0 then
        Player.Functions.SetMetaData('injail', 0)
        -- Delete Confiscated Inv --
        local getInv = MySQL.query.await('SELECT * FROM ox_inventory WHERE owner = ? AND name = ?', { CID, CID })
        if getInv and getInv[1] then
            MySQL.query('DELETE FROM ox_inventory WHERE name = ?', { CID })
            Utils.Debug('Prison Breakout', 'Player: '..name..' | Deleted Prison Inv: '..CID)
        end
    end
end

-- Countdown for Alarms to Turn Off --
function xTs.AlarmCountdown()
    Utils.Debug('Prison Alarm Countdown Started')
    SetTimeout((Config.PrisonBreak.alarmLength * 60000), function()
        GlobalState.PrisonAlarms = false
        TriggerClientEvent('xt-prison:client:AlarmSync', -1, false)
        for x = 1, #Config.PrisonBreak.hackZones do
            local door = exports.ox_doorlock:getDoorFromName(Config.PrisonBreak.hackZones[x].gate)
            TriggerEvent('ox_doorlock:setState', door.id, true)
        end
        Utils.Debug('Prison Alarm Countdown Ended')
    end)
    return
end

-- Set Terminal Hacked State --
function xTs.TerminalHackedState(ID, BOOL)
    local pCoords = GetEntityCoords(GetPlayerPed(source))
    local hackCoords = Config.PrisonBreak.hackZones[ID].coords
    local dist = #(hackCoords - pCoords)
    if dist >= 5 then return end
    if Config.PrisonBreak.hackZones[ID].isHacked == BOOL then return end
    Config.PrisonBreak.hackZones[ID].isHacked = BOOL
    if BOOL then
        local door = exports.ox_doorlock:getDoorFromName(Config.PrisonBreak.hackZones[ID].gate)
        TriggerEvent('ox_doorlock:setState', door.id, false)
        xTs.TerminalCooldown(ID)
    end
end

-- Set Terminal Busy State --
function xTs.TerminalBusyState(ID, BOOL)
    local pCoords = GetEntityCoords(GetPlayerPed(source))
    local hackCoords = Config.PrisonBreak.hackZones[ID].coords
    local dist = #(hackCoords - pCoords)
    if dist >= 5 then return end
    if Config.PrisonBreak.hackZones[ID].isBusy == BOOL then return end
    Config.PrisonBreak.hackZones[ID].isBusy = BOOL
end

-- Set Terminal Cooldown --
function xTs.TerminalCooldown(ID)
    Utils.Debug('Prison Terminal Cooldown Started', 'Terminal: '..ID)
    SetTimeout((Config.PrisonBreak.terminalCooldowns * 60000), function()
        local door = exports.ox_doorlock:getDoorFromName(Config.PrisonBreak.hackZones[ID].gate)
        Config.PrisonBreak.hackZones[ID].isBusy = false
        Config.PrisonBreak.hackZones[ID].isHacked = false
        TriggerEvent('ox_doorlock:setState', door.id, true)
        Utils.Debug('Prison Terminal Cooldown Ended', 'Terminal: '..ID)
    end)
end

return xTs