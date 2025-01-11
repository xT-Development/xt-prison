local utils = require 'modules.server.utils'

-- View Jail Roster --
lib.callback.register('xt-prison:server:getJailRoster', function(source)
    return utils.generateJailRoster()
end)

-- Unjails Player via Roster --
lib.callback.register('xt-prison:server:unjailPlayerByRoster', function(source, targetSource)
    local isCop = utils.isCop(source)
    if not isCop then return false end

    local state = Player(targetSource).state
    if state and state.jailTime > 0 then
        setJailTime(targetSource, 0)

        lib.notify(targetSource, {
            title = locale('notify.freedom'),
            description = locale('notify.unjailed_by_roster')
        })
        Wait(3000)
        local released = lib.callback.await('xt-prison:client:exitJail', targetSource, true)
        return released
    end

    return state and (state.jailTime <= 0) or false
end)

-- Set Player Jail Time via Roster --
lib.callback.register('xt-prison:server:changePlayerJailTimeByRoster', function(source, targetSource, newTime)
    local isCop = utils.isCop(source)
    if not isCop then return false end

    local state = Player(targetSource).state
    if state and state.jailTime > 0 then
        setJailTime(targetSource, newTime)

        lib.notify(targetSource, {
            title = locale('notify.new_time_by_roster'),
            description = (locale('notify.new_time_by_roster_description')):format(newTime)
        })
    end

    return state and (state.jailTime == newTime) or false
end)