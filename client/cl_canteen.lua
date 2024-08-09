local config    = require 'configs.client'
local utils     = require 'modules.client.utils'

local canteenPed
local canteenBlip


local function initCanteen()
    if DoesEntityExist(canteenPed) then return end

    local canteenInfo = config.CanteenPed
    canteenPed = utils.createPed(canteenInfo.model, canteenInfo.coords, canteenInfo.scenario)
    canteenBlip = utils.createBlip('Prison Canteen', canteenInfo.coords, 273, 0.3, 2)

    if config.useOxtarget then
        exports.ox_target:addLocalEntity(canteenPed, {
            {
                label = 'Receive Meal',
                icon = 'fas fa-utensils',
                onSelect = function()
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
            }
        })
    else
        exports['qb-target']:AddTargetEntity(canteenPed, {
            options = {
                {
                    label = 'Receive Meal',
                    icon = 'fas fa-utensils',
                    action = function(entity)
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
                    end,
                },
            },
            distance = 2.5,
        })
    end
end

local function removeCanteen()
    if not DoesEntityExist(canteenPed) and not DoesBlipExist(canteenBlip) then
        return
    end
    
    if config.useOxtarget then
        exports.ox_target:removeLocalEntity(canteenPed, 'Receive Meal')
    else
        exports['qb-target']:RemoveTargetEntity(canteenPed)
    end
    
    -- Delete the ped and remove the blip
    DeletePed(canteenPed)
    if DoesBlipExist(canteenBlip) then
        RemoveBlip(canteenBlip)
    end
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
