local db                = require 'modules.server.db'
local config            = require 'configs.server'
local prisonBreakcfg    = require 'configs.prisonbreak'
local utils             = require 'modules.server.utils'
local manager           = require 'modules.server.manager'
local ox_inventory      = exports.ox_inventory
local globalState       = GlobalState
local confiscated       = {}

local function loadPlayerJailTime(src)
    local cid = getCharID(src)
    local getJailTime = MySQL.scalar.await(db.LOAD_JAILTIME, { cid })
    local setTime = setJailTime(src, getJailTime or 0)
    return setTime and getJailTime or 0
end

local function setJailState(src, setTime)
    local playerState = Player(src)?.state
    if not playerState then return false end

    local jailTime = playerState.jailTime
    if jailTime == setTime then
        return true
    end

    local set = setJailTime(src, ((setTime < 0) and 0 or setTime))

    return set
end

local function removeItemsOnEntry(src)
    local cid = getCharID(src)
    local playerItems = ox_inventory:GetInventoryItems(src)
    local confiscatedItems = MySQL.scalar.await(db.GET_ITEMS, { cid })

    confiscatedItems = json.decode(confiscatedItems) or {}

    if next(playerItems) and not next(confiscatedItems) then -- Checks if player has items and confiscated table is empty
        MySQL.insert.await(db.CONFISCATE_ITEMS, { cid, json.encode(playerItems) })
        ox_inventory:ClearInventory(src)

        lib.notify(src, {
            title = locale('notify.confiscated'),
            icon = 'fas fa-trash',
            type = 'error'
        })
    end
end

local function returnItemsOnExit(src)
    local cid = getCharID(src)
    if Player(src).state.jailTime > 0 then
        utils.banPlayer(src, cid)
        return
    end

    local prisonInventory = ox_inventory:GetInventoryItems(src) -- Get Prison Inventory
    local confiscatedItems = MySQL.scalar.await(db.GET_ITEMS, { cid }) -- Get Confiscated Items
    confiscatedItems = json.decode(confiscatedItems) or {}

    ox_inventory:ClearInventory(src) -- Clear Prison Inventory

    Wait(100)

    if next(confiscatedItems) then -- Ensure table is not empty
        for slot, info in pairs(confiscatedItems) do
            ox_inventory:AddItem(src, info.name, info.count, info.metadata)
        end

        MySQL.query.await(db.CLEAR_CONFISCATED_ITEMS, { cid })
    end

    lib.notify(src, {
        title = locale('notify.returned_items'),
        icon = 'fas fa-hand-holding-heart',
        type = 'success'
    })

    for slot, info in pairs(prisonInventory) do -- Return some prison items
        if config.AllowedToKeepItems[info.name] then
            ox_inventory:AddItem(src, info.name, info.count, info.metadata)
        end
    end
end

local function removeJob(src)
    if charHasJob(src, config.UnemployedJobName) then return end

    if setCharJob(src, config.UnemployedJobName) then
        lib.notify(src, {
            title = locale('notify.lost_job'),
            icon = 'fas fa-ban',
            type = 'error'
        })
    end
end

-- Get Jail Time --
lib.callback.register('xt-prison:server:initJailTime', function(source)
    return loadPlayerJailTime(source)
end)

-- Player Enters Prison --
-- Handles server side entering. Removes job, items and adds to jailed players table
lib.callback.register('xt-prison:server:enterPrison', function(source, setTime)
    local set = setJailState(source, setTime)
    if not set then return false end

    manager.addToJailedPlayers(source, setTime) -- Add to jailed players table
    removeItemsOnEntry(source)

    if config.RemoveJob then
        removeJob(source)
    end

    local isLifer = utils.liferCheck(source) -- Check if player is a lifer, for proper notifications

    return true, isLifer
end)

-- Player Exits Prison --
-- Handles server side exiting. Return items and remove from jailed players table
lib.callback.register('xt-prison:server:exitPrison', function(source)
    local set = setJailState(source, 0) -- Ensure the state is set to 0
    if not set then return false end

    manager.removeFromJailedPlayers(source) -- Remove from jailed players table
    returnItemsOnExit(source)

    return true
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

-- ONLY Set Jail Time --
-- Currently unused but might be re-used in the future, not sure
lib.callback.register('xt-prison:server:setJailStatus', function(source, setTime)
    local setState = setJailState(source, setTime)
    return setState
end)

-- Check if Player is a Lifer --
lib.callback.register('xt-prison:server:liferCheck', function(source)
    return utils.liferCheck(source)
end)

-- Checks Time Left --
lib.callback.register('xt-prison:server:checkJailTime', function(source)
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