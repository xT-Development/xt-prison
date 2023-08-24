local Utils = require('modules.shared')
local scully = GetResourceState('scully_emotemenu')
local rpemotes = GetResourceState('rpemotes')
local CopsNotified = false
local HackZone = {}
local inJail = false
local CurrentCops = 0

RegisterNetEvent('police:SetCopCount', function(amount) CurrentCops = amount end)

local xTc = {}

-- Play Emote --
function xTc.Emote(emote)
    if scully == 'started' or scully == 'starting' then
        exports.scully_emotemenu:playEmoteByCommand(emote)
    end
    if rpemotes == 'started' or rpemotes == 'starting' then
        TriggerEvent('animations:client:EmoteCommandStart', {emote})
    end
end

-- End Emote --
function xTc.EndEmote()
    if scully == 'started' or scully == 'starting' then
        exports.scully_emotemenu:cancelEmote()
    end
    if rpemotes == 'started' or rpemotes == 'starting' then
        TriggerEvent('animations:client:EmoteCommandStart', {'c'})
    end
end

-- Create Prison Zone for Prison Break Distance Checks --
function xTc.PrisonZone()
    PrisonZone = lib.points.new({
        coords = Config.PrisonBreak.center,
        distance =  Config.PrisonBreak.radius,
    })

    function PrisonZone:onExit()
        if inJail then
            inJail = false
            jailTime = 0
            local alarm = lib.callback.await('xt-prison:server:PrisonAlarms', false, true)
            QBCore.Functions.Notify('You escaped prison!', "error")
            TriggerServerEvent('xt-prison:server:Breakout')
            if Config.XTPrisonJobs then TriggerEvent('XTPrisonJobsCleanup') end
        end
    end
end

