local QBCore = exports['qb-core']:GetCoreObject()

local SPEED_LIMIT = 15          -- mph threshold for door pop
local SPEED_CONVERSION = 2.23694 -- m/s to mph conversion factor
local speedNotificationShown = false

-- Helper: show HUD notification via QBCore
local function ShowNotification(text)
    QBCore.Functions.Notify(text, 'primary', 3000)
end

-- Helper: toggle driver door open/closed based on current state
local function ToggleVehicleDoor(vehicle, doorIndex)
    if not DoesEntityExist(vehicle) then
        ShowNotification("Vehicle does not exist.")
        return
    end

    -- Get Vehicle Door Angle Ratio 
    local doorState = GetVehicleDoorAngleRatio(vehicle, doorIndex)

    if doorState > 0 then
        ShowNotification("Closing door.")
        SetVehicleDoorShut(vehicle, doorIndex, false)
    else
        ShowNotification("Opening door.")
        SetVehicleDoorOpen(vehicle, doorIndex, false, false)
    end
end

-- Reset notification flag when player exits vehicle
AddEventHandler('baseevents:leftVehicle', function()
    speedNotificationShown = false
end)

-- Command: toggle driver door, restricted to emergency vehicles (class 18) under speed limit
RegisterCommand("toggleVehicleDoor", function()
    local playerPed = PlayerPedId()

    if not IsPedInAnyVehicle(playerPed, false) then return end

    local vehicle = GetVehiclePedIsIn(playerPed, false)

    -- Seat -1 = driver seat
    if not vehicle or GetPedInVehicleSeat(vehicle, -1) ~= playerPed then return end

    if GetVehicleClass(vehicle) ~= 18 then return end

    -- GetEntitySpeed returns m/s, convert to mph
    local speed = GetEntitySpeed(vehicle) * SPEED_CONVERSION

    if speed <= SPEED_LIMIT then
        speedNotificationShown = false
        ToggleVehicleDoor(vehicle, 0) -- 0 = driver door
    elseif not speedNotificationShown then
        ShowNotification("Too fast to door pop: " .. math.ceil(speed) .. " mph")
        speedNotificationShown = true
    end
end, false)

-- Allow players to rebind to their preferred key, default G
RegisterKeyMapping("toggleVehicleDoor", "Toggle Vehicle Door", "keyboard", "G")