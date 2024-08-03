local config    = require 'configs.client'
local utils     = require 'modules.client.utils'

local prisonDoc
local prisonDocBlip

local function initPrisonDoctor()
    if DoesEntityExist(prisonDoc) then return end

    local docInfo = config.PrisonDoctor
    prisonDoc = utils.createPed(docInfo.model, docInfo.coords, docInfo.scenario)
    prisonDocBlip = utils.createBlip('Prison Infirmary', docInfo.coords, 61, 0.3, 1)

    exports.ox_target:addLocalEntity(prisonDoc, {
        {
            label = 'Receive Check-Up',
            icon = 'fas fa-stethoscope',
            onSelect = function()
                if lib.progressCircle({
                    label = 'Receiving Checkup...',
                    duration = (docInfo.healLength * 1000),
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
                    lib.notify({ title = 'Healed', description = 'You received a checkup from the doctor!', type = 'success' })
                    config.PlayerHealed()
                end
            end
        }
    })
end

local function removePrisonDoctor()
    if not DoesEntityExist(prisonDoc) and not DoesBlipExist(prisonDocBlip) then
        return
    end

    exports.ox_target:removeLocalEntity(prisonDoc, 'Receive Check-Up')
    DeletePed(prisonDoc)
    RemoveBlip(prisonDocBlip)
end

AddEventHandler('onResourceStart', function(resource)
   if resource ~= GetCurrentResourceName() then return end
   initPrisonDoctor()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    removePrisonDoctor()
end)

AddEventHandler('xt-prison:client:onLoad', function()
    initPrisonDoctor()
end)

AddEventHandler('xt-prison:client:onUnload', function()
    removePrisonDoctor()
end)
