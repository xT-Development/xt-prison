local db                = require 'modules.server.db'
local config            = require 'configs.server'
local prisonBreakcfg    = require 'configs.prisonbreak'
local utils             = require 'modules.server.utils'
local ox_inventory      = exports.ox_inventory
local globalState       = GlobalState

local function savePlayerJailTime(src)
    local state = Player(src).state
    local jailTime = state and state.jailTime or 0
    local cid = getCharID(src) or state and state.xtprison_identifier
    if not cid then return lib.print.debug('player core identifier not found, not saving jailtime') end
    MySQL.insert.await(db.UPDATE_JAILTIME, { cid, jailTime })
end

local function loadPlayerJailTime(src)
    local CID = getCharID(src)
    local getJailTime = MySQL.scalar.await(db.LOAD_JAILTIME, { CID })
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
    if charHasJob(source, config.UnemployedJobName) then
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
    if ox_inventory:ConfiscateInventory(src) then
        lib.notify(src, {
            title = locale('notify.confiscated'),
            icon = 'fas fa-trash',
            type = 'error'
        })
    end
end)

-- Return Items on Exit --
RegisterNetEvent('xt-prison:server:returnItems', function()
    local src = source
    if Player(src).state.jailTime > 0 then
        -- TODO: Add exploit ban
        return
    end
    local CID = getCharID(src)
    local getInv = MySQL.query.await(db.GET_INVENTORY, { CID, CID })

    if getInv and getInv[1] then
        if ox_inventory:ReturnInventory(src) then
            lib.notify(src, {
                title = locale('notify.returned_items'),
                icon = 'fas fa-hand-holding-heart',
                type = 'success'
            })
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
            if charHasJob(tonumber(src), config.policeJobs) then
                count += 1
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