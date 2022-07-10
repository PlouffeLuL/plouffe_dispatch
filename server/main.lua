local Auth = nil
local currentId = 1
local trackedJobs = {police = {}, ambulance = {}}

Auth = exports.plouffe_lib:Get("Auth")

local function playerLoggedIn(targetPlayerData)
    for k,v in pairs(trackedJobs) do
        for playerId,playerData in pairs(v) do
            TriggerClientEvent("plouffe_dispatch:client:loggedIn", playerId, targetPlayerData, k)
        end
    end
end

local function playerLoggedOut(targetPlayerData)
    for k,v in pairs(trackedJobs) do
        for playerId,playerData in pairs(v) do
            TriggerClientEvent("plouffe_dispatch:client:loggedOut", playerId, targetPlayerData)
        end
    end
end

AddEventHandler("ooc_core:setjob", function(playerId, job, lastJob)
    local alreadyLoggedIn = false

    if trackedJobs[job.name] and not trackedJobs[job.name][playerId] then
        local playerData = exports.ooc_core:getPlayerFromId(playerId)
        local name = ("%s.%s"):format(playerData.identity.firstname:sub(1,1), playerData.identity.lastname)

        trackedJobs[playerData.job.name][playerData.playerId] = {
            id = playerData.playerId,
            name = name,
            badge = playerData.metadata.pdGroup and playerData.metadata.pdGroup.badge or "Inconnue",
            departement = playerData.metadata.pdGroup and playerData.metadata.pdGroup.abreviate or "Inconnue",
            radio = Player(playerId).state.radioChannel
        }

        playerLoggedIn(trackedJobs[playerData.job.name][playerData.playerId])
    end

    if trackedJobs[lastJob.name] and (trackedJobs[lastJob.name][playerId] and lastJob.name ~= job.name) then
        playerLoggedOut(trackedJobs[lastJob.name][playerId])
        trackedJobs[lastJob.name][playerId] = nil
    end
end)

AddEventHandler("ooc_core:playerloaded", function(playerData)
    if trackedJobs[playerData.job.name] then
        local name = ("%s.%s"):format(playerData.identity.firstname:sub(1,1), playerData.identity.lastname)
        TriggerClientEvent("plouffe_dispatch:client:spawned", playerData.playerId, trackedJobs)

        trackedJobs[playerData.job.name][playerData.playerId] = {
            id = playerData.playerId,
            name = name,
            badge = playerData.metadata.pdGroup and playerData.metadata.pdGroup.badge or "Inconnue",
            departement = playerData.metadata.pdGroup and playerData.metadata.pdGroup.abreviate or "Inconnue",
            radio = "0"
        }

        playerLoggedIn(trackedJobs[playerData.job.name][playerData.playerId])
    end
end)

AddEventHandler("ooc_core:playerDropped", function(playerData)
    if trackedJobs[playerData.job.name] then
        playerLoggedOut(trackedJobs[playerData.job.name][playerData.playerId])
        trackedJobs[playerData.job.name][playerData.playerId] = nil
    end
end)

RegisterNetEvent("plouffe_dispatch:server:sendAlert", function(alert)
    local playerId = source

    if not Auth:Events(playerId, "plouffe_dispatch:server:sendAlert") then
        print(("Player %s spammed alert event"):format(playerId))
    end

    alert.id = currentId
    currentId = currentId + 1

    if not alert.job then
        return
    end

    for k,v in pairs(alert.job) do
        if trackedJobs[k] then
            for playerId,playerData in pairs(trackedJobs[k]) do
                TriggerClientEvent("plouffe_dispatch:client:sendAlert", playerId, alert)
            end
        end
    end
end)

CreateThread(function()
    local players = GetPlayers()

    Wait(1000)

    for k,v in pairs(players) do
        local playerData = exports.ooc_core:getPlayerFromId(v)

        if playerData and trackedJobs[playerData.job.name] then
            local name = ("%s.%s"):format(playerData.identity.firstname:sub(1,1), playerData.identity.lastname)

            trackedJobs[playerData.job.name][playerData.playerId] = {
                id = playerData.playerId,
                name = name,
                badge = playerData.metadata.pdGroup and playerData.metadata.pdGroup.badge or "Inconnue",
                departement = playerData.metadata.pdGroup and playerData.metadata.pdGroup.abreviate or "Inconnue",
                radio = "0"
            }
        end
    end

    for k,v in pairs(players) do
        local playerData = exports.ooc_core:getPlayerFromId(v)

        if playerData and trackedJobs[playerData.job.name] then
            TriggerClientEvent("plouffe_dispatch:client:spawned", playerData.playerId, trackedJobs)
        end
    end

end)

function SetPlayerRadio(playerId, radio)
    local playerData = exports.ooc_core:getPlayerFromId(playerId)

    if trackedJobs[playerData.job.name] and trackedJobs[playerData.job.name][playerId] then
        trackedJobs[playerData.job.name][playerId].radio = radio

        for k,v in pairs(trackedJobs) do
            for thisPlayerId,playerData in pairs(v) do
                TriggerClientEvent("plouffe_dispatch:client:updateTargetRadio", thisPlayerId, playerId, radio)
            end
        end
    end
end
exports("SetPlayerRadio", SetPlayerRadio)

function sendAlert(alert)
    alert.id = currentId
    currentId = currentId + 1

    if not alert.job then
        return
    end

    for k,v in pairs(alert.job) do
        if trackedJobs[k] then
            for playerId,playerData in pairs(trackedJobs[k]) do
                TriggerClientEvent("plouffe_dispatch:client:sendAlert", playerId, alert)
            end
        end
    end
end
exports("sendAlert",  sendAlert)