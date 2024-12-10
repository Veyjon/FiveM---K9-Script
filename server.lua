print('K9 Script by Veyjon Loaded!')

RegisterServerEvent('k9:getPlayerName')
AddEventHandler('k9:getPlayerName', function(targetId)
    local playerName = GetPlayerName(targetId)
    if playerName then
        -- Trigger the client to start the search and notify others globally
        TriggerClientEvent('k9:startSearch', -1, playerName, targetId)

        -- Broadcast to all players that K9 is searching this player
        TriggerClientEvent('chat:addMessage', -1, {
            color = {255, 255, 0},
            multiline = true,
            args = {"K9 Unit", "The K9 is searching " .. playerName .. "!"}
        })
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"Error", "Player name not found."}
        })
    end
end)

RegisterNetEvent('k9:startSearch')
AddEventHandler('k9:startSearch', function(playerName, targetId)
    local targetPlayer = GetPlayerPed(GetPlayerFromServerId(targetId))
    local targetPos = GetEntityCoords(targetPlayer)

    -- Command K9 to approach and search the target player
    TaskGoToEntity(k91, targetPlayer, -1, 2.0, 1.0, 1073741824, 0)

    -- Optional: Add sniffing or searching animation
    Citizen.Wait(3000) -- Simulate the search duration
    TaskStartScenarioInPlace(k91, "WORLD_DOG_SNIFF_GROUND", 0, true)

    Citizen.SetTimeout(5000, function()
        ClearPedTasks(k91) -- Clear tasks after completion
    end)
end)

RegisterServerEvent('k9:startVehicleSearch')
AddEventHandler('k9:startVehicleSearch', function()
    local playerPed = GetPlayerPed(source) -- Get the player's ped ID
    local vehicle = GetVehiclePedIsIn(playerPed, false) -- Check if the player is in a vehicle

    -- If the player is not in a vehicle, find the closest one
    if vehicle == 0 then
        vehicle = GetClosestVehicle(GetEntityCoords(playerPed), 10.0, 0, 70) -- Find a nearby vehicle
    end

    -- Check if the vehicle exists
    if DoesEntityExist(vehicle) and vehicle ~= 0 then
        -- Trigger the client to start the vehicle search
        TriggerClientEvent('k9:startVehicleSearchClient', -1, vehicle)

        -- Broadcast to all players that K9 is searching the vehicle
        TriggerClientEvent('chat:addMessage', -1, {
            color = {255, 255, 0},
            multiline = true,
            args = {"K9 Unit", "K9 is searching the vehicle!"}
        })
    else
        -- Notify the player if no vehicle was found
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"Error", "No vehicle found nearby."}
        })
    end
end)

RegisterServerEvent('k9:broadcastVehicleSearchMessage')
AddEventHandler('k9:broadcastVehicleSearchMessage', function(vehicleName, vehiclePlate)
    -- Broadcast to all clients
    TriggerClientEvent('chat:addMessage', -1, {
        color = {255, 255, 0},
        multiline = true,
        args = {"K9 Unit", "K9 is searching a " .. vehicleName .. " (Plate: " .. vehiclePlate .. ")"}
    })
end)
