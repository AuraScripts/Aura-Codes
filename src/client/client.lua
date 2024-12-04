local myCode = {}

CreateThread(function()
	Wait(math.random(1500, 3000))
	TriggerServerEvent("AURA:Server:FetchCodeInfo")
end)
RegisterNetEvent("AURA:Client:NotReadyYet")
AddEventHandler("AURA:Client:NotReadyYet", function()
	Wait(math.random(1500, 3000))
	TriggerServerEvent("AURA:Server:FetchCodeInfo")
end)
RegisterNetEvent("AURA:Client:UpdateToCode")
AddEventHandler("AURA:Client:UpdateToCode", function(tab)
	myCode = tab
end)



RegisterCommand('code', function()
	if myCode["Code"] then
		local cantClaimFriendCodes = false
		local doesntHaveRewards = false

		if myCode.Playtime > AURA.ClaimFriendCodePlaytimeMax then
			cantClaimFriendCodes = true
		end

		if not myCode.RewardsToClaim.Items[1] and myCode.RewardsToClaim.Money == 0 then
			doesntHaveRewards = true
		end

		lib.registerContext({
			id = 'AURA_main',
			title = AURA.Lang.MainTitle,
			options = {
				{
					title = AURA.Lang.YourFriendCode,
					description = AURA.Lang.SelectToCopy,
					icon = 'id-card',
					metadata = {
						{label = AURA.Lang.Code, value = myCode.Code},
						{label = AURA.Lang.CodeUses, value = myCode.Uses}
					},
					onSelect = function()
						lib.setClipboard(myCode.Code)
						TriggerEvent("AURA:Client:Notification", AURA.Lang.CopiedCode, "success")
					end,
				},
				{
					title = AURA.Lang.ClaimFriendsCode,
					description = AURA.Lang.ClaimFriendsCode2,
					icon = 'gifts',
					disabled = cantClaimFriendCodes,
					onSelect = function()
						local input = lib.inputDialog(AURA.Lang.ClaimFriendsCode, {
							{type = 'input', label = AURA.Lang.ClaimFriendsCode3, description = AURA.Lang.ClaimFriendsCode4, required = true},
						})
						if input and input[1] and #input[1] > 0 then
							if not cantClaimFriendCodes then
								TriggerServerEvent("AURA:Server:CheckCode", input[1])
							else
								TriggerEvent("AURA:Client:Notification", AURA.Lang.CantClaimAnymore, "error")
							end
						else
							TriggerEvent("AURA:Client:Notification", AURA.Lang.InvalidCode, "error")
							lib.showContext('AURA_main')
						end
					end,
				},
				{
					title = AURA.Lang.ClaimCode,
					description = AURA.Lang.ClaimCode2,
					icon = 'gift',
					onSelect = function()
						local input = lib.inputDialog(AURA.Lang.ClaimCode, {
							{type = 'input', label = AURA.Lang.ClaimCode3, description = AURA.Lang.ClaimCode4, required = true},
						})
						if input and input[1] and #input[1] > 0 then
							TriggerServerEvent("AURA:Server:CheckGlobalCode", input[1])
						else
							TriggerEvent("AURA:Client:Notification", AURA.Lang.InvalidCode, "error")
							lib.showContext('AURA_main')
						end
					end,
				},
				{
					title = AURA.Lang.ClaimRewards,
					description = AURA.Lang.ClaimRewards2,
					icon = 'hand',
					disabled = doesntHaveRewards,
					onSelect = function()
						if not doesntHaveRewards then
							TriggerServerEvent("AURA:Server:CollectRewards")
						else
							TriggerEvent("AURA:Client:Notification", AURA.Lang.NothingToClaim, "error")
						end
					end,
				},
			}
		})
		 
		lib.showContext('AURA_main')
	else
		TriggerEvent("AURA:Client:Notification", AURA.Lang.CodeNotLoaded, "error")
	end
end, false)
TriggerEvent('chat:addSuggestion', '/code', AURA.Lang.CodesCommandSuggestion, {})


RegisterCommand('codecreator', function()
	TriggerServerEvent("AURA:Server:OpenCodeCreator")
end, false)
TriggerEvent('chat:addSuggestion', '/codecreator', AURA.Lang.CodeCreatorCommandSuggestion, {})

local newCodeData = {
	Code = nil,
	RewardData = {Items = {}, Money = 0},
	Expires = 0
}

