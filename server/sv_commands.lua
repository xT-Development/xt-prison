local config    = require 'configs.server'
local utils     = require 'modules.server.utils'

-- Check Jail Time --
lib.addCommand('jailtime', {
    help = 'Check your jail time',
    params = {},
    restricted = false
}, function(source, args, raw)
    utils.checkJailTime(source)
end)


-- Jail Player Command --
if config.EnableJailCommand then
    lib.addCommand('jail', {
        help = 'Jail Player',
        params = {},
        restricted = false
    }, function(source, args, _)
        local player = getPlayer(source)
        if not player then return end

        if utils.isCop(source) then
            local jailInput = lib.callback.await('xt-prison:client:jailPlayerInput', source)
            if not jailInput then return end

            local targetSource = tonumber(jailInput[1])
            local setTime = tonumber(jailInput[2])

            local dist = utils.playerDistanceCheck(source, targetSource)
            if not dist then return end

            local targetPlayer = getPlayer(targetSource)
            if not targetPlayer then return end

            local notifyTitle = ('Sent %s to Jail for %s Months'):format(getCharName(targetSource), setTime)
            local state = Player(targetSource).state
            if state and state?.jailTime > 0 then
                if setTime < 0 then
                    setTime = 0
                end

                setJailTime(targetSource, setTime)

                lib.notify(targetSource, {
                    title = 'Jail Time Updated',
                    description = ('Your jail time was set to %s months'):format(setTime),
                    icon = 'fas fa-lock',
                    type = 'success',
                    duration = 5000
                })
                notifyTitle = ('Updated %s\'s Jail Time to %s Months'):format(getCharName(targetSource), setTime)
            else
                lib.callback.await('xt-prison:client:enterJail', targetSource, setTime)
            end

            lib.notify(source, {
                title = notifyTitle,
                icon = 'fas fa-lock',
                type = 'success',
                duration = 5000
            })
        else
            lib.notify(source, {
                title = 'You don\'t have access to this command!',
                type = 'info'
            })
        end
    end)
end