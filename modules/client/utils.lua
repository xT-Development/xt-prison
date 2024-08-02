local utils = {}

function utils.createPed(model, coords, scenario)
    if not model or not coords or not scenario then lib.print.error('create ped error, missing info') return end

    model = type(model) == 'string' and GetHashKey(model) or model

    lib.requestModel(model)
    local pedId = CreatePed(0, model, coords.x, coords.y, coords.z - 1, coords.w, false, false)
    TaskStartScenarioInPlace(pedId, scenario, 0, true)
    FreezeEntityPosition(pedId, true)
    SetEntityInvincible(pedId, true)
    SetBlockingOfNonTemporaryEvents(pedId, true)
    SetModelAsNoLongerNeeded(model)

    return pedId
end

function utils.createBlip(text, coords, icon, scale, color, pulse)
    if not text or not coords then lib.print.error('create blip error, missing text or coords') return end

    local blipID = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blipID, icon or 1)
    SetBlipScale(blipID, scale or 0.5)
    SetBlipDisplay(blipID, 4)
    SetBlipColour(blipID, color or 1)
    SetBlipAsShortRange(blipID, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(text)
    EndTextCommandSetBlipName(blipID)
    SetBlipCategory(blipID, 102)

    if pulse then
        PulseBlip(blipID)
    end

    return blipID
end

return utils