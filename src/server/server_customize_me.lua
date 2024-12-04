local QBCore = nil
local ESX = nil

if AURA.Framework == "qb-core" then
    QBCore = exports['qb-core']:GetCoreObject()
elseif AURA.Framework == "esx" then
    ESX = exports['es_extended']:getSharedObject()
end

function GiveItem(src, item, amt)
    if AURA.Framework == "qb-core" then
        local Player = QBCore.Functions.GetPlayer(src)
        Player.Functions.AddItem(item, amt)
    elseif AURA.Framework == "esx" then
        local xPlayer = ESX.GetPlayerFromId(src)
        xPlayer.addInventoryItem(item, amt)
    end
end

function GiveMoney(src, amt)
    if AURA.Framework == "qb-core" then
        local Player = QBCore.Functions.GetPlayer(src)
        Player.Functions.AddMoney('cash', amt)
    elseif AURA.Framework == "esx" then
        local xPlayer = ESX.GetPlayerFromId(src)
        xPlayer.addAccountMoney('money', amt)
    end
end