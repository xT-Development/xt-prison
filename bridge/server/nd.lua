if not lib.checkDependency('ND_Core', '2.0.0') then return end

NDCore = {}

lib.load('@ND_Core.init')

function getPlayer(src)
    return NDCore.getPlayer(src)
end

function getCharID(src)
    local player = getPlayer(src)
    return player and player.id or nil
end

function getCharName(src)
    local player = getPlayer(src)
    return player.fullname
end

function charHasJob(src, job)
    local player = getPlayer(src)
    return player and player.groups[job] or false
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