local config    = require 'configs.client'
local utils     = require 'modules.client.utils'
local resources = require 'bridge.compat.resources'

local canteenPed
local canteenBlip

local function onSelectCanteen()
    local canteenInfo = config.CanteenPed
    if lib.progressCircle({
        label = 'Receiving Canteen Meal...',
        duration = (canteenInfo.mealLength * 1000),
        position = 'bottom',
        useWhileDead = true,
        canCancel = false,
        disable = {
            move = true,
            car = true,
            combat = true,
            sprint = true,
        },
    }) then
        local receiveMeal = lib.callback.await('xt-prison:server:receiveCanteenMeal', false)
        if receiveMeal then
            lib.notify({ title = 'Received Meal', description = 'You received a meal from the canteen!', type = 'success' })
        end
    end
end

local function initCanteen()
    if DoesEntityExist(canteenPed) then return end

    local canteenInfo = config.CanteenPed
    canteenPed = utils.createPed(canteenInfo.model, canteenInfo.coords, canteenInfo.scenario)
    canteenBlip = utils.createBlip('Prison Canteen', canteenInfo.coords, 273, 0.3, 2)

    if resources.qb_target then
        exports['qb-target']:AddTargetEntity(canteenPed, {
            options = {
                {
                    label = 'Receive Meal',
                    icon = 'fas fa-utensils',
                    action = onSelectCanteen,
                },
            },
            distance = 2.5,
        })
    else
        exports.ox_target:addLocalEntity(canteenPed, {
            {
                label = 'Receive Meal',
                icon = 'fas fa-utensils',
                onSelect = onSelectCanteen
            }
        })
    end
end

local function removeCanteen()
    if not DoesEntityExist(canteenPed) and not DoesBlipExist(canteenBlip) then
        return
    end

    if resources.qb_target then
        exports['qb-target']:RemoveTargetEntity(canteenPed)
    else
        exports.ox_target:removeLocalEntity(canteenPed, 'Receive Meal')
    end

    DeletePed(canteenPed)
    RemoveBlip(canteenBlip)
end

AddEventHandler('onResourceStart', function(resource)
   if resource ~= GetCurrentResourceName() then return end
   initCanteen()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    removeCanteen()
end)

AddEventHandler('xt-prison:client:onLoad', function()
    initCanteen()
end)

AddEventHandler('xt-prison:client:onUnload', function()
    removeCanteen()
end)
