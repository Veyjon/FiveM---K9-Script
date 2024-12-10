--[[ Dog Script ]] --

local dogBreeds = {"Rottweiler", "Husky", "Retriever", "Shepherd"}
local dogBHash = {"a_c_rottweiler", "a_c_husky", "a_c_retriever", "a_c_shepherd"}
local dogTypes = {"Search", "General Purpose"}
local dogModelHashes = {
    Rottweiler = GetHashKey("a_c_rottweiler"),
    Husky = GetHashKey("a_c_husky"),
    Retriever = GetHashKey("a_c_retriever"),
    Shepherd = GetHashKey("a_c_shepherd")
}

local DogState = {
    entity = nil,
    name = nil,
    blip = nil,
    breed = nil
}

local function ResetDogState()
    if DogState.blip then
        RemoveBlip(DogState.blip)
    end
    DogState = {
        entity = nil,
        name = nil,
        blip = nil,
        breed = nil
    }
end

local function SafeModelRequest(modelHash)
    if not HasModelLoaded(modelHash) then
        RequestModel(modelHash)
        local timeout = 0
        while not HasModelLoaded(modelHash) and timeout < 100 do
            Citizen.Wait(50)
            timeout = timeout + 1
        end
        
        if not HasModelLoaded(modelHash) then
            print("Failed to load model: " .. modelHash)
            return false
        end
    end
    return true
end

local function ValidateDogName(name)
    return name ~= nil and name ~= "" and #name <= 30
end

local k91 = nil
local k91Name = nil

local blipk91 = nil

local selectedDogIndex = 1
local currentDogIndex = 1
local currentTypeIndex = 1
local selectedTypeIndex = 1

