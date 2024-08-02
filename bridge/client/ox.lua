if GetResourceState('ox_core') ~= 'started' then return end

local file = ('imports/%s.lua'):format(IsDuplicityVersion() and 'server' or 'client')
local import = LoadResourceFile('ox_core', file)
local chunk = assert(load(import, ('@@ox_core/%s'):format(file)))
chunk()

--[[
    TO-DO:
    - Add compat events for jailing (if there is any)
]]

AddEventHandler('ox:playerLoaded', function()
    TriggerEvent('xt-prison:client:onLoad')
end)

AddEventHandler('ox:playerLogout', function()
    TriggerEvent('xt-prison:client:onUnload')
end)