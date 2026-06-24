local db                = require 'modules.server.db'
local config            = require 'configs.server'
local prisonBreakcfg    = require 'configs.prisonbreak'
local utils             = require 'modules.server.utils'
local ox_inventory      = exports.ox_inventory
local globalState       = GlobalState
local confiscated       = {}

local function savePlayerJailTime(src)
    local state = Player(src).state
    local jailTime = state and state.jailTime or 0
    local cid = getCharID(src) or state and state.xtprison_identifier
    if not cid then return lib.print.debug('player core identifier not found, not saving jailtime') end
    MySQL.insert.await(db.UPDATE_JAILTIME, { cid, jailTime })

    if confiscated[cid] then
        ox_inventory:ReturnInventory(src)
        confiscated[cid] = nil
    end
end

local function loadPlayerJailTime(src)
    local cid = getCharID(src)
    local getJailTime = MySQL.scalar.await(db.LOAD_JAILTIME, { cid })
    local setTime = setJailTime(src, getJailTime or 0)
    return setTime and getJailTime or 0
end

-- Get Jail Time --
lib.callback.register('xt-prison:server:initJailTime', function(source)
    return loadPlayerJailTime(source)
end)

-- Save Jail Time --
RegisterNetEvent('xt-prison:server:saveJailTime', function()
    local src = source
    savePlayerJailTime(src)
end)

-- Remove Player Job --
lib.callback.register('xt-prison:server:removeJob', function(source)
    if not charHasJob(source, config.UnemployedJobName) then
        if setCharJob(source, config.UnemployedJobName) then
            lib.notify(source, {
                title = locale('notify.lost_job'),
                icon = 'fas fa-ban',
                type = 'error'
            })
            return true
        end
    else
        return true
    end

    return false
end)

-- Remove Items on Entry --
RegisterNetEvent('xt-prison:server:removeItems', function()
    local src = source
    local cid = getCharID(src)
    if not cid then return end
    if confiscated[cid] then return end

    local playerItems = ox_inventory:GetInventoryItems(src)
    if not playerItems or not next(playerItems) then
        confiscated[cid] = true
        return
    end

    local existing = MySQL.scalar.await(db.GET_ITEMS, { cid })
    existing = existing and json.decode(existing) or {}

    if existing and next(existing) then
        confiscated[cid] = true
        return
    end

    local success = MySQL.insert.await(db.CONFISCATE_ITEMS, { cid, json.encode(playerItems) })
    if not success then return end

    ox_inventory:ClearInventory(src)
    confiscated[cid] = true

    lib.notify(src, {
        title = locale('notify.confiscated'),
        icon = 'fas fa-trash',
        type = 'error'
    })
end)

-- Return Items on Exit --
RegisterNetEvent('xt-prison:server:returnItems', function()
    local src = source
    local cid = getCharID(src)
    if not cid then return end

    if Player(src).state.jailTime > 0 then
        utils.banPlayer(src, cid)
        return
    end

    if not confiscated[cid] then return end

    local prisonInventory = ox_inventory:GetInventoryItems(src) -- items picked up while jailed
    local rawConfiscated = MySQL.scalar.await(db.GET_ITEMS, { cid })
    local confiscatedItems = rawConfiscated and json.decode(rawConfiscated) or {}

    ox_inventory:ClearInventory(src) -- wipe prison inventory; re-add allowed items

    local failedItems = {}

    if confiscatedItems and next(confiscatedItems) then
        for _, info in pairs(confiscatedItems) do
            local success, response = ox_inventory:AddItem(src, info.name, info.count, info.metadata)
            if not success then
                failedItems[#failedItems + 1] = info
            end
        end
    end

    if #failedItems > 0 then
        MySQL.query.await(db.UPDATE_CONFISCATED_ITEMS, { json.encode(failedItems), cid })

        lib.notify(src, {
            title = locale('notify.return_partial_failure'),
            icon = 'fas fa-triangle-exclamation',
            type = 'error'
        })
    else
        MySQL.query.await(db.CLEAR_CONFISCATED_ITEMS, { cid })

        lib.notify(src, {
            title = locale('notify.returned_items'),
            icon = 'fas fa-hand-holding-heart',
            type = 'success'
        })
    end

    confiscated[cid] = nil

    for _, info in pairs(prisonInventory) do -- Return allowed prison items
        if config.AllowedToKeepItems[info.name] then
            ox_inventory:AddItem(src, info.name, info.count, info.metadata)
        end
    end
end)

-- Set Jail Time --
lib.callback.register('xt-prison:server:setJailStatus', function(source, setTime)
    local src = source
    local playerState = Player(src)?.state
    if not playerState then return end

    local jailTime = playerState.jailTime
    if jailTime == setTime then
        return true
    end

    setJailTime(src, ((setTime < 0) and 0 or setTime))

    return true
end)

-- Check if Player is a Lifer --
lib.callback.register('xt-prison:server:liferCheck', function(source)
    return utils.liferCheck(source)
end)

-- Receive Canteen Meal --
lib.callback.register('xt-prison:server:receiveCanteenMeal', function(source)
    local food = config.CanteenMeal.food
    local drink = config.CanteenMeal.drink
    if ox_inventory:AddItem(source, food.item, food.count) and ox_inventory:AddItem(source, drink.item, drink.count) then
        return true
    end
    return false
end)

-- Checks Time Left --
local lastTimeCheck = {}

local function initTimeCheck(source)
    lastTimeCheck[source] = lib.timer(5000, function()
        lastTimeCheck[source] = nil
    end, true)
end

lib.callback.register('xt-prison:server:checkJailTime', function(source)
    if lastTimeCheck[source] then
        lib.notify(source, {
            title = locale('notify.wait_before_check'),
            icon = 'fas fa-hourglass-half',
            type = 'error'
        })
        return
    end

    initTimeCheck(source) -- init timer

    return utils.checkJailTime(source)
end)

-- Constantly Update Cop Count --
AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    if prisonBreakcfg.MinimumPolice == 0 then
        globalState.copCount = 0
        return
    end

    SetInterval(function()
        local players = GetPlayers()
        local count = 0

        for _, src in pairs(players) do
            src = src and tonumber(src) or false
            local player = src and getPlayer(src) or false
            if player then
                if charHasJob(src, config.policeJobs) then
                    count += 1
                end
            end
        end

        if globalState.copCount ~= count then
            globalState.copCount = count
        end
    end, 120000)
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    savePlayerJailTime(src)
end)