Citizen.CreateThread(
    function()
        WarMenu.CreateMenu("maink9", "K9 Script")
        WarMenu.SetSubTitle("maink9", "by Veyjon")

        while true do
            if WarMenu.IsMenuOpened("maink9") then
                if k91 == nil then
                    if WarMenu.Button("K9 name", "Set Name") then
                        DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", "", "", "", "", 30)
                        while (UpdateOnscreenKeyboard() == 0) do
                            DisableAllControlActions(0)
                            Wait(0)
                        end
                        if (GetOnscreenKeyboardResult()) then
                            k91Name = GetOnscreenKeyboardResult()
                            if k91Name ~= "" then
                                WarMenu.CloseMenu()

                                WarMenu.OpenMenu(maink9)
                            else
                                AdvancedNotification(
                                    "CHAR_FLOYD",
                                    "uber",
                                    7,
                                    "~g~Veyjon",
                                    "K9 Script",
                                    "You must enter a name!"
                                )
                            end
                        end
                    elseif
                        WarMenu.ComboBox(
                            "Breed",
                            dogBreeds,
                            currentDogIndex,
                            selectedDogIndex,
                            function(currentIndex, selectedIndex)
                                currentDogIndex = currentIndex
                                selectedDogIndex = selectedIndex
                                print("Updated currentDogIndex: " .. currentDogIndex)
                                print("Updated selectedDogIndex:" .. selectedDogIndex)
                                print("Selected Breed:" .. dogBreeds[currentDogIndex])
                            end
                        )
                     then
                    elseif WarMenu.Button("Spawn K9") then
                        if not k91Name then
                            AdvancedNotification(
                                "CHAR_FLOYD",
                                "uber",
                                7,
                                "~g~Veyjon",
                                "K9 Script",
                                "Must set dog name!"
                            )
                        else
                            
                            RequestModel(GetHashKey(dogBHash[currentDogIndex]))
                            while not HasModelLoaded(GetHashKey(dogBHash[currentDogIndex])) do
                                Citizen.Wait(1)
                            end

                            
                            local pos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 2.0, 0.0)
                            local heading = GetEntityHeading(GetPlayerPed(-1))
                            local _, groundZ = GetGroundZFor_3dCoord(pos.x, pos.y, pos.z, false)

                            k91 =
                                CreatePed(
                                28,
                                GetHashKey(dogBHash[currentDogIndex]),
                                pos.x,
                                pos.y,
                                groundZ + 1,
                                heading,
                                true,
                                true
                            )

                            local function SetupDogRelationships(dog)
                                local civMaleHash = GetHashKey("CIVMALE")
                                SetPedRelationshipGroupDefaultHash(dog, civMaleHash)
                                SetPedRelationshipGroupHash(dog, civMaleHash)
                                
                                
                                SetRelationshipBetweenGroups(0, civMaleHash, GetHashKey("PLAYER"))
                            end

                            local function CreateDogBlip(dog, name)
                                local blip = AddBlipForEntity(dog)
                                SetBlipAsFriendly(blip, true)
                                SetBlipDisplay(blip, 2)
                                SetBlipShowCone(blip, true)
                                SetBlipAsShortRange(blip, false)
                                
                                BeginTextCommandSetBlipName("STRING")
                                AddTextComponentString(name)
                                EndTextCommandSetBlipName(blip)
                                
                                return blip
                            end

                            
                            GiveWeaponToPed(k91, GetHashKey("WEAPON_ANIMAL"), true, true)
                            TaskSetBlockingOfNonTemporaryEvents(k91, true)
                            SetPedRelationshipGroupDefaultHash(k91, GetHashKey("CIVMALE"))
                            SetPedRelationshipGroupHash(k91, GetHashKey("CIVMALE"))
                            SetRelationshipBetweenGroups(0, GetHashKey("CIVMALE"), GetHashKey("PLAYER"))
                            SetRelationshipBetweenGroups(0, GetHashKey("PLAYER"), GetHashKey("CIVMALE"))

                            
                            SetPedFleeAttributes(k91, 0, true)  
                            SetPedCombatAttributes(k91, 3, false)  
                            SetPedCombatAttributes(k91, 5, false)  
                            SetPedCombatAttributes(k91, 46, true)  
                            SetPedCombatAttributes(k91, 1, true)   
                            SetPedCombatAbility(k91, 2)  
                            SetPedAlertness(k91, 2)  
                            SetEntityInvincible(k91, false)  
                            SetPedCanRagdollFromPlayerImpact(k91, false)  
                            SetEntityHealth(k91, 250)

                            
                            blipk91 = AddBlipForEntity(k91)
                            SetBlipAsFriendly(blipk91, true)
                            SetBlipDisplay(blipk91, 2)
                            SetBlipShowCone(blipk91, true)
                            SetBlipAsShortRange(blipk91, false)

                            BeginTextCommandSetBlipName("STRING")
                            AddTextComponentString(k91Name)
                            EndTextCommandSetBlipName(blipk91)

                            Command_Follow(k91)
                        end
                    end
                else
                    if IsPedDeadOrDying(k91, true) then
                        AdvancedNotification(
                            "CHAR_FLOYD",
                            "uber",
                            7,
                            "~g~Veyjon",
                            "K9 Script",
                            k91Name .. " has been killed!"
                        )
                        k91 = nil
                        k91Name = nil
                        blipk91 = nil
                        RemoveBlip(blipk91)
                    end                    

                    if WarMenu.Button("Sit/Stay") then
                        Command_Sit(k91)
                    elseif WarMenu.Button("Follow/Recall") then
                        Command_Follow(k91)
                    elseif WarMenu.Button("Bark") then
                        Command_Bark(k91)
                    elseif WarMenu.Button("Lay Down") then
                        Command_Lay(k91)
                    elseif WarMenu.Button("Track") then
                        local id = KeyboardInput("Target Player's ID", "", 2)
                        Command_StartTrack(k91, id)
                    elseif WarMenu.Button("Enter Vehicle") then
                        EnterVehicle(k91)
                    elseif WarMenu.Button("Exit Vehicle") then
                        ExitVehicle(k91)
                    elseif WarMenu.Button("Dismiss") then
                        DismissDog(k91)
                    end

                    if Config.CivMenu then
                        if WarMenu.Button("Search Player") then
                            Command_SearchP(k91)
                        elseif WarMenu.Button("Search Vehicle") then
                            Command_SearchV(k91)
                        end
                    end
                end

                WarMenu.Display()

            end

            Citizen.Wait(0)

        end


    end
)

local function ValidateSearchTarget(targetId)
    local targetPed = GetPlayerPed(GetPlayerFromServerId(targetId))
    return DoesEntityExist(targetPed), targetPed
end

local function IsTargetInSearchRange(dogPos, targetPos, maxDistance)
    return Vdist(dogPos.x, dogPos.y, dogPos.z, targetPos.x, targetPos.y, targetPos.z) <= maxDistance
end