RegisterNetEvent("AURA:Client:OpenCodeCreator")
AddEventHandler("AURA:Client:OpenCodeCreator", function()
	local tab = {}

	if not newCodeData.Code then
		table.insert(tab, {
			title = AURA.Lang.CodeCreator2,
			description = AURA.Lang.CodeCreator3,
			icon = 'id-card',
			onSelect = function()
				local input = lib.inputDialog(AURA.Lang.CodeCreator2, {
					{type = 'input', label = AURA.Lang.CodeCreator4, required = true, min = 2, max = 16},
				})

				if input and input[1] then
					newCodeData.Code = input[1]
					TriggerEvent("AURA:Client:OpenCodeCreator")
				else
					TriggerEvent("AURA:Client:OpenCodeCreator")
				end
			end,
		})
	else
		table.insert(tab, {
			title = AURA.Lang.Code..": "..newCodeData.Code,
			description = AURA.Lang.CodeCreator3,
			icon = 'id-card',
			onSelect = function()
				local input = lib.inputDialog(AURA.Lang.CodeCreator2, {
					{type = 'input', label = AURA.Lang.CodeCreator4, required = true, min = 2, max = 16},
				})

				if input and input[1] then
					newCodeData.Code = input[1]
					TriggerEvent("AURA:Client:OpenCodeCreator")
				else
					TriggerEvent("AURA:Client:OpenCodeCreator")
				end
			end,
		})
	end

	local list = nil
	for k,v in pairs(newCodeData.RewardData.Items) do
		if list then
			list = list..", "..v.."x "..k
		else
			list = v.."x "..k
		end
	end
	if not list then
		list = AURA.Lang.CodeCreator6
	end
	table.insert(tab, {
		title = AURA.Lang.CodeCreator5,
		description = list,
		icon = 'gifts',
		onSelect = function()
			local input = lib.inputDialog(AURA.Lang.CodeCreator5, {
				{type = 'input', label = AURA.Lang.CodeCreator7, required = true},
				{type = 'number', label = AURA.Lang.CodeCreator8, required = true},
			})

			if input and input[1] and input[2] then
				if input[2] == 0 then
					if newCodeData.RewardData.Items[input[1]] then
						newCodeData.RewardData.Items[input[1]] = nil
					end
				else
					newCodeData.RewardData.Items[input[1]] = input[2]
				end
				TriggerEvent("AURA:Client:OpenCodeCreator")
			else
				TriggerEvent("AURA:Client:OpenCodeCreator")
			end
		end,
	})

	table.insert(tab, {
		title = AURA.Lang.CodeCreator9,
		description = AURA.Lang.CodeCreator10..newCodeData.RewardData.Money,
		icon = 'money-bill',
		onSelect = function()
			local input = lib.inputDialog(AURA.Lang.CodeCreator9, {
				{type = 'number', label = AURA.Lang.CodeCreator11, required = true},
			})

			if input and input[1] then
				newCodeData.RewardData.Money = tonumber(input[1])
				TriggerEvent("AURA:Client:OpenCodeCreator")
			else
				TriggerEvent("AURA:Client:OpenCodeCreator")
			end
		end,
	})

	local days = 0
	local hours = 0

	if newCodeData.Expires > 0 then
		if newCodeData.Expires > 24 then
			days = math.ceil(newCodeData.Expires/24)
			hours = (days*24) - newCodeData.Expires
		else
			hours = newCodeData.Expires
		end
	end
	table.insert(tab, {
		title = AURA.Lang.CodeCreator14,
		description = AURA.Lang.CodeCreator15..": "..days.." "..AURA.Lang.Days..", "..hours.." "..AURA.Lang.Hours,
		icon = 'calendar-days',
		onSelect = function()
			local input = lib.inputDialog(AURA.Lang.CodeCreator14, {
				{type = 'number', label = AURA.Lang.CodeCreator16, required = true},
				{type = 'number', label = AURA.Lang.CodeCreator17, required = true},
			})

			if input and (input[1] or input[2]) then
				newCodeData.Expires = 0
			end
			if input and input[1] then
				newCodeData.Expires = newCodeData.Expires + tonumber(input[1])*24
			end
			if input and input[2] then
				newCodeData.Expires = newCodeData.Expires + tonumber(input[2])
			end
			TriggerEvent("AURA:Client:OpenCodeCreator")
		end,
	})

	local hideCreateButton = false
	if not newCodeData.Code or (newCodeData.RewardData.Money == 0 and list == AURA.Lang.CodeCreator6) or newCodeData.Expires == 0 then
		hideCreateButton = true
	end

	table.insert(tab, {
		title = AURA.Lang.CodeCreator12,
		description = AURA.Lang.CodeCreator13,
		icon = 'circle-plus',
		disabled = hideCreateButton,
		onSelect = function()
			TriggerServerEvent("AURA:Server:CreateTheCode", newCodeData)
			newCodeData = {
				Code = nil,
				RewardData = {Items = {}, Money = 0},
				Expires = 0	
			}
		end,
	})

	lib.registerContext({
		id = 'AURA_codecreator',
		title = AURA.Lang.CodeCreator,
		options = tab,
		onExit = function()
			newCodeData = {
				Code = nil,
				RewardData = {Items = {}, Money = 0},
				Expires = 0	
			}
		end,
	})
	lib.showContext('AURA_codecreator')
end)