if GetResourceState('ox_core') ~= 'started' then return end

local Ox = require '@ox_core.lib.init'

function getPlayer(id)
    return Ox.GetPlayer(id) --luacheck: ignore
end

function getCharID(src)
    local player = getPlayer(src)
    return player and player.charId or nil
end

function getCharName(src)
    local player = getPlayer(src)
    return player.name
end

function charHasJob(src, job)
    local player = getPlayer(src)
    local group, rank = player.getGroup(job)
    return (group ~= nil)
end

function setCharJob(src, job)
    local player = getPlayer(src)
    return player and player.setGroup(job, 0) or false
end

function setJailTime(src, time)
    local playerState = Player(src)?.state
    local player = getPlayer(src)
    if not playerState or not player then return end

    playerState.jailTime = time
    playerState.xtprison_identifier = getCharID(src)

    while playerState and (playerState.jailTime ~= time) do
        Wait(1)
    end

    syncJailCompatibility(src, time)

    return playerState and (playerState.jailTime == time) or false
end exports('SetJailTime', setJailTime)