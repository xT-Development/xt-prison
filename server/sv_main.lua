local db                = require 'modules.server.db'
local config            = require 'configs.server'
local prisonBreakcfg    = require 'configs.prisonbreak'
local utils             = require 'modules.server.utils'
local prisonModules     = require 'modules.server.prisonbreak'
local ox_inventory      = exports.ox_inventory
local globalState       = GlobalState

local function savePlayerJailTime(source)
    local CID = getCharID(source)
    local jailTime = Player(source).state?.jailTime
    local callback = MySQL.update.await(db.UPDATE_JAILTIME, { jailTime, CID })
    return callback
end

local function loadPlayerJailTime(source)
    local CID = getCharID(source)
    local getJailTime = MySQL.scalar.await(db.LOAD_JAILTIME, { CID })
    local setTime = setJailTime(source, getJailTime or 0)
    return setTime and getJailTime or 0
end

-- Get Jail Time --
lib.callback.register('xt-prison:server:initJailTime', function(source)
    return loadPlayerJailTime(source)
end)

-- Save Jail Time --
lib.callback.register('xt-prison:server:saveJailTime', function(source)
    return savePlayerJailTime(source)
end)

-- Remove Player Job --
lib.callback.register('xt-prison:server:removeJob', function(source)
    if charHasJob(source, config.UnemployedJobName) then
        if setCharJob(source, config.UnemployedJobName) then
            lib.notify(source, {
                title = 'You lost your job!',
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
lib.callback.register('xt-prison:server:removeItems', function(source)
    if ox_inventory:ConfiscateInventory(source) then
        lib.notify(source, {
            title = 'Your items were confiscated!',
            icon = 'fas fa-trash',
            type = 'error'
        })
        return true
    end

    return false
end)

-- Return Items on Exit --
lib.callback.register('xt-prison:server:returnItems', function(source)
    local CID = getCharID(source)
    local getInv = MySQL.query.await(db.GET_INVENTORY, { CID, CID })

    if getInv and getInv[1] then
        if ox_inventory:ReturnInventory(source) then
            lib.notify(source, {
                title = 'Your items were returned!',
                icon = 'fas fa-hand-holding-heart',
                type = 'success'
            })
            return true
        end
    end

    return false
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