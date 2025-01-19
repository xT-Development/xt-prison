if GetResourceState('qbx_core') == 'started' then
    if not lib.checkDependency('qbx_core', '1.18.0') then
        return lib.print.error('qbx_core v1.18.0 is required for xt-prison') -- Requires 1.18.0 for HasGroup export || https://github.com/Qbox-project/qbx_core/blob/c6f2b96a3644edce5958c76b447a98afa4801475/server/functions.lua#L447
    end
else return end

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