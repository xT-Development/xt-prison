return {
    Center = vec3(1699.86, 2605.15, 45.56),         -- Center check for prison break
    Radius = 200,                                   -- Radius of prison break

    RequiredItems = {                               -- Required items for prison break hack
        ['trojan_usb'] = 1
    },

    HackLength = 5,                                 -- Seconds
    AlarmLength = 2,                                -- Minutes
    TerminalCooldowns = 10,                         -- Cooldown on hacking terminals once they are hacked

    MinimumPolice = 0,                              -- Minimum required police to start prison break

    AlarmChanceOnHack = {                           -- Chance alarm activates when player attempts to hack terminal
        fail = 10,
        success = 100
    },

    RemoveItemsChanceOnHack = {                     -- Chance items are removed from player when player attempts to hack terminal
        fail = 100,
        success = 50
    },

    HackZones = {                                   -- Gate = Name of door in ox_doorlock database
        { coords = vec3(1846.05, 2604.7, 45.65), gate = 'prison 1', radius = 0.4 },
        { coords = vec3(1819.55, 2604.7, 45.6),  gate = 'prison 2', radius = 0.4 },
        { coords = vec3(1817.4, 2602.7, 45.65),  gate = 'prison 2', radius = 0.4 },
        { coords = vec3(1843.95, 2602.7, 45.65), gate = 'prison 2', radius = 0.4 },
        -- { coords = vec3(1804.75, 2616.25, 45.6), gate = 'prison 3', radius = 0.4 }, -- These gates are perma locked?
        -- { coords = vec3(1804.75, 2617.65, 45.6), gate = 'prison 4', radius = 0.4 }
    },

    GateHackMinigame = function(gateID)             -- Use any minigame you want, return success or fail
        local difficulty = { 'easy', 'easy' }
        local keys = { 'w', 's' }
        return lib.skillCheck(difficulty, keys)
    end
}