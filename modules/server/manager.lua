local db    = require 'modules.server.db'
local utils = require 'modules.server.utils'

local jailedPlayers = {}

--------------------
-- SYNC JAIL TIME
local function savePlayerJailTime(src)
    if not jailedPlayers[src] then return end
    local state = Player(src).state
    local jailTime = state and state.jailTime or 0
    local cid = getCharID(src) or state and state.xtprison_identifier
    if not cid then return lib.print.debug('player core identifier not found, not saving jailtime') end
    MySQL.insert.await(db.UPDATE_JAILTIME, { cid, jailTime })
end

local function syncAllJailedPlayersJailTime()
    for src in pairs(jailedPlayers) do
        savePlayerJailTime(src)
    end
end

AddEventHandler('playerDropped', function(reason) -- Sync single player's jail time to db
    local src = source
    savePlayerJailTime(src)
    jailedPlayers[src] = nil
end)

AddEventHandler('onResourceStop', function(resource) -- Sync all jailed players time to db
    if resource ~= GetCurrentResourceName() then return end
    syncAllJailedPlayersJailTime()
end)

-- Handles syncing all jailed player's jail time to the db
local syncLoop
syncLoop = lib.timer(120000, function()
    syncAllJailedPlayersJailTime()
    syncLoop:restart()
end, true)

--------------------
-- TIME REDUCTION
local function reduceAllJailedPlayersTimes()
    for src in pairs(jailedPlayers) do
        src = (type(src) == "number") and src or tonumber(src)
        local isLifer = utils.liferCheck(src)
        if not isLifer then
            local state = Player(src).state
            local jailTime = state and state.jailTime or 0
            local newJailTime = (jailTime - 1)
            if newJailTime <= 0 then
                newJailTime = 0

                lib.notify(src, {
                    title = locale('notify.checkout'),
                    icon = 'fas fa-unlock',
                    type = 'success'
                })
            end

            state.jailTime = newJailTime
        end
    end
end

-- Handles reducing time for all jailed players
local timeReductionLoop
timeReductionLoop = lib.timer(60000, function()
    reduceAllJailedPlayersTimes()
    timeReductionLoop:restart()
end, true)


-- Functions to manage the jailedPlayers table
-- Implemented with the purpose of moving time reduction loops and state management to the server
-- so that the clients are making less calls to the server. Also, statebag security.
-- We still manipulate the player state for jailTime, but use this table to simply manage ONLY the jailed players
local manager = {}

function manager.addToJailedPlayers(src)
    if jailedPlayers[src] then
        return
    end

    savePlayerJailTime(src) -- Save initial time to db on entry
    jailedPlayers[src] = true
end

function manager.removeFromJailedPlayers(src)
    if not jailedPlayers[src] then
        return
    end

    savePlayerJailTime(src) -- Save their time as they are removed
    jailedPlayers[src] = nil
end

function manager.isPlayerJailed(src)
    return (jailedPlayers[src] ~= nil)
end exports('isPlayerJailed', manager.isPlayerJailed)

function manager.getJailedPlayers() -- Get jailed players table
    return jailedPlayers
end exports('getJailedPlayers', manager.getJailedPlayers)

function manager.getJailedPlayersRoster() -- Return jailed players as a roster
    local roster = {}

    for src in pairs(jailedPlayers) do
        src = type(src) == "number" and src or tonumber(src)
        local state = Player(src).state
        if state then
            local statusStr = (state.jailTime > 0) and (locale('notify.time_remaining')):format(state.jailTime) or locale('notify.awaiting_checkout')
            local charName = getCharName(src)
            roster[#roster + 1] = {
                title = charName,
                description = statusStr,
                icon = 'fas fa-user-lock',
                private = {
                    source = src,
                    name = charName,
                    jailTime = state.jailTime
                }
            }
        end
    end

    return roster
end

return manager