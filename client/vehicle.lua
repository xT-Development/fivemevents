local debugPrint = require 'config'.debugPrint

-- entering, exiting, and abort entering vehicle
lib.onCache('vehicle', function(newVeh)
    local vehicle = newVeh or cache.vehicle
    local seat = newVeh and GetSeatPedIsTryingToEnter(vehicle) or cache.seat
    local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
    local netId = VehToNet(vehicle)
    local debugString = 'Entering'

    if not cache.vehicle and newVeh then -- entering vehicle

        -- player is attempting to enter, but aborted due to death or non-existing vehicle
        if not DoesEntityExist(vehicle) or IsPlayerDead(cache.playerId) then
            debugString = 'Aborted Entering'
            TriggerServerEvent('baseevents:enteringAborted')

            goto continue
        end

        -- player entered vehicle
        TriggerServerEvent('baseevents:enteringVehicle', vehicle, seat, model, netId)
    elseif cache.vehicle and not newVeh then -- exiting vehicle
        debugString = 'Exiting'
        TriggerServerEvent('baseevents:leftVehicle', vehicle, seat, model, netId)
    end

    ::continue:: -- ensure debug print is executed

    debugPrint(('%s Vehicle'):format(debugString), {
        vehicle = vehicle,
        seat = seat,
        model = model,
        netId = netId
    })
end)

-- entered vehicle completion
lib.onCache('seat', function(newSeat)
    if cache.vehicle and newSeat ~= 0 then

        -- player is fully seated in the vehicle
        debugPrint('Entered Vehicle', {
            vehicle = cache.vehicle,
            seat = newSeat,
            model = GetDisplayNameFromVehicleModel(GetEntityModel(cache.vehicle)),
            netId = VehToNet(cache.vehicle)
        })

        TriggerServerEvent('baseevents:enteredVehicle', cache.vehicle, newSeat, GetDisplayNameFromVehicleModel(GetEntityModel(cache.vehicle)), VehToNet(cache.vehicle))
    end
end)

--[[

    Events:
    - baseevents:enteringVehicle    | veh, seat, modelName, netId
    - baseevents:enteredVehicle     | veh, seat, modelName, netId
    - baseevents:leftVehicle        | veh, seat, modelName, netId
    - baseevents:enteringAborted

]]