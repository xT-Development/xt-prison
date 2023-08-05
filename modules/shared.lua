-- Resource Print on Startup --
AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        if Config.Debug then print('^2xT Debug ^7| xT Development | ^2dsc.gg/xtdev ^7| '..resource) end
    end
end)

local Utils = {}

-- Debug Print --
function Utils.Debug(type, debugTxt)
    if debugTxt == nil then debugTxt = '' end
    if Config.Debug then
        print("^2xT Debug ^7| "..type.." | ^2"..debugTxt)
    end
end

return Utils
