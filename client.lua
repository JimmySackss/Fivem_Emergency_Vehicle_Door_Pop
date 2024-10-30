local SPEED_LIMIT = 15 -- This is adjustable on the server side. You can set this to whatever. But remember realistically, 15 is too fast.
local SPEED_CONVERSION = 2.23694 -- The math to convert m/s to mph. 
local speedNotificationShown = false 

-- toggle the door command, triggered by a custom keybinding. 
RegisterCommand("toggleVehicleDoor", function()
    local playerPed = PlayerPedId()
    if IsPedInAnyVehicle(playerPed, false) then
        local vehicle = GetVehiclePedIsIn(playerPed, false)

        -- Now checking if the vehicle is a emergency vehicle. 
        if vehicle and GetPedInVehicleSeat(vehicle, -1) == playerPed and GetVehicleClass(vehicle) == 18 then
            local speed = GetEntitySpeed(vehicle) * SPEED_COVERSION

            -- Check to see if speed is below the limit.
            if speed <= SPEED_LIMIT then
                speedNotificationShown = false --This resetsthe notification ifthe speed is safe.
                ToggleVehicleDoor(vehicle, 0)
            elseif not speedNotificationShown then
                ShowNotification("Your speed is too high to door pop: " .. math.ceil(speed) .. " mph")
                speedNotificationShown = true
            end
        end
    end
end, (false)

-- Register key mapping to allow players to keybind to their preference.
RegisterKeyMapping("toggleVehicleDoor", "Toggle Vehicle Door", "keyboard", "G") -- Default set to "G" key.

function ToggleVehicleDoor(vehicle, doorIndex)
    if DoesEntityExist(vehicle) then
        local doorState = GetVehicleDoorAngleRatio(vehicle, doorIndex)

        if doorState > 0 then
            ShowNotification("Closing door")
            SetVehicleDoorShut(vehicle, doorIndex, false)
        else
            ShowNotification("Opening door")
            SetVehicleDoorOpen(vehicle, doorIndex, false, false)
        end
    else
        ShowNotification("Vehicle does not exist")
    end
end

function ShowNotification(text)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandThefeedPostTicker(true, false)
end
