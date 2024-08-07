if GetResourceState('qb-core') ~= 'started' then return end

local QBCore = exports['qb-core']:GetCoreObject()
local config = require 'configs.server'
local utils =  require 'modules.server.utils'

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