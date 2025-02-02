return {
    EnableJailCommand = true,                   -- Jail command using ox_lib input menu

    UnemployedJobName = 'unemployed',           -- Name of unemployed job (if remove job is enabled)

    CanteenMeal = {                             -- Food & Drink received from canteen
        food = {
            item = 'burger',
            count = 1
        },
        drink = {
            item = 'water',
            count = 1
        }
    },

    AllowedToKeepItems = {                      --  Items found/received in prison that can be kept when released
        ['money'] = true
    },

    PoliceJobs = {                              -- Police jobs
        'police',
        'lspd',
    },

    Lifers = {                                  -- Lifer identifiers
        'RANDOLIOCID',
        'QWADEBOTCID'
    },

    banPlayer = function(source, cid)
        -- Implement your own ban functions/logging here
        -- This function passes the player source and player core identifier
    end
}