local function PerformK9Search(dog, target)
    TriggerEvent('chat:addMessage', {
        color = {0, 255, 0},
        multiline = true,
        args = {"K9", "K9 is searching the player!"}
    })

    Citizen.CreateThread(function()
        local searchDuration = math.random(3000, 10000)
        local startTime = GetGameTimer()
        local targetPos = GetEntityCoords(target)
        local searchAnimations = {
            "WORLD_DOG_SNIFF_GROUND",
            "WORLD_DOG_BARK",
            "WORLD_DOG_SITTING"
        }
        local searchSounds = {
            "BARK_SMALL_DOG_01",
            "BARK_SMALL_DOG_02",
            "BARK_MED_DOG_01",
            "BARK_MED_DOG_02"
        }

        local positions = {}
        for i = 1, 10 do
            local angle = i * 36  
            local radius = 2.0  
            
            local offsetX = math.cos(math.rad(angle)) * radius
            local offsetY = math.sin(math.rad(angle)) * radius
            
            local newX = targetPos.x + offsetX
            local newY = targetPos.y + offsetY
            local newZ = targetPos.z

            table.insert(positions, vector3(newX, newY, newZ))
        end

        for _, pos in ipairs(positions) do
            TaskGoToCoordAnyMeans(dog, pos.x, pos.y, pos.z, 1.75, 0, 0, 786603, 0xbf800000)
            
            local arrived = false
            Citizen.CreateThread(function()
                while not arrived do
                    local currentPos = GetEntityCoords(dog)
                    local distance = #(currentPos - pos)
                    
                    if distance < 1.0 then
                        arrived = true
                    end
                    Citizen.Wait(100)
                end
            end)

            while not arrived do
                Citizen.Wait(100)
            end
        end

        while GetGameTimer() - startTime < searchDuration do
            local randomAnim = searchAnimations[math.random(#searchAnimations)]
            TaskStartScenarioInPlace(dog, randomAnim, 0, true)

            if math.random() < 0.3 then
                local randomSound = searchSounds[math.random(#searchSounds)]
                PlaySound(dog, randomSound, "BARK_SMALL_DOG_SOUNDSET")
            end

            Citizen.Wait(math.random(2000, 5000))
        end

        TriggerEvent('chat:addMessage', {
            color = {0, 255, 0},
            multiline = true,
            args = {"K9", "Player search completed."}
        })

        ClearPedTasks(dog)


        TriggerServerEvent('k9:getPlayerName', GetPlayerServerId(NetworkGetPlayerIndexFromPed(target)))
    end)
end

local function SafeExecuteCommand(commandFunc)
    return function(source, args, rawCommand)
        local success, err = pcall(commandFunc, source, args, rawCommand)
        if not success then
            print("Command error: " .. tostring(err))
            TriggerEvent('chat:addMessage', {
                color = {255, 0, 0},
                multiline = true,
                args = {"Error", "An unexpected error occurred."}
            })
        end
    end
end

RegisterCommand(
    "searchp",
    function(source, args, rawCommand)
        if not k91 then
            return AdvancedNotification("CHAR_FLOYD", "uber", 7, "~g~Veyjon", "K9 Script", "You do not have a dog spawned!")
        end

        if not CooldownManager:Check("searchPlayer") then
            return
        end

        local targetId = tonumber(args[1])
        if not targetId then
            return TriggerEvent('chat:addMessage', {
                color = {255, 0, 0},
                multiline = true,
                args = {"Error", "You must specify a valid player ID."}
            })
        end

        local isValidTarget, targetPlayer = ValidateSearchTarget(targetId)
        if not isValidTarget then
            return TriggerEvent('chat:addMessage', {
                color = {255, 0, 0},
                multiline = true,
                args = {"Error", "Invalid player specified or not found."}
            })
        end

        local dogPos = GetEntityCoords(k91)
        local targetPos = GetEntityCoords(targetPlayer)

        if not IsTargetInSearchRange(dogPos, targetPos, 10.0) then
            return AdvancedNotification("CHAR_FLOYD", "uber", 7, "~g~Veyjon", "K9 Search", "~r~Target player is too far away for K9 search!")
        end

        PerformK9Search(k91, targetPlayer)
    end,
    false
)

RegisterCommand(
    "dsu",
    function()
        WarMenu.OpenMenu("maink9")
    end,
    false
)

local function FindAttackTarget(args)
    local target = nil
    
    if args[1] then
        local targetId = tonumber(args[1])
        target = targetId and GetPlayerPed(GetPlayerFromServerId(targetId))
    end
    
    if not target and IsPlayerFreeAiming(PlayerId()) then
        local _, aimedTarget = GetEntityPlayerIsFreeAimingAt(PlayerId())
        target = IsEntityAPed(aimedTarget) and aimedTarget
    end
    
    target = target or GetPedInFront()
    
    return target
end

RegisterCommand(
    "att",
    function(source, args, rawCommand)
        if not k91 then
            return AdvancedNotification("CHAR_FLOYD", "uber", 7, "~g~Veyjon", "K9 Script", "No K9 spawned to execute attack!")
        end

        local target = FindAttackTarget(args)
        
        if not target or target == PlayerPedId() then
            return AdvancedNotification("CHAR_FLOYD", "uber", 7, "~g~Veyjon", "K9 Script", "No valid target found!")
        end

        DetachEntity(k91)
        ClearPedTasks(k91)
        TaskCombatPed(k91, target, 0, 16)
        AdvancedNotification("CHAR_FLOYD", "uber", 7, "~g~Veyjon", "K9 Script", k91Name .. " is attacking the target!")
    end,
    false
)

local searchPlayerCooldown = 0
local searchVehicleCooldown = 0
local COOLDOWN_TIME = 30

local function checkCooldown(cooldownType)
    local currentTime = GetGameTimer()
    
    if cooldownType == "player" then
        if currentTime < searchPlayerCooldown then
            local remainingTime = math.ceil((searchPlayerCooldown - currentTime) / 1000)
            TriggerEvent('chat:addMessage', {
                color = {255, 0, 0},
                multiline = true,
                args = {"Error", "You must wait " .. remainingTime .. " seconds before searching again."}
            })
            return false
        end
        searchPlayerCooldown = currentTime + (COOLDOWN_TIME * 1000)
    elseif cooldownType == "vehicle" then
        if currentTime < searchVehicleCooldown then
            local remainingTime = math.ceil((searchVehicleCooldown - currentTime) / 1000)
            TriggerEvent('chat:addMessage', {
                color = {255, 0, 0},
                multiline = true,
                args = {"Error", "You must wait " .. remainingTime .. " seconds before searching again."}
            })
            return false
        end
        searchVehicleCooldown = currentTime + (COOLDOWN_TIME * 1000)
    end
    
    return true
end

RegisterCommand(
    "searchp",
    function(source, args, rawCommand)
        if not k91 then
            AdvancedNotification("CHAR_FLOYD", "uber", 7, "~g~Veyjon", "K9 Script", "You do not have a dog spawned!")
            return
        end

        if not checkCooldown("player") then
            return
        end

        local targetId = tonumber(args[1])
        if not targetId then
            TriggerEvent('chat:addMessage', {
                color = {255, 0, 0},
                multiline = true,
                args = {"Error", "You must specify a valid player ID."}
            })
            return
        end

        local targetPlayer = GetPlayerPed(GetPlayerFromServerId(targetId))

        if DoesEntityExist(targetPlayer) then
            local targetPos = GetEntityCoords(targetPlayer)
            local playerPed = PlayerPedId()
            local dogPos = GetEntityCoords(k91) 


            local distance = Vdist(dogPos.x, dogPos.y, dogPos.z, targetPos.x, targetPos.y, targetPos.z)

            local maxDistance = 10.0

            -- If the player is within the allowed distance, trigger the search
            if distance <= maxDistance then
                -- Broadcast to all players that K9 is searching the player
                TriggerEvent('chat:addMessage', {
                    color = {0, 255, 0},
                    multiline = true,
                    args = {"K9", "K9 is searching the player!"}
                })

                -- Start the K9 search animation
                Citizen.CreateThread(function()
                    -- Search duration and animations
                    local searchDuration = math.random(3000, 10000) -- 3-10 seconds of search time
                    local startTime = GetGameTimer()
                    local searchAnimations = {
                        "WORLD_DOG_SNIFF_GROUND",
                        "WORLD_DOG_BARK",
                        "WORLD_DOG_SITTING"
                    }
                    local searchSounds = {
                        "BARK_SMALL_DOG_01",
                        "BARK_SMALL_DOG_02",
                        "BARK_MED_DOG_01",
                        "BARK_MED_DOG_02"
                    }

                    -- Circular movement points
                    local positions = {}
                    for i = 1, 10 do
                        local angle = i * 36  -- 10 steps, 36 degrees apart
                        local radius = 2.0  -- 2 meters from target
                        
                        local offsetX = math.cos(math.rad(angle)) * radius
                        local offsetY = math.sin(math.rad(angle)) * radius
                        
                        local newX = targetPos.x + offsetX
                        local newY = targetPos.y + offsetY
                        local newZ = targetPos.z

                        table.insert(positions, vector3(newX, newY, newZ))
                    end

                    -- Walk to each position
                    for _, pos in ipairs(positions) do
                        -- Use TaskGoToCoordAnyMeans with increased speed of 1.75
                        TaskGoToCoordAnyMeans(k91, pos.x, pos.y, pos.z, 1.75, 0, 0, 786603, 0xbf800000)
                        
                        -- Wait until near the destination
                        local arrived = false
                        Citizen.CreateThread(function()
                            while not arrived do
                                local currentPos = GetEntityCoords(k91)
                                local distance = #(currentPos - pos)
                                
                                if distance < 1.0 then
                                    arrived = true
                                end
                                Citizen.Wait(100)
                            end
                        end)

                        -- Wait for the dog to get close to the position
                        while not arrived do
                            Citizen.Wait(100)
                        end
                    end

                    -- Search loop
                    while GetGameTimer() - startTime < searchDuration do
                        -- Random animation
                        local randomAnim = searchAnimations[math.random(#searchAnimations)]
                        TaskStartScenarioInPlace(k91, randomAnim, 0, true)

                        -- Occasional sound
                        if math.random() < 0.3 then
                            local randomSound = searchSounds[math.random(#searchSounds)]
                            PlaySound(k91, randomSound, "BARK_SMALL_DOG_SOUNDSET")
                        end

                        -- Wait a bit before next action
                        Citizen.Wait(math.random(2000, 5000))
                    end

                    -- Final actions
                    TriggerEvent('chat:addMessage', {
                        color = {0, 255, 0},
                        multiline = true,
                        args = {"K9", "Player search completed."}
                    })

                    -- Clear tasks
                    ClearPedTasks(k91)

                    -- Trigger server event to start the search
                    TriggerServerEvent('k9:getPlayerName', targetId)
                end)
            else
                -- Use AdvancedNotification to inform the local player that the target is too far
                AdvancedNotification("CHAR_FLOYD", "uber", 7, "~g~Veyjon", "K9 Search", "~r~Target player is too far away for K9 search!")
            end
        else
            TriggerEvent('chat:addMessage', {
                color = {255, 0, 0},
                multiline = true,
                args = {"Error", "Invalid player specified or not found."}
            })
        end
    end,
    false
)

-- Helper function to get heading between two points
function GetHeadingFromCoords(x1, y1, z1, x2, y2, z2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math.deg(math.atan2(dy, dx)) - 90
end

RegisterCommand(
    "searchv",
    function(source, args, rawCommand)
        -- Check if the dog is spawned
        if not k91 then
            AdvancedNotification("CHAR_FLOYD", "uber", 7, "~g~Veyjon", "K9 Script", "You do not have a dog spawned!")
            return
        end

        -- Check cooldown
        if not checkCooldown("vehicle") then
            return
        end

        local playerPed = PlayerPedId()

        -- First, check if the player is inside a vehicle
        local vehicle = GetVehiclePedIsIn(playerPed, false) -- false to get the vehicle even if the player is not inside it

        -- If not inside a vehicle, find the closest vehicle nearby
        if vehicle == 0 then
            vehicle = GetClosestVehicle(GetEntityCoords(playerPed), 10.0, 0, 71) -- 10m radius, include addon vehicles
        end

        -- Check if the vehicle exists
        if DoesEntityExist(vehicle) and vehicle ~= 0 then
            -- Get vehicle plate
            local vehiclePlate = GetVehicleNumberPlateText(vehicle)

            -- Trigger a server event to broadcast the message with vehicle plate
            TriggerServerEvent('k9:broadcastVehicleSearchMessage', "K9 is searching vehicle (Plate: " .. vehiclePlate .. ")")
            
            -- Add chat message
            TriggerEvent('chat:addMessage', {
                color = {0, 255, 0},
                multiline = true,
                args = {"K9", "K9 is searching vehicle (Plate: " .. vehiclePlate .. ")"}
            })

            -- Get vehicle position
            local vehiclePos = GetEntityCoords(vehicle)

            -- Search duration and animations
            Citizen.CreateThread(function()
                local searchDuration = math.random(3000, 10000) -- 3-10 seconds of search time
                local startTime = GetGameTimer()
                local searchAnimations = {
                    "WORLD_DOG_SNIFF_GROUND",
                    "WORLD_DOG_BARK",
                    "WORLD_DOG_SITTING"
                }
                local searchSounds = {
                    "BARK_SMALL_DOG_01",
                    "BARK_SMALL_DOG_02",
                    "BARK_MED_DOG_01",
                    "BARK_MED_DOG_02"
                }

                -- Initial circling
                local positions = {}
                for i = 1, 10 do
                    local angle = i * 36
                    local radius = 2.0
                    
                    local offsetX = math.cos(math.rad(angle)) * radius
                    local offsetY = math.sin(math.rad(angle)) * radius
                    
                    local newX = vehiclePos.x + offsetX
                    local newY = vehiclePos.y + offsetY
                    local newZ = vehiclePos.z

                    table.insert(positions, vector3(newX, newY, newZ))
                end

                -- Walk to each position
                for _, pos in ipairs(positions) do
                    TaskGoToCoordAnyMeans(k91, pos.x, pos.y, pos.z, 1.75, 0, 0, 786603, 0xbf800000)
                    
                    local arrived = false
                    Citizen.CreateThread(function()
                        while not arrived do
                            local currentPos = GetEntityCoords(k91)
                            local distance = #(currentPos - pos)
                            
                            if distance < 1.0 then
                                arrived = true
                            end
                            Citizen.Wait(100)
                        end
                    end)

                    while not arrived do
                        Citizen.Wait(100)
                    end
                end

                -- Search loop
                while GetGameTimer() - startTime < searchDuration do
                    -- Random animation
                    local randomAnim = searchAnimations[math.random(#searchAnimations)]
                    TaskStartScenarioInPlace(k91, randomAnim, 0, true)

                    -- Occasional sound
                    if math.random() < 0.3 then
                        local randomSound = searchSounds[math.random(#searchSounds)]
                        PlaySound(k91, randomSound, "BARK_SMALL_DOG_SOUNDSET")
                    end

                    -- Wait a bit before next action
                    Citizen.Wait(math.random(2000, 5000))
                end

                -- Final actions
                TriggerEvent('chat:addMessage', {
                    color = {0, 255, 0},
                    multiline = true,
                    args = {"K9", "Vehicle search completed for (Plate: " .. vehiclePlate .. ")"}
                })

                -- Clear tasks
                ClearPedTasks(k91)
            end)
        else
            -- If no vehicle found
            TriggerEvent('chat:addMessage', {
                color = {255, 0, 0},
                multiline = true,
                args = {"Error", "No vehicle found nearby."}
            })
        end
    end, 
    false
)

RegisterKeyMapping("dsu", "Open K9 Menu", "keyboard", "f1")
RegisterKeyMapping("command_sit", "Dog Sit", "keyboard", "f2")
RegisterKeyMapping("command_lay", "Dog Lay Down", "keyboard", "f3")
RegisterKeyMapping("command_follow", "Dog Follow", "keyboard", "f4")
RegisterKeyMapping("entervehicle", "Dog Enter", "keyboard", "f5")
RegisterKeyMapping("exitvehicle", "Dog Exit", "keyboard", "f6")
--

RegisterCommand("dsu", function()
    WarMenu.OpenMenu("maink9")
end, false)

RegisterCommand("command_follow", function()
    Command_Follow(k91)  
end, false)

RegisterCommand("command_sit", function()
    Command_Sit(k91)
end, false)

RegisterCommand("command_lay", function()
    Command_Lay(k91)
end, false)

RegisterCommand("entervehicle", function()
    EnterVehicle(k91)
end, false)

RegisterCommand("exitvehicle", function()
    ExitVehicle(k91)
end, false)

local dogStamina = 300.0
local maxStamina = 300.0
local staminaDrainRate = 0.2
local restRecoveryRate = 1.0

function UpdateDogStamina(dog)
    -- Drain stamina while tracking
    if IsEntityFollowingAPath(dog) then
        dogStamina = math.max(0, dogStamina - staminaDrainRate)
    end
    
    -- Recovery when not tracking
    if dogStamina < maxStamina and not IsEntityFollowingAPath(dog) then
        dogStamina = math.min(maxStamina, dogStamina + restRecoveryRate)
    end
    
    -- Stop tracking if exhausted
    if dogStamina <= 0 then
        ClearPedTasks(dog)
        TriggerEvent('chatMessage', '', {255, 165, 0}, "^3Dog is exhausted and cannot continue tracking!")
    end
end

function AdvancedTracking(dog, target)
    -- Create intermittent sniffing behavior
    CreateThread(function()
        while IsEntityFollowingAPath(dog) do
            -- Random sniffing animations
            if math.random() < 0.1 then
                RequestAnimDict('creatures@dog@move')
                TaskPlayAnim(dog, 'creatures@dog@move', 'sniff_idle', 8.0, -8.0, -1, 1, 0, false, false, false)
            end
            Wait(1000)
        end
    end)
    
    -- Add occasional path recalculation
    CreateThread(function()
        while IsEntityFollowingAPath(dog) do
            if math.random() < 0.05 then
                TaskGoToEntity(dog, target, -1, 0.5, 7.0, 1077936128, 0)
            end
            Wait(5000)
        end
    end)
end

function HandleTrackingInterruptions(dog, target)
    CreateThread(function()
        while IsEntityFollowingAPath(dog) do
            local dogCoords = GetEntityCoords(dog)
            local targetCoords = GetEntityCoords(target)
            local distance = #(dogCoords - targetCoords)
            
            -- Lost target check
            if distance > 50.0 then
                TriggerEvent('chatMessage', '', {255, 165, 0}, "^3Dog has lost the trail!")
                ClearPedTasks(dog)
                break
            end
            
            Wait(2000)
        end
    end)
end

function GetPedInFront()
    local playerPed = PlayerPedId()
    local forwardVector = GetEntityForwardVector(playerPed)
    local playerCoords = GetEntityCoords(playerPed)
    local endCoords = playerCoords + forwardVector * 5.0 

    local raycast = StartShapeTestRay(playerCoords.x, playerCoords.y, playerCoords.z, endCoords.x, endCoords.y, endCoords.z, 8, playerPed, 0)
    local _, hit, _, _, entity = GetShapeTestResult(raycast)

    if hit and IsEntityAPed(entity) then
        return entity
    end
    return nil
end

-- Function to check if the player is in a vehicle
function IsPlayerInVehicle()
    local playerPed = PlayerPedId()
    return IsPedInAnyVehicle(playerPed, false)
end

-- Function to handle exiting the vehicle (and preventing the dog from disappearing)
function ExitVehicle()
    local playerPed = PlayerPedId()  -- Get the player's Ped
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if not IsPlayerInVehicle() then
        -- Prevent the player from exiting the vehicle if not in one
        TriggerEvent('chat:addMessage', {
            args = {"[Vehicle]", "You cannot exit the vehicle at this time!"}
        })
        return  -- Do nothing if the player is not in a vehicle
    end

    -- Exit the vehicle without the dog disappearing
    TaskLeaveVehicle(playerPed, vehicle, 0)  -- Player exits the vehicle
end

RegisterCommand("exitvehicle", function()
    ExitVehicle()
end, false)

RegisterKeyMapping("exitvehicle", "Exit Vehicle", "keyboard", "E")  -- You can change the default key here

-- Add a thread to listen for the key press (and prevent exit if outside a vehicle)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        -- Check if the custom key for "Exit Vehicle" is pressed
        if IsControlJustPressed(0, GetControlInstructionalButton(0, "exitvehicle", false)) then
            ExitVehicle()
        end
    end
end)

--[[ Command Functions ]] function Command_Sit(ped)
    ClearPedTasks(ped)

    RequestAnimDict("creatures@rottweiler@amb@world_dog_sitting@base")
    while not HasAnimDictLoaded("creatures@rottweiler@amb@world_dog_sitting@base") do
        Citizen.Wait(1)
    end
    TaskPlayAnim(ped, "creatures@rottweiler@amb@world_dog_sitting@base", "base", 8.0, -4.0, -1, 1, 0.0)
end

function Command_Follow(ped)
    if IsPedInAnyVehicle(ped, false) then
        TaskLeaveVehicle(ped, GetVehiclePedIsIn(ped, false), 0)
        while IsPedInAnyVehicle(ped, false) do
            Citizen.Wait(100)
        end
    end

    ClearPedTasks(ped)
    DetachEntity(ped)
    TaskFollowToOffsetOfEntity(ped, GetPlayerPed(-1), 0.5, 0.0, 0.0, 7.0, -1, 0.2, true)
end

function Command_Bark(ped)
    ClearPedTasks(ped)

    RequestAnimDict("creatures@retriever@amb@world_dog_barking@base")
    while not HasAnimDictLoaded("creatures@retriever@amb@world_dog_barking@base") do
        Citizen.Wait(1)
    end
    TaskPlayAnim(ped, "creatures@retriever@amb@world_dog_barking@base", "base", 8.0, -4.0, -1, 1, 0.0)
end

function Command_Lay(ped)
    ClearPedTasks(ped)

    RequestAnimDict("creatures@rottweiler@amb@sleep_in_kennel@")
    while not HasAnimDictLoaded("creatures@rottweiler@amb@sleep_in_kennel@") do
        Citizen.Wait(1)
    end
    TaskPlayAnim(ped, "creatures@rottweiler@amb@sleep_in_kennel@", "sleep_in_kennel", 8.0, -4.0, -1, 1, 0.0)
end

function Command_StartTrack(dog, player)
    print("Starting track - Player ID: " .. tostring(player))
    
    local target = GetPlayerPed(GetPlayerFromServerId(tonumber(player)))
    
    if not DoesEntityExist(target) then
        print("Target not found")
        return
    end
    
    -- Check if player is in range and has line of sight
    local dogCoords = GetEntityCoords(dog)
    local targetCoords = GetEntityCoords(target)
    local distance = #(dogCoords - targetCoords)
    local maxRange = 10000.0  -- Increased range
    
    if distance > maxRange then
        TriggerEvent('chatMessage', '', {255, 0, 0}, "^1Target is too far for the dog to track!")
        return
    end
    
    -- Check if path to target is possible
    local startTime = GetGameTimer()
    local canPath = false
    
    RequestCollisionAtCoord(targetCoords.x, targetCoords.y, targetCoords.z)
    while not HasCollisionLoadedAroundEntity(target) and GetGameTimer() - startTime < 1000 do
        Wait(0)
    end
    
    if GetIsTaskActive(dog, 35) then -- Check if navigation is possible
        canPath = true
    end
    
    if not canPath then
        TriggerEvent('chatMessage', '', {255, 0, 0}, "^1Dog cannot pick up the scent from here!")
        return
    end
    
    ClearPedTasks(dog)
    
    -- Enhanced pathing settings
    SetPedPathCanUseClimbovers(dog, true)
    SetPedPathCanUseLadders(dog, false)
    SetPedPathAvoidFire(dog, true)
    SetPedPathPreferToAvoidWater(dog, true)
    SetPedMoveRateOverride(dog, 1.25) -- Make movement smoother
    
    -- Use both NavMesh and entity following for better tracking
    TaskGoToEntity(dog, target, -1, 0.5, 12.0, 1077936128, 0)
    SetPedKeepTask(dog, true)
    
    -- Only trigger success message if pathing is established
    if canPath then
        TriggerEvent('chatMessage', '', {0, 255, 0}, "^2Dog has picked up the scent!")
    end
end

function EnterVehicle(ped)
    if IsPedInAnyVehicle(PlayerPedId(), false) then
        ClearPedTasks(ped)

        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        local vehHeading = GetEntityHeading(vehicle)

        TaskGoToEntity(ped, vehicle, -1, 0.5, 100, 1073741824, 0)
        TaskAchieveHeading(ped, vehHeading, -1)

        RequestAnimDict("creatures@rottweiler@in_vehicle@van")
        RequestAnimDict("creatures@rottweiler@amb@world_dog_sitting@base")

        while not HasAnimDictLoaded("creatures@rottweiler@in_vehicle@van") or
            not HasAnimDictLoaded("creatures@rottweiler@amb@world_dog_sitting@base") do
            Citizen.Wait(1)
        end

        TaskPlayAnim(ped, "creatures@rottweiler@in_vehicle@van", "get_in", 8.0, -4.0, -1, 2, 0.0)
        Citizen.Wait(700)
        ClearPedTasks(ped)

        AttachEntityToEntity(ped, vehicle, GetEntityBoneIndexByName(vehicle, Config.VehicleBone), 0.0, 0.0, 0.25)
        TaskPlayAnim(ped, "creatures@rottweiler@amb@world_dog_sitting@base", "base", 8.0, -4.0, -1, 2, 0.0)
    else
        AdvancedNotification("CHAR_FLOYD", "uber", 7, "~g~Veyjon", "K9 Script", "You must be inside a vehicle!")
    end
end

function ExitVehicle(ped)
    local vehicle = GetEntityAttachedTo(ped)
    local vehPos = GetEntityCoords(vehicle)
    local forwardX = GetEntityForwardVector(vehicle).x * 3.7
    local forwardY = GetEntityForwardVector(vehicle).y * 3.7
    local _, groundZ = GetGroundZFor_3dCoord(vehPos.x, vehPos.y, vehPos.z, 0)

    ClearPedTasks(ped)
    DetachEntity(ped)

    SetEntityCoords(ped, vehPos.x + forwardX, vehPos.y + forwardY, groundZ + 1.0)

    Command_Follow(ped)
end

function DismissDog(ped)
    ClearPedTasks(ped)

    DeletePed(ped)

    blipk91 = nil
    k91 = nil
    k91Name = nil
    RemoveBlip(blipk91)
end
--

--[[ Other Functions ]] function AdvancedNotification(icon1, icon2, type, sender, title, text)
    Citizen.CreateThread(
        function()
            Wait(1)
            SetNotificationTextEntry("STRING")
            AddTextComponentString(text)
            SetNotificationMessage(icon1, icon2, true, type, sender, title, text)
            DrawNotification(false, true)
            Citizen.Wait(60000)
        end
    )
end
Citizen.CreateThread(function()
    while true do
        if k91 then
            if IsPedInCombat(k91, GetPlayerPed(PlayerId())) then
                print('Dont attack player')
                ClearPedTasks(k91)
                Command_Follow(k91)
            end
            
            -- Only prevent fleeing if not in combat with another ped
            if IsPedFleeing(k91) and not IsPedInMeleeCombat(k91) then
                print('Dont flee player')
                ClearPedTasks(k91)
                Command_Follow(k91)
            end
        end
        Citizen.Wait(500)
    end
end)

function KeyboardInput(TextEntry, ExampleText, MaxStringLenght)

    AddTextEntry("FMMC_KEY_TIP1", TextEntry) 
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght) 
    blockinput = true 

    while (UpdateOnscreenKeyboard() == 0) do 
        DisableAllControlActions(0)
        Citizen.Wait(0)
    end

    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult() 
        Citizen.Wait(500) 
        blockinput = false 
        return result 
    else
        Citizen.Wait(500) 
        blockinput = false
        return nil 
    end
end
