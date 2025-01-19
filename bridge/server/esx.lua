if GetResourceState('es_extended') ~= 'started' then return end

local ESX = exports['es_extended']:getSharedObject()

function getPlayer(src)
    return ESX.GetPlayerFromId(src)
end

function getCharID(src)
    local player = getPlayer(src)
    return player and player.identifier or nil
end

function getCharName(src)
    local player = getPlayer(src)
    return player.getName()
end

function charHasJob(src, job)
    local player = getPlayer(src)
    return player and (player.job.name == job) or false
end

function setCharJob(src, job)
    local player = getPlayer(src)
    return player and player.setJob(job, 0) or nil
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