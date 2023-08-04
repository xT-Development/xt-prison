local xTs = require('modules.server')

-- Check Jail Time --
lib.addCommand('jailtime', {
    help = 'Check your jail time',
    params = {},
    restricted = false
}, function(source, args, raw)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local jailTime = Player.PlayerData.metadata['injail']
    if jailTime > 0 then
        QBCore.Functions.Notify(src, 'You have '..jailTime..' months left.', 'info')
    elseif jailTime <= 0 then
        QBCore.Functions.Notify(src, 'You don\'t have any jail time left!', 'info')
    end
end)


-- Jail Player Command --
if Config.EnableJailCommand then
    lib.addCommand('jail', {
        help = 'Jail Player',
        params = {},
        restricted = false
    }, function(source, args, _)
        local src = source
        local Player = QBCore.Functions.GetPlayer(src)
        if xTs.isCop(src) then
            TriggerClientEvent('qb-policejob:client:JailPlayerInput', source)
        else
            QBCore.Functions.Notify(src, 'You don\'t have access to this command!', 'info')
        end
    end)
end