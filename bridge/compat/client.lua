local prisonModules = require 'modules.client.prison'

-- QB/QBX Prison Compat Events --
RegisterNetEvent('prison:client:Enter', function(setTime)
    lib.print.error(GetInvokingResource(), 'triggered depreceated event prison:client:Enter, use callback')
    prisonModules.enterPrison(setTime)
end)

RegisterNetEvent('prison:client:Leave', function()
    lib.print.error(GetInvokingResource(), 'triggered depreceated event prison:client:Leave, use callback')
    prisonModules.exitPrison(false)
end)

RegisterNetEvent('prison:client:UnjailPerson', function()
    lib.print.error(GetInvokingResource(), 'triggered depreceated event prison:client:UnjailPerson, use callback')
    prisonModules.exitPrison(true)
end)