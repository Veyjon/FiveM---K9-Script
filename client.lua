--[[ Dog Script ]] --

-- Default Variables

local dogBreeds = {"Rottweiler", "Husky", "Retriever", "Shepherd"}
local dogBHash = {"a_c_rottweiler", "a_c_husky", "a_c_retriever", "a_c_shepherd"}
local dogTypes = {"Search", "General Purpose"}

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
                            -- Close the keyboard and menu once a name is entered
                            if k91Name ~= "" then
                                -- Close the menu and continue to the next action
                                WarMenu.CloseMenu()
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
                            -- Spawning
                            RequestModel(GetHashKey(dogBHash[currentDogIndex]))
                            while not HasModelLoaded(GetHashKey(dogBHash[currentDogIndex])) do
                                Citizen.Wait(1)
                            end

                            -- Spawn the dog
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

                            -- Friendly Relationship Setup
                            GiveWeaponToPed(k91, GetHashKey("WEAPON_ANIMAL"), true, true)
                            TaskSetBlockingOfNonTemporaryEvents(k91, true)
                            SetPedRelationshipGroupDefaultHash(k91, GetHashKey("CIVMALE"))
                            SetPedRelationshipGroupHash(k91, GetHashKey("CIVMALE"))
                            SetRelationshipBetweenGroups(0, GetHashKey("CIVMALE"), GetHashKey("PLAYER"))
                            SetRelationshipBetweenGroups(0, GetHashKey("PLAYER"), GetHashKey("CIVMALE"))

                            -- Prevent dog from running away
                            SetPedFleeAttributes(k91, 0, true)  -- Disable fleeing completely
                            SetPedCombatAttributes(k91, 3, false)  -- No combat avoidance
                            SetPedCombatAttributes(k91, 5, false)  -- Don't flee from danger
                            SetPedCombatAttributes(k91, 46, true)  -- Enable combat response
                            SetPedCombatAttributes(k91, 1, true)   -- Always fight
                            SetPedCombatAbility(k91, 2)  -- Set high combat ability
                            SetPedAlertness(k91, 2)  -- Set high alertness
                            SetEntityInvincible(k91, false)  -- Optional: make dog invincible
                            SetPedCanRagdollFromPlayerImpact(k91, false)  -- Prevent ragdolling from player impact
                            SetEntityHealth(k91, 250)

                            -- Blip Stuff
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

        -- End of Loop
    end
)

RegisterCommand(
    "dsu",
    function()
        WarMenu.OpenMenu("maink9")
    end,
    false
)

RegisterCommand(
    "att",
    function(source, args, rawCommand)
        if k91 then
            DetachEntity(k91)

            local handler = PlayerPedId()

            -- Restore player targeting for the dog
            SetPedCanBeTargettedByPlayer(k91, PlayerPedId(), true)
            SetPedCanBeDamagedByPlayerPawn(k91, PlayerPedId(), true)

            if args[1] then
                local target = GetPlayerPed(GetPlayerFromServerId(tonumber(args[1])))
                ClearPedTasks(k91)

                if IsEntityAPed(target) and target ~= handler then
                    TaskCombatPed(k91, target, 0, 16)
                end
            elseif IsPlayerFreeAiming(PlayerId()) then
                local _, target = GetEntityPlayerIsFreeAimingAt(PlayerId())
                ClearPedTasks(k91)

                if IsEntityAPed(target) and target ~= handler then
                    TaskCombatPed(k91, target, 0, 16)
                end
            else
                local target = GetPedInFront()
                ClearPedTasks(k91)

                if IsEntityAPed(target) and target ~= handler then
                    TaskCombatPed(k91, target, 0, 16)
                end
            end
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
    Command_Follow(k91)  -- Make sure `k91` is correctly defined and set
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

-- Register the "exitvehicle" command (could be bound to a key through RegisterKeyMapping as before)
RegisterCommand("exitvehicle", function()
    ExitVehicle()
end, false)

-- Register the custom keybinding for exiting the vehicle (defaults to "E")
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
    local target = GetPlayerPed(GetPlayerFromServerId(tonumber(player)))

    TaskFollowToOffsetOfEntity(dog, target, 0.5, 0.0, 0.0, 6.0, -1, 0.2, true)
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

--[[ Other Functions ]] function AdvancedNotification(icon1, icon2, type, sender, title, text) -- Function to display a notification with image.
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
    -- TextEntry --> The Text above the typing field in the black square
    -- ExampleText --> An Example Text, what it should say in the typing field
    -- MaxStringLenght --> Maximum String Lenght

    AddTextEntry("FMMC_KEY_TIP1", TextEntry) --Sets the Text above the typing field in the black square
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght) --Actually calls the Keyboard Input
    blockinput = true --Blocks new input while typing if **blockinput** is used

    while (UpdateOnscreenKeyboard() == 0) do --While typing is not aborted and not finished, this loop waits
        DisableAllControlActions(0)
        Citizen.Wait(0)
    end

    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult() --Gets the result of the typing
        Citizen.Wait(500) --Little Time Delay, so the Keyboard won't open again if you press enter to finish the typing
        blockinput = false --This unblocks new Input when typing is done
        return result --Returns the result
    else
        Citizen.Wait(500) --Little Time Delay, so the Keyboard won't open again if you press enter to finish the typing
        blockinput = false --This unblocks new Input when typing is done
        return nil --Returns nil if the typing got aborted
    end
end

