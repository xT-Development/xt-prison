local config = lib.load('configs.client')
local rosterZone

-- Unjail Player --
local function unjailConfirmation(info)
    local confirmation = lib.alertDialog({
        header = ('Unjail %s?'):format(info.name),
        content = ('Are you sure you want to unjail **%s**?  \nThey still have **%s Months** left.'):format(info.name, info.jailTime),
        centered = true,
        cancel = true,
    }) if confirmation == 'cancel' then return end

    local unjailed = lib.callback.await('xt-prison:server:unjailPlayerByRoster', false, info.source)
    if unjailed then
        lib.notify({
            title = ('%s was released!'):format(info.name),
            type = 'success'
        })
    end
end

-- Change Player's Jail Time --
local function changeJailTime(info)
    local newTime = lib.inputDialog(('Change Jail Time: %s'):format(info.name), {
        { type = 'number', label = 'New Jail Time', description = ('Time Left: %s Months'):format(info.jailTime), icon = 'hashtag' },
    }) if not newTime then return end

    local setTime = lib.callback.await('xt-prison:server:changePlayerJailTimeByRoster', false, info.source, newTime[1])
    if setTime then
        lib.notify({
            title = ('Changed %s\'s Jail Time!'):format(info.name),
            description = ('New Time: %s'):format(newTime[1]),
            type = 'success'
        })
    end
end

local function rosterActionMenu(info)
    local actions = {
        {
            title = 'Change Jail Time',
            icon = 'fas fa-hourglass',
            onSelect = function()
                changeJailTime(info)
            end
        },
        {
            title = 'Unjail',
            icon = 'fas fa-lock-open',
            onSelect = function()
                unjailConfirmation(info)
            end
        }
    }

    lib.registerContext({
        id = 'prisoners_roster_actions',
        title = info.name,
        menu = 'prisoners_roster',
        options = actions
    })
    lib.showContext('prisoners_roster_actions')
end

local function openPublicRoster()
    local jailRoster = lib.callback.await('xt-prison:server:getJailRoster', false)
    if not jailRoster then return end

    if not jailRoster[1] then
        jailRoster = {
            {
                title = 'No Prisoners!',
                readOnly = true
            }
        }
    else
        for x = 1, #jailRoster do
            jailRoster[x].readOnly = true
        end
    end

    lib.registerContext({
        id = 'prisoners_public_roster',
        title = 'Jail Roster',
        options = jailRoster
    })
    lib.showContext('prisoners_public_roster')
end

local function createRosterZone()
    local zoneInfo = config.RosterLocation
    rosterZone = exports.ox_target:addSphereZone({
        coords = zoneInfo.coords,
        radius = zoneInfo.radius,
        debug = zoneInfo.DebugPoly,
        drawSprite = true,
        options = {
            {
                label = 'View Prisoners Roster',
                icon = 'fas fa-clipboard-list',
                onSelect = openPublicRoster
            }
        }
    })
end

local function removeRosterZone()
    exports.ox_target:removeZone(rosterZone)
end

-- Open Prisoners Manageable Roster as Cop --
RegisterNetEvent('xt-prison:client:openPrivateJailRoster', function(jailRoster)
    if GetInvokingResource() then return end

    if not jailRoster[1] then
        jailRoster = {
            {
                title = 'No Prisoners!',
                readOnly = true
            }
        }
    else
        for x = 1, #jailRoster do
            jailRoster[x].onSelect = function()
                rosterActionMenu(jailRoster[x].private)
            end
        end
    end

    lib.registerContext({
        id = 'prisoners_roster',
        title = 'Jail Roster',
        options = jailRoster
    })
    lib.showContext('prisoners_roster')
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    createRosterZone()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    removeRosterZone()
end)

AddEventHandler('xt-prison:client:onLoad', function()
    createRosterZone()
end)

AddEventHandler('xt-prison:client:onUnload', function()
    removeRosterZone()
end)