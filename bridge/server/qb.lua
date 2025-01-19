if GetResourceState('qb-core') ~= 'started' or GetResourceState('qbx_core') == 'started' then return end

local QBCore = exports['qb-core']:GetCoreObject()

function getPlayer(src)
    return QBCore.Functions.GetPlayer(src)
end

function getCharID(src)
    local player = getPlayer(src)
    return player and player.PlayerData.citizenid or nil
end

function getCharName(src)
    local player = getPlayer(src)
    local playerData = player.PlayerData
    return ("%s %s"):format(playerData.charinfo.firstname, playerData.charinfo.lastname)
end

function charHasJob(src, job)
    local player = getPlayer(src)
    return player and (player.PlayerData.job.name == job) or false
end

function setCharJob(src, job)
    local player = getPlayer(src)
    return player and player.Functions.SetJob(job) or nil
end

function setJailTime(src, time)
    local playerState = Player(src)?.state
    local player = getPlayer(src)
    if not playerState or not player then return end

    playerState.jailTime = time
    playerState.xtprison_identifier = getCharID(src)
    player.Functions.SetMetaData('injail', time)

    while playerState and (playerState.jailTime ~= time) do
        Wait(1)
    end

    syncJailCompatibility(src, time)

    return playerState and (playerState.jailTime == time) or false
end exports('SetJailTime', setJailTime)