Config = {}

-- Debug Configs --
Config.Debug = true
Config.DebugPoly = true

-- Enable/Disable Using xt-prisonjobs --
Config.XTPrisonJobs = true

-- Police Config --
Config.PoliceJobs = { 'police' }
Config.Dispatch = 'ps' -- 'ps' or 'default'
Config.EnableJailCommand = true -- Jail command using ox_lib input menu

-- Remove Jobs Entering Prison --
Config.RemoveJob = true

-- Freedom Spawn --
Config.Freedom = vec4(1839.9522705078, 2581.2080078125, 46.014366149902, 2.941924571991)

-- Alert Entering Prison --
Config.EnterPrisonAlert  = {
    header = 'Welcome to Prison, Criminal Scum!',
    content = 'To reduce your time in prison, get a job from the guard in the cells. Get your ass to work and maybe you\'ll learn a thing or two.',
}

-- Random Spawns & Emotes --
Config.Spawns = {
    { coords = vec4(1770.7249755859, 2479.9802246094, 45.74076461792, 31.66007232666),   emote = 'pushup' },
    { coords = vec4(1761.0710449219, 2474.9235839844, 49.693054199219, 33.123195648193), emote = 'pushup' },
    { coords = vec4(1745.0281982422, 2479.2116699219, 45.740684509277, 323.06579589844), emote = 'weights' },
    { coords = vec4(1768.1342773438, 2481.6772460938, 45.740734100342, 33.281074523926), emote = 'lean' },
}

-- Prisonbreak Configuration --
Config.PrisonBreak = {
    center = vec3(1699.86, 2605.15, 45.56), -- Center check for prison break
    radius = 200, -- Radius of prison break
    requriedItems = { 'trojan_usb' }, -- Required items for prison break hack
    hackLength = 60, -- Seconds
    alarmLength = 10, -- Minutes
    terminalCooldowns = 10, -- Cooldown on hacking terminals once they are hacked
    minimumPolice = 0, -- Minimum required police to start prison break
    hackZones = {
        { coords = vec3(1846.05, 2604.7, 45.65), gate = 'prison 1', radius = 0.4, isHacked = false, isBusy = false },
        { coords = vec3(1819.55, 2604.7, 45.6),  gate = 'prison 2', radius = 0.4, isHacked = false, isBusy = false },
        { coords = vec3(1817.4, 2602.7, 45.65),  gate = 'prison 2', radius = 0.4, isHacked = false, isBusy = false },
        -- { coords = vec3(1804.75, 2616.25, 45.6), gate = 'prison 3', radius = 0.4, isHacked = false, isBusy = false }, -- These gates are perma locked?
        -- { coords = vec3(1804.75, 2617.65, 45.6), gate = 'prison 3', radius = 0.4, isHacked = false, isBusy = false }
    },
}

-------------------------------------------------

QBCore = exports['qb-core']:GetCoreObject()
sharedItems = exports.ox_inventory:Items()