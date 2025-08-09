local debugPrint = require 'config'.debugPrint

RegisterServerEvent('baseevents:onPlayerDied')
RegisterServerEvent('baseevents:onPlayerKilled')
RegisterServerEvent('baseevents:onPlayerWasted')
RegisterServerEvent('baseevents:enteringVehicle')
RegisterServerEvent('baseevents:enteringAborted')
RegisterServerEvent('baseevents:enteredVehicle')
RegisterServerEvent('baseevents:leftVehicle')

AddEventHandler('baseevents:onPlayerKilled', function(killedBy, data)
	local victim = source

	debugPrint('Player Killed', {
        victim = victim,
        attacker = killedBy,
        data = data
    })
end)

AddEventHandler('baseevents:onPlayerDied', function(killedBy, pos)
	local victim = source

	debugPrint('Player Died', {
        victim = victim,
        attackerType = killedBy,
        pos = pos
    })
end)