-- Entering Prison --
function xTc.EnterPrison(TIME)
    local setJailTime = lib.callback.await('xt-prison:server:SetJailStatus', false, TIME)
    if setJailTime then
        local removeItems = lib.callback.await('xt-prison:server:RemoveItems', false)
        local isLifer = lib.callback.await('xt-prison:server:LiferCheck', false)
        if Config.RemoveJob then local removeJob = lib.callback.await('xt-prison:server:RemoveJob', false) end

        DoScreenFadeOut(1000)
        while not IsScreenFadedOut() do Wait(25) end

        local RandomSpawn = Config.Spawns[math.random(1, #Config.Spawns)]
        SetEntityCoords(cache.ped, RandomSpawn.coords.x, RandomSpawn.coords.y, RandomSpawn.coords.z - 0.9, 0, 0, 0, false)
        SetEntityHeading(cache.ped, RandomSpawn.coords.w)

        -- Maybe this helps players with dookie butt water computers? idk. too lazy to look into it --
        Wait(500)
        if GetEntityCoords(cache.ped) ~= vec3(RandomSpawn.coords.x, RandomSpawn.coords.y, RandomSpawn.coords.z - 0.9) then
            SetEntityCoords(cache.ped, RandomSpawn.coords.x, RandomSpawn.coords.y, RandomSpawn.coords.z - 0.9, 0, 0, 0, false)
            SetEntityHeading(cache.ped, RandomSpawn.coords.w)
        end

        xTc.Emote(RandomSpawn.emote)

        inJail = true
        jailTime = TIME

        TriggerServerEvent("InteractSound_SV:PlayOnSource", "jail", 0.5)
        if Config.XTPrisonJobs then TriggerEvent('XTEnterPrison') end
        Wait(3000)
        DoScreenFadeIn(1000)

        if not isLifer then xTc.TimeReductionLoop() end

        if Config.EnterPrisonAlert.enable and not isLifer then
            local alertInfo = Config.EnterPrisonAlert
            local alert = lib.alertDialog({
                header = alertInfo.header,
                content = 'Prison Sentence: '..jailTime..'  \n'..alertInfo.content,
                centered = true,
                labels = { confirm = 'Close' }
            })
        elseif Config.EnterPrisonAlert.enable and isLifer then
            QBCore.Functions.Notify('You\'re a lifer!', 'error')
        end
    end
end

-- Exiting Prison --
function xTc.ExitPrison()
    local getJailTime = lib.callback.await('xt-prison:server:GetJailTime', false)
    if getJailTime > 0 then
		QBCore.Functions.Notify('You still have '..getJailTime..' months left!', 'error')
	else
        local setJailTime = lib.callback.await('xt-prison:server:SetJailStatus', false, 0)
        if setJailTime then
            jailTime = 0
            inJail = false

            if Config.XTPrisonJobs then TriggerEvent('XTPrisonJobsCleanup') end

            DoScreenFadeOut(500)
            while not IsScreenFadedOut() do Wait(25) end

            TriggerServerEvent('qb-clothes:loadPlayerSkin')
            SetEntityCoords(cache.ped, Config.Freedom.x, Config.Freedom.y, Config.Freedom.z, 0, 0, 0, false)
            SetEntityHeading(cache.ped, Config.Freedom.w)

            Wait(500)
            DoScreenFadeIn(1000)
            local returnItems = lib.callback.await('xt-prison:server:ReturnItems', false)
        end
	end
end

-- Create Prisonbreak Hacking Zones --
function xTc.HackZones()
    for x = 1, #Config.PrisonBreak.hackZones do
        local zoneInfo = Config.PrisonBreak.hackZones[x]
        HackZone[x] = exports.ox_target:addSphereZone({
            coords = zoneInfo.coords,
            radius = zoneInfo.radius,
            debug = Config.DebugPoly,
            drawsprite = true,
            options = {
                {
                    label = 'Hack Prison Gate',
                    icon = 'fas fa-laptop-code',
                    items = Config.PrisonBreak.requiredItems,
                    onSelect = function() xTc.StartGateHack(x) end,
                    canInteract = function()
                        local canHack = lib.callback.await('xt-prison:server:CanHackTerminal', false, x)
                        if CurrentCops >= Config.PrisonBreak.minimumPolice and canHack then return true else return false end
                    end
                }
            }
        })
    end
end

-- Remove Prisonbreak Hacking Zones --
function xTc.RemoveHackZones()
    for x = 1, #HackZone do exports.ox_target:removeZone(HackZone[x]) end
end

-- Start Hacking Terminal --
function xTc.StartGateHack(ID)
    xTc.Emote('tablet2')
    TriggerServerEvent('xt-prison:server:TerminalBusyState', ID, true)
    TriggerEvent('ultra-voltlab', Config.PrisonBreak.hackLength, function(result, reason)
        if result == 0 then
            QBCore.Functions.Notify('You failed the hack!', 'error')
        elseif result == 1 then
            QBCore.Functions.Notify('You completed the hack!', 'success')
            TriggerServerEvent('xt-prison:server:TerminalHackedState', ID, true)
        elseif result == 2 then
            QBCore.Functions.Notify('You failed to complete the hack in time!', 'error')
        elseif result == -1 then
            QBCore.Functions.Notify('Error!', 'error')
        end
        local triggerAlarm = lib.callback.await('xt-prison:server:PrisonAlarms', false, true)
        TriggerServerEvent('xt-prison:server:TerminalBusyState', ID, false)
        xTc.EndEmote()
    end)
end

-- Notify Police --
function xTc.PoliceNotify()
    if Config.Dispatch == 'ps' then
        exports['ps-dispatch']:PrisonBreak()
    elseif Config.Dispatch == 'default' then
        TriggerEvent('police:client:policeAlert', Config.PrisonBreak.center, 'Prison Break')
    end
    CopsNotified = true
end

-- Prison Alarm Toggle --
function xTc.PrisonAlarm(BOOL)
    if BOOL then
        local alarmIpl = GetInteriorAtCoordsWithType(1787.004,2593.1984,45.7978, "int_prison_main")
        if not CopsNotified then xTc.PoliceNotify() end

        RefreshInterior(alarmIpl)
        EnableInteriorProp(alarmIpl, "prison_alarm")

        CreateThread(function()
            while not PrepareAlarm("PRISON_ALARMS") do Wait(100) end
            StartAlarm("PRISON_ALARMS", true)
        end)

        if not DoesBlipExist(PrisonBreakBlip) then PrisonBreakBlip = xTc.PrisonBreakBlip() end
    else
        local alarmIpl = GetInteriorAtCoordsWithType(1787.004,2593.1984,45.7978, "int_prison_main")

        RefreshInterior(alarmIpl)
        DisableInteriorProp(alarmIpl, "prison_alarm")

        CreateThread(function()
            while not PrepareAlarm("PRISON_ALARMS") do Wait(100) end
            StopAllAlarms(true)
        end)

        if DoesBlipExist(PrisonBreakBlip) then RemoveBlip(PrisonBreakBlip) end
        CopsNotified = false
    end
end

-- Create Prison Break Blip --
function xTc.PrisonBreakBlip()
    local PulsingBlip = AddBlipForCoord(Config.PrisonBreak.center.x, Config.PrisonBreak.center.y, Config.PrisonBreak.center.z)
    SetBlipSprite(PulsingBlip , 161)
    SetBlipScale(PulsingBlip , 3.0)
    SetBlipColour(PulsingBlip, 3)
    PulseBlip(PulsingBlip)
    return PulsingBlip
end

function xTc.TimeReductionLoop()
    jailTime = lib.callback.await('xt-prison:server:GetJailTime', false)
    Utils.Debug('Time Left:', jailTime)
    if jailTime > 0 and inJail then
        SetTimeout(60000, function()
            local setTime = lib.callback.await('xt-prison:server:SetJailStatus', false, (jailTime - 1))
            if setTime then Utils.Debug('Time Reduced', jailTime) xTc.TimeReductionLoop() else return end
        end)
    elseif jailTime <= 0 and inJail then
        QBCore.Functions.Notify('Your time is up! Go checkout with the guard in the cells!', "success", 10000)
    end
end

return xTc