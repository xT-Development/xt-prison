if GetResourceState('qbx_core') ~= 'started' then return end

local config = require 'configs.server'

function getPlayer(src)
    return exports.qbx_core:GetPlayer(src)
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
    return exports.qbx_core:HasGroup(src, job)
end

function setCharJob(src, job)
    local player = getPlayer(src)
    return player and player.Functions.SetJob(config.UnemployedJobName) or nil
end

function setJailTime(src, time)
    local playerState = Player(src)?.state
    local player = getPlayer(src)
    if not playerState or not player then return end

    playerState.jailTime = time
    player.Functions.SetMetaData('injail', time)
    Wait(100)

    return playerState and (playerState.jailTime == time) or false
end exports('SetJailTime', setJailTime)