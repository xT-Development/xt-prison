local config    = require 'configs.server'
local utils     = require 'modules.server.utils'

-- Check Jail Time --
lib.addCommand('jailtime', {
    help = locale('commands.check_time'),
    params = {},
    restricted = false
}, function(source, args, raw)
    utils.checkJailTime(source)
end)

-- Jail Roster --
lib.addCommand('prisoners', {
    help = locale('commands.prisoners_roster'),
    params = {},
    restricted = false
}, function(source, args, raw)
    if not utils.isCop(source) then
        lib.notify(source, {
            title = locale('notify.no_access'),
            type = 'info'
        })
        return
    end

    local jailRoster = utils.generateJailRoster()

    TriggerClientEvent('xt-prison:client:openPrivateJailRoster', source, jailRoster)
end)


-- Jail/Unjail Player Commands --
if config.EnableJailCommand then
    lib.addCommand('jail', {
        help = locale('commands.jail'),
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

            local targetPlayer = getPlayer(targetSource)
            if not targetPlayer then
                return lib.notify(source, {
                    title = locale('notify.invalid_player'),
                    type = 'error'
                })
            end

            local dist = utils.playerDistanceCheck(source, targetSource)
            if not dist then return end

            local notifyTitle = (locale('notify.player_sent')):format(getCharName(targetSource), setTime)
            local state = Player(targetSource).state
            if state?.jailTime and state?.jailTime > 0 then
                if setTime < 0 then
                    setTime = 0
                end

                setJailTime(targetSource, setTime)

                lib.notify(targetSource, {
                    title = locale('notify.time_updated'),
                    description = (locale('notify.time_updated_description')):format(setTime),
                    icon = 'fas fa-lock',
                    type = 'success',
                    duration = 5000
                })
                notifyTitle = (locale('notify.updated_players_times')):format(getCharName(targetSource), setTime)
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
                title = locale('notify.no_access'),
                type = 'info'
            })
        end
    end)

    lib.addCommand('unjail', {
        help = locale('commands.unjail'),
        params = {{
            name = 'id',
            type = 'playerId',
            help = locale('commands.playerid')
        }}
    }, function(source, args)
        if not utils.isCop(source) then return end

        local targetPlayer = getPlayer(args.id)
        if not targetPlayer then
            return lib.notify(source, {
                title = locale('notify.invalid_player'),
                type = 'error'
            })
        end

        local state = Player(args.id).state
        if state and state.jailTime <= 0 then
            return
        end

        local released = lib.callback.await('xt-prison:client:exitJail', args.id, true)
        if released then
            lib.notify(source, {
                title = (locale('notify.player_released')):format(getCharName(args.id)),
                icon = 'fas fa-lock',
                type = 'success',
                duration = 5000
            })
        end
    end)
end