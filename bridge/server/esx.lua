if GetResourceState('es_extended') ~= 'started' then return end

local ESX = exports['es_extended']:getSharedObject()

function getPlayer(src)
    return ESX.GetPlayerFromId(src)
end

function getCharID(src)
    local player = getPlayer(src)
    return player and player.identifier or nil
end

function getCharJob(src)
    -- TODO
    return
end

function setCharJob(src, job)
    -- TODO
    return
end

function setJailTime(src, time)
    local playerState = Player(src)?.state
    local player = getPlayer(src)
    if not playerState or not player then return end

    playerState.jailTime = time

    return playerState and (playerState.jailTime == time) or false
end