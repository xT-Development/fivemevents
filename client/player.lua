local function GetPlayerByEntityID(entityId)
    local players = GetActivePlayers()

    for i = 1, #players do
        if GetPlayerPed(players[i]) == entityId then
            return players[i]
        end
    end

    return nil
end

CreateThread(function()
    local isDead = false
    local hasBeenDead = false
    local diedAt
    local lastPed = 0
    local player = cache.playerId

    -- Cache frequently used values
    local waitTime = 100
    local playerCheckInterval = 1000
    local lastPlayerCheck = 0

    while true do
        Wait(waitTime)

        local currentTime = GetGameTimer()

        -- Only check if player is active every second
        if currentTime - lastPlayerCheck > playerCheckInterval then
            if not NetworkIsPlayerActive(player) then
                lastPlayerCheck = currentTime
                goto continue
            end
            lastPlayerCheck = currentTime
        end

        local ped = cache.ped

        -- Only process if ped changed or we need to check death status
        if ped ~= lastPed or isDead or not hasBeenDead then
            lastPed = ped

            local isPedDead = IsPedFatallyInjured(ped)

            if isPedDead and not isDead then
                isDead = true

                if not diedAt then
                    diedAt = currentTime
                end

                local killer, killerweapon = NetworkGetEntityKillerOfPlayer(player)
                local killerentitytype = GetEntityType(killer)
                local killertype = -1
                local killerinvehicle = false
                local killervehiclename = ''
                local killervehicleseat = 0

                if killerentitytype == 1 then
                    killertype = GetPedType(killer)
                    if IsPedInAnyVehicle(killer, false) then
                        killerinvehicle = true

                        local killerVehicle = GetVehiclePedIsUsing(killer)
                        killervehiclename = GetDisplayNameFromVehicleModel(GetEntityModel(killerVehicle))
                        killervehicleseat = GetPedVehicleSeat(killer)
                    end
                end

                local killerid = GetPlayerByEntityID(killer)
                if killer ~= ped and killerid and NetworkIsPlayerActive(killerid) then
                    killerid = GetPlayerServerId(killerid)
                else
                    killerid = -1
                end

                local playerCoords = GetEntityCoords(ped)

                if killer == ped or killer == -1 then
                    TriggerEvent('baseevents:onPlayerDied', killertype, {playerCoords.x, playerCoords.y, playerCoords.z})
                    TriggerServerEvent('baseevents:onPlayerDied', killertype, {playerCoords.x, playerCoords.y, playerCoords.z})
                    hasBeenDead = true
                else
                    local killerData = {
                        killertype = killertype,
                        weaponhash = killerweapon,
                        killerinveh = killerinvehicle,
                        killervehseat = killervehicleseat,
                        killervehname = killervehiclename,
                        killerpos = {playerCoords.x, playerCoords.y, playerCoords.z}
                    }
                    TriggerEvent('baseevents:onPlayerKilled', killerid, killerData)
                    TriggerServerEvent('baseevents:onPlayerKilled', killerid, killerData)
                    hasBeenDead = true
                end

            elseif not isPedDead and isDead then
                isDead = false
                diedAt = nil
            end

            -- Check if the player has to respawn in order to trigger an event
            if not hasBeenDead and diedAt and diedAt > 0 then
                local playerCoords = GetEntityCoords(ped)
                TriggerEvent('baseevents:onPlayerWasted', {playerCoords.x, playerCoords.y, playerCoords.z})
                TriggerServerEvent('baseevents:onPlayerWasted', {playerCoords.x, playerCoords.y, playerCoords.z})
                hasBeenDead = true
            elseif hasBeenDead and diedAt and diedAt <= 0 then
                hasBeenDead = false
            end
        end

        ::continue::
    end
end)

--[[

    Events:
    - baseevents:onPlayerDied
    - baseevents:onPlayerKilled
    - baseevents:onPlayerWasted

]]