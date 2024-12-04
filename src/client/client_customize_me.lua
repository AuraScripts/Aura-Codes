local QBCore = nil
local ESX = nil

if AURA.Framework == "qb-core" then
    QBCore = exports['qb-core']:GetCoreObject()
elseif AURA.Framework == "esx" then
    ESX = exports["es_extended"]:getSharedObject()
end

RegisterNetEvent("AURA:Client:Notification")
AddEventHandler("AURA:Client:Notification", function(msg, extra)
	if AURA.NotificationSystem == 'tnotify' then
		exports['t-notify']:Alert({
			style = 'message', 
			message = msg
		})
	elseif AURA.NotificationSystem == 'mythic_old' then
		exports['mythic_notify']:DoHudText('inform', msg)
	elseif AURA.NotificationSystem == 'mythic_new' then
		exports['mythic_notify']:SendAlert('inform', msg)
	elseif AURA.NotificationSystem == 'okoknotify' then
		exports['okokNotify']:Alert(AURA.Lang.DealershipLabel, msg, 3000, 'neutral')
	elseif AURA.NotificationSystem == 'print' then
		print(msg)
	elseif AURA.NotificationSystem == 'framework' then
        if AURA.Framework == "qb-core" then
            QBCore.Functions.Notify(msg, extra)
        elseif AURA.Framework == "esx" then
            ESX.ShowNotification(msg)
        end
	end 
end)