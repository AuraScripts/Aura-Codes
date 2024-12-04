CodeCreators = { --This is where you add all your code creators, must match the license you have checking above!
    --Example: "license:b57267ca8ac5ee2e6218821d610f9aa9ff30a1c2"
"license:bae0adc88c1b038812010ad03f65382c57689657",
}


Webhooks = { --Put Discord Webhook Links In these
    ClaimFriendCode = "https://discord.com/api/webhooks/1313624489505853503/mDjdcCO4mgVphqvgjB1HDWYE8t0JsNXlOmsGC6zRcsAoan7zQDCKeEsOwHtp7QvyXTsE",
    ClaimServerCode = "https://discord.com/api/webhooks/1313624489505853503/mDjdcCO4mgVphqvgjB1HDWYE8t0JsNXlOmsGC6zRcsAoan7zQDCKeEsOwHtp7QvyXTsE",
    RedeemRewards = "https://discord.com/api/webhooks/1313624489505853503/mDjdcCO4mgVphqvgjB1HDWYE8t0JsNXlOmsGC6zRcsAoan7zQDCKeEsOwHtp7QvyXTsE",
    CreateCode = "https://discord.com/api/webhooks/1313624489505853503/mDjdcCO4mgVphqvgjB1HDWYE8t0JsNXlOmsGC6zRcsAoan7zQDCKeEsOwHtp7QvyXTsE"
}


--------------------------------------------------------------------ADD CODE CREATORS ABOVE--------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Script Below






local pCodes_identifier = {}
local pCodes_code = {}
local cCodes = {}
local loadedTables = false

local pIdentToId = {}

CreateThread(function()
    local temp_pCodes = MySQL.query.await('SELECT * from aura_codes', {})
    if temp_pCodes and temp_pCodes[1] then
        local pCodes_identifier2 = {}
        local pCodes_code2 = {}
        for i=1, #temp_pCodes do
            pCodes_identifier2[temp_pCodes[i].identifier] = {Code = temp_pCodes[i].code, Uses = temp_pCodes[i].uses, Playtime = temp_pCodes[i].playtime, UsedCodes = json.decode(temp_pCodes[i].usedcodes), UsedFCodes = json.decode(temp_pCodes[i].usedfriendcodes), RewardsToClaim = json.decode(temp_pCodes[i].rewardstoclaim)}
            pCodes_code2[temp_pCodes[i].code] = {Identifier = temp_pCodes[i].identifier, Uses = temp_pCodes[i].uses, Playtime = temp_pCodes[i].playtime, UsedCodes = json.decode(temp_pCodes[i].usedcodes), UsedFCodes = json.decode(temp_pCodes[i].usedfriendcodes), RewardsToClaim = json.decode(temp_pCodes[i].rewardstoclaim)}
        end

        pCodes_identifier = pCodes_identifier2
        pCodes_code = pCodes_code2
    end

    local temp_cCodes = MySQL.query.await('SELECT * from aura_createdcodes', {})
    if temp_cCodes and temp_cCodes[1] then
        local cCodes2 = {}
        for i=1, #temp_cCodes do
            cCodes2[temp_cCodes[i].code] = {RewardData = json.decode(temp_cCodes[i].reward_data)}
        end

        cCodes = cCodes2
    end

    loadedTables = true
    while true do
        MySQL.Async.execute('DELETE FROM aura_createdcodes WHERE date_deletion < NOW()', {}, function(result)
            if result > 0 then
                print('^1[AURA_Codes] ^0Deleted ^2'..result..' ^0expired codes from the database.')
            end
        end)
        local temp_cCodes = MySQL.query.await('SELECT * from aura_createdcodes', {})
        if temp_cCodes and temp_cCodes[1] then
            local cCodes2 = {}
            for i=1, #temp_cCodes do
                cCodes2[temp_cCodes[i].code] = {RewardData = json.decode(temp_cCodes[i].reward_data)}
            end

            cCodes = cCodes2
        end
        Wait(AURA.CheckCodesInterval*60000)
    end
end)
CreateThread(function()
    while true do
        if loadedTables then
            for k,v in pairs(pIdentToId) do
                MySQL.update('UPDATE aura_codes SET playtime = ? WHERE (`identifier`) = (?)', {pCodes_identifier[k].Playtime, k}) 
            end
        end
        Wait(AURA.UpdatePlayersInDatabase*60000)
    end
end)
CreateThread(function()
    while true do
        Wait(60000)
        if loadedTables then
            for k,v in pairs(pIdentToId) do
                if GetPlayerName(v) then
                    pCodes_identifier[k].Playtime = pCodes_identifier[k].Playtime + 1
                    TriggerClientEvent("AURA:Client:UpdateToCode", v, {Code = pCodes_identifier[k].Code, Uses = pCodes_identifier[k].Uses, Playtime = pCodes_identifier[k].Playtime, UsedCodes = pCodes_identifier[k].UsedCodes, UsedFCodes = pCodes_identifier[k].UsedFCodes, RewardsToClaim = pCodes_identifier[k].RewardsToClaim})
                else
                    pIdentToId[k] = nil
                end
                Wait(10)
            end
        end
    end
end)

RegisterServerEvent("AURA:Server:FetchCodeInfo")
AddEventHandler("AURA:Server:FetchCodeInfo", function()
    local src = source
    local ident = GetPlayerIdentifierByType(src, AURA.Identifier)

    if loadedTables then
        if ident and ident ~= "nil" then
            if pCodes_identifier[ident] then
                TriggerClientEvent("AURA:Client:UpdateToCode", src, {Code = pCodes_identifier[ident].Code, Uses = pCodes_identifier[ident].Uses, Playtime = pCodes_identifier[ident].Playtime, UsedCodes = pCodes_identifier[ident].UsedCodes, UsedFCodes = pCodes_identifier[ident].UsedFCodes, RewardsToClaim = pCodes_identifier[ident].RewardsToClaim})
                pIdentToId[ident] = src
            else
                local NewCode = nil
                NewCode = GetNewCode()
                pCodes_identifier[ident] = {Code = NewCode, Uses = 0, Playtime = 0, UsedCodes = {}, UsedFCodes = {}, RewardsToClaim = {Items = {}, Money = 0}}
                pCodes_code[NewCode] = {Identifier = ident, Uses = 0, Playtime = 0, UsedCodes = {}, UsedFCodes = {}, RewardsToClaim = {Items = {}, Money = 0}}
                MySQL.insert('INSERT INTO aura_codes (identifier, code, uses, playtime, usedcodes, usedfriendcodes, rewardstoclaim) VALUES (?, ?, ?, ?, ?, ?, ?)',
                    {
                        ident,
                        NewCode,
                        0,
                        0,
                        json.encode({}),
                        json.encode({}),
                        json.encode({Items = {}, Money = 0})
                    }
                )
                TriggerClientEvent("AURA:Client:UpdateToCode", src, {Code = NewCode, Uses = 0, Playtime = 0, UsedCodes = {}, UsedFCodes = {}, RewardsToClaim = {Items = {}, Money = 0}})
                pIdentToId[ident] = src
            end
        else
            print("^1[WARNING] ^0Was Not Able To Grab Identifier For ^2ID:"..src.." / Name:"..GetPlayerName(src).."^0")
        end
    else
        TriggerClientEvent("AURA:Client:NotReadyYet", src)
    end
end)

RegisterServerEvent("AURA:Server:CheckCode")
AddEventHandler("AURA:Server:CheckCode", function(daCode)
    local src = source
    local ident = GetPlayerIdentifierByType(src, AURA.Identifier)

    if pCodes_code[daCode] then
        if ident and ident ~= "nil" then
            local canClaim = true
            if pCodes_identifier[ident].UsedFCodes[1] then
                for i=1, #pCodes_identifier[ident].UsedFCodes do
                    if daCode == pCodes_identifier[ident].UsedFCodes[i] then
                        canClaim = false
                    end
                end
            end

            if daCode == pCodes_identifier[ident].Code then
                TriggerClientEvent("AURA:Client:Notification", src, AURA.Lang.InvalidCode, "error")
                return
            end

            if canClaim then
                table.insert(pCodes_identifier[ident].UsedFCodes, daCode)
                table.insert(pCodes_code[pCodes_identifier[ident].Code].UsedFCodes, daCode)
                pCodes_code[daCode].Uses = pCodes_code[daCode].Uses + 1
                pCodes_identifier[pCodes_code[daCode].Identifier].Uses = pCodes_identifier[pCodes_code[daCode].Identifier].Uses + 1

                local ClaimerRewards = {Items = {}, Money = 0}
                ClaimerRewards.Items = pCodes_identifier[ident].RewardsToClaim.Items
                ClaimerRewards.Money = AURA.DefaultReward.Claimer.Money + pCodes_identifier[ident].RewardsToClaim.Money
                for k,v in pairs(AURA.DefaultReward.Claimer.Items) do
                    if ClaimerRewards.Items[k] then
                        ClaimerRewards.Items[k] = ClaimerRewards.Items[k] + v
                    else
                        ClaimerRewards.Items[k] = v
                    end
                end
                pCodes_identifier[ident].RewardsToClaim = ClaimerRewards
                pCodes_code[pCodes_identifier[ident].Code].RewardsToClaim = ClaimerRewards
                MySQL.update('UPDATE aura_codes SET usedfriendcodes = ? WHERE (`identifier`) = (?)', {json.encode(pCodes_identifier[ident].UsedFCodes), ident})
                MySQL.update('UPDATE aura_codes SET rewardstoclaim = ? WHERE (`identifier`) = (?)', {json.encode(pCodes_identifier[ident].RewardsToClaim), ident})
                if pIdentToId[ident] then
                    TriggerClientEvent("AURA:Client:UpdateToCode", pIdentToId[ident], {Code = pCodes_identifier[ident].Code, Uses = pCodes_identifier[ident].Uses, Playtime = pCodes_identifier[ident].Playtime, UsedCodes = pCodes_identifier[ident].UsedCodes, UsedFCodes = pCodes_identifier[ident].UsedFCodes, RewardsToClaim = pCodes_identifier[ident].RewardsToClaim})
                end

                local OwnerRewards = {Items = {}, Money = 0}
                OwnerRewards.Items = pCodes_code[daCode].RewardsToClaim.Items
                OwnerRewards.Money = AURA.DefaultReward.CodeOwner.Money + pCodes_code[daCode].RewardsToClaim.Money
                for k,v in pairs(AURA.DefaultReward.CodeOwner.Items) do
                    if OwnerRewards.Items[k] then
                        OwnerRewards.Items[k] = OwnerRewards.Items[k] + v
                    else
                        OwnerRewards.Items[k] = v
                    end
                end
                if AURA.SpecialRewardMilestones[tostring(pCodes_code[daCode].Uses)] then
                    OwnerRewards.Money = OwnerRewards.Money + AURA.SpecialRewardMilestones[tostring(pCodes_code[daCode].Uses)].Money
                    for k,v in pairs(AURA.SpecialRewardMilestones[tostring(pCodes_code[daCode].Uses)].Items) do
                        if OwnerRewards.Items[k] then
                            OwnerRewards.Items[k] = OwnerRewards.Items[k] + V
                        else
                            OwnerRewards.Items[k] = v
                        end
                    end
                end
                pCodes_identifier[pCodes_code[daCode].Identifier].RewardsToClaim = OwnerRewards
                pCodes_code[daCode].RewardsToClaim = OwnerRewards
                MySQL.update('UPDATE aura_codes SET uses = ? WHERE (`identifier`) = (?)', {pCodes_code[daCode].Uses, pCodes_code[daCode].Identifier})
                MySQL.update('UPDATE aura_codes SET rewardstoclaim = ? WHERE (`identifier`) = (?)', {json.encode(pCodes_code[daCode].RewardsToClaim), pCodes_code[daCode].Identifier})
                if pIdentToId[pCodes_code[daCode].Identifier] then
                    TriggerClientEvent("AURA:Client:UpdateToCode", pIdentToId[pCodes_code[daCode].Identifier], {Code = pCodes_identifier[ident].Code, Uses = pCodes_identifier[ident].Uses, Playtime = pCodes_identifier[ident].Playtime, UsedCodes = pCodes_identifier[ident].UsedCodes, UsedFCodes = pCodes_identifier[ident].UsedFCodes, RewardsToClaim = pCodes_identifier[ident].RewardsToClaim})
                end
                
                if Webhooks.ClaimFriendCode ~= "" then
                    local dat = {
                        {
                            ["name"] = "**"..AURA.Lang.PlayerInfo..":**",
                            ["value"] = AURA.Lang.Name..": **"..GetPlayerName(src).."**\n"..AURA.Lang.Id..": **"..src.."**\n"..AURA.Lang.Identifier..": **"..ident.."**",
                            ["inline"] = false
                        },
                        {
                            ["name"] = "**"..AURA.Lang.CodeInfo..":**",
                            ["value"] = AURA.Lang.Code..": **"..daCode.."**",
                            ["inline"] = false
                        }
                    }
                    sendToDiscord(dat, 32768, AURA.Lang.PlayerClaimedFriendCode, Webhooks.ClaimFriendCode)
                end

                TriggerClientEvent("AURA:Client:Notification", src, AURA.Lang.ClaimedFriendCode, "success")
            else
                TriggerClientEvent("AURA:Client:Notification", src, AURA.Lang.AlreadyClaimed, "error")
            end
        else
            TriggerClientEvent("AURA:Client:Notification", src, AURA.Lang.UnableToProccessCode, "error")
        end
    else
        TriggerClientEvent("AURA:Client:Notification", src, AURA.Lang.InvalidCode, "error")
    end
end)



RegisterServerEvent("AURA:Server:CollectRewards")
AddEventHandler("AURA:Server:CollectRewards", function()
    local src = source
    local ident = GetPlayerIdentifierByType(src, AURA.Identifier)

    if ident and ident ~= "nil" then
        if pCodes_identifier[ident].RewardsToClaim.Items[1] or pCodes_identifier[ident].RewardsToClaim.Money > 0 then
            local itemstring = "None"
            for k,v in pairs(pCodes_identifier[ident].RewardsToClaim.Items) do
                GiveItem(src, k, v)
                if itemstring ~= "None" then
                    itemstring = itemstring..", "..v.."x "..k
                else
                    itemstring = v.."x "..k
                end
            end
            if pCodes_identifier[ident].RewardsToClaim.Money > 0 then
                GiveMoney(src, pCodes_identifier[ident].RewardsToClaim.Money)
            end

            pCodes_identifier[ident].RewardsToClaim = {Items = {}, Money = 0}
            pCodes_code[pCodes_identifier[ident].Code].RewardsToClaim = {Items = {}, Money = 0}
            MySQL.update('UPDATE aura_codes SET rewardstoclaim = ? WHERE (`identifier`) = (?)', {json.encode(pCodes_identifier[ident].RewardsToClaim), ident})
            TriggerClientEvent("AURA:Client:Notification", src, AURA.Lang.RewardsClaimed, "success")
            TriggerClientEvent("AURA:Client:UpdateToCode", src, {Code = pCodes_identifier[ident].Code, Uses = pCodes_identifier[ident].Uses, Playtime = pCodes_identifier[ident].Playtime, UsedCodes = pCodes_identifier[ident].UsedCodes, UsedFCodes = pCodes_identifier[ident].UsedFCodes, RewardsToClaim = pCodes_identifier[ident].RewardsToClaim})
            if Webhooks.RedeemRewards ~= "" then
                local dat = {
                    {
                        ["name"] = "**"..AURA.Lang.PlayerInfo..":**",
                        ["value"] = AURA.Lang.Name..": **"..GetPlayerName(src).."**\n"..AURA.Lang.Id..": **"..src.."**\n"..AURA.Lang.Identifier..": **"..ident.."**",
                        ["inline"] = false
                    },
                    {
                        ["name"] = "**"..AURA.Lang.RewardInfo..":**",
                        ["value"] = AURA.Lang.CodeCreator9..": **$"..pCodes_identifier[ident].RewardsToClaim.Money.."**\n"..AURA.Lang.CodeCreator5..": **"..itemstring.."**",
                        ["inline"] = false
                    }
                }
                sendToDiscord(dat, 78368, AURA.Lang.PlayerClaimedRewards, Webhooks.RedeemRewards)
            end
        else
            TriggerClientEvent("AURA:Client:Notification", src, AURA.Lang.NothingToClaim, "error")
        end
    else
        TriggerClientEvent("AURA:Client:Notification", src, AURA.Lang.UnableToProccessRewards, "error")
    end
end)

RegisterServerEvent("AURA:Server:CheckGlobalCode")
AddEventHandler("AURA:Server:CheckGlobalCode", function(daCode)
    local src = source
    local ident = GetPlayerIdentifierByType(src, AURA.Identifier)

    if ident and ident ~= "nil" then
        if cCodes[daCode] then
            local canClaim = true
            if pCodes_identifier[ident].UsedCodes[1] then
                for i=1, #pCodes_identifier[ident].UsedCodes do
                    if daCode == pCodes_identifier[ident].UsedCodes[i] then
                        canClaim = false
                    end
                end
            end

            if canClaim then
                local itemstring = "None"
                table.insert(pCodes_identifier[ident].UsedCodes, daCode)
                table.insert(pCodes_code[pCodes_identifier[ident].Code].UsedCodes, daCode)
                for k,v in pairs(cCodes[daCode].RewardData.Items) do
                    GiveItem(src, k, v)
                    if itemstring ~= "None" then
                        itemstring = itemstring..", "..v.."x "..k
                    else
                        itemstring = v.."x "..k
                    end
                end
                if cCodes[daCode].RewardData.Money > 0 then
                    GiveMoney(src, cCodes[daCode].RewardData.Money)
                end
                MySQL.update('UPDATE aura_codes SET usedcodes = ? WHERE (`identifier`) = (?)', {json.encode(pCodes_identifier[ident].UsedCodes), ident})
                TriggerClientEvent("AURA:Client:Notification", src, AURA.Lang.CodeClaimed, "success")
                TriggerClientEvent("AURA:Client:UpdateToCode", src, {Code = pCodes_identifier[ident].Code, Uses = pCodes_identifier[ident].Uses, Playtime = pCodes_identifier[ident].Playtime, UsedCodes = pCodes_identifier[ident].UsedCodes, UsedFCodes = pCodes_identifier[ident].UsedFCodes, RewardsToClaim = pCodes_identifier[ident].RewardsToClaim})

                if Webhooks.ClaimServerCode ~= "" then
                    local dat = {
                        {
                            ["name"] = "**"..AURA.Lang.PlayerInfo..":**",
                            ["value"] = AURA.Lang.Name..": **"..GetPlayerName(src).."**\n"..AURA.Lang.Id..": **"..src.."**\n"..AURA.Lang.Identifier..": **"..ident.."**",
                            ["inline"] = false
                        },
                        {
                            ["name"] = "**"..AURA.Lang.CodeInfo..":**",
                            ["value"] = AURA.Lang.Code..": **"..daCode.."**",
                            ["inline"] = false
                        },
                        {
                            ["name"] = "**"..AURA.Lang.RewardInfo..":**",
                            ["value"] = AURA.Lang.CodeCreator9..": **$"..cCodes[daCode].RewardData.Money.."**\n"..AURA.Lang.CodeCreator5..": **"..itemstring.."**",
                            ["inline"] = false
                        }
                    }
                    sendToDiscord(dat, 9498256, AURA.Lang.PlayerClaimedServerCode, Webhooks.ClaimServerCode)
                end
            else
                TriggerClientEvent("AURA:Client:Notification", src, AURA.Lang.AlreadyClaimed, "error")
            end
        else
            TriggerClientEvent("AURA:Client:Notification", src, AURA.Lang.InvalidCode, "error")
        end
    else
        TriggerClientEvent("AURA:Client:Notification", src, AURA.Lang.UnableToProccessCode, "error")
    end
end)

RegisterServerEvent("AURA:Server:OpenCodeCreator")
AddEventHandler("AURA:Server:OpenCodeCreator", function(daCode)
    local src = source
    local ident = GetPlayerIdentifierByType(src, AURA.Identifier)

    if ident and ident ~= "nil" then
        local can = false
        for i=1, #CodeCreators do
            if ident == CodeCreators[i] then
                can = true
            end
        end

        if can then
            TriggerClientEvent("AURA:Client:OpenCodeCreator", src)
        else
            TriggerClientEvent("AURA:Client:Notification", src, AURA.Lang.NoPerms, "error")
        end
    else
        TriggerClientEvent("AURA:Client:Notification", src, AURA.Lang.UnableToOpen, "error")
    end
end)

RegisterServerEvent("AURA:Server:CreateTheCode")
AddEventHandler("AURA:Server:CreateTheCode", function(codeData)
    local src = source
    local ident = GetPlayerIdentifierByType(src, AURA.Identifier)

    if ident and ident ~= "nil" then
        local can = false
        for i=1, #CodeCreators do
            if ident == CodeCreators[i] then
                can = true
            end
        end

        if can then
            local itemstring = "None"
            for k,v in pairs(codeData.RewardData.Items) do
                if itemstring ~= "None" then
                    itemstring = itemstring..", "..v.."x "..k
                else
                    itemstring = v.."x "..k
                end
            end
            if codeData.Code and (codeData.RewardData.Money >= 0 or itemstring ~= "None") and codeData.Expires > 0 then
                if not cCodes[codeData.Code] then
                    cCodes[codeData.Code] = {RewardData = codeData.RewardData}
                    MySQL.insert('INSERT INTO aura_createdcodes (code, reward_data, date_creation, date_deletion) VALUES (?, ?, NOW(), DATE_ADD(NOW(), INTERVAL ? HOUR))',
                        {
                            codeData.Code,
                            json.encode(codeData.RewardData),
                            codeData.Expires
                        }
                    )
                    TriggerClientEvent("AURA:Client:Notification", src, AURA.Lang.CodeCreated, "success")
                    if Webhooks.CreateCode ~= "" then
                        local dat = {
                            {
                                ["name"] = "**"..AURA.Lang.PlayerInfo..":**",
                                ["value"] = AURA.Lang.Name..": **"..GetPlayerName(src).."**\n"..AURA.Lang.Id..": **"..src.."**\n"..AURA.Lang.Identifier..": **"..ident.."**",
                                ["inline"] = false
                            },
                            {
                                ["name"] = "**"..AURA.Lang.CodeInfo..":**",
                                ["value"] = AURA.Lang.Code..": **"..codeData.Code.."**\n"..AURA.Lang.CodeCreator9..": **$"..codeData.RewardData.Money.."**\n"..AURA.Lang.CodeCreator5..": **"..itemstring.."**",
                                ["inline"] = false
                            }
                        }
                        sendToDiscord(dat, 16753920, AURA.Lang.PlayerCreatedCode, Webhooks.CreateCode)
                    end
                else
                    TriggerClientEvent("AURA:Client:Notification", src, AURA.Lang.DuplicateCode, "error")
                end
            else
                TriggerClientEvent("AURA:Client:Notification", src, AURA.Lang.MissingInputs, "error")
            end
        else
            TriggerClientEvent("AURA:Client:Notification", src, AURA.Lang.NoPerms, "error")
        end
    else
        TriggerClientEvent("AURA:Client:Notification", src, AURA.Lang.UnableToCreateCode, "error")
    end
end)


AddEventHandler('playerDropped', function(reason) 
    local src = nil
    src = source
    local ident = nil
    ident = GetPlayerIdentifierByType(src, AURA.Identifier)
    if ident then
        pIdentToId[ident] = nil
    else
        for k,v in pairs(pIdentToId) do
            if v == src then
                pIdentToId[k] = nil
            end
        end
    end
end)

local letterTable = {
    [1] = "A",
    [2] = "B",
    [3] = "C",
    [4] = "D",
    [5] = "E",
    [6] = "F",
    [7] = "G",
    [8] = "H",
    [9] = "I",
    [10] = "J",
    [11] = "K",
    [12] = "L",
    [13] = "M",
    [14] = "N",
    [15] = "O",
    [16] = "P",
    [17] = "Q",
    [18] = "R",
    [19] = "S",
    [20] = "T",
    [21] = "U",
    [22] = "V",
    [23] = "W",
    [24] = "X",
    [25] = "Y",
    [26] = "Z"
}
function GetNewCode()
    local newCode = nil
    repeat
        local tempCode = ""
        for i=1, AURA.FriendCodeLength do
            local lorn = 0
            lorn = math.random(1, 2)
            if lorn == 1 then
                tempCode = tempCode..(math.random(1,9))
            else
                tempCode = tempCode..letterTable[math.random(1,26)]
            end
        end

        if not pCodes_code[tempCode] then
            newCode = tempCode
        end
        Wait(500)
    until newCode
    return newCode
end



function sendToDiscord(field, colour, titles, webhook)
    local embed = {
          {
              ["fields"] = field,
              ["color"] = colour,
              ["title"] = titles,
              ["description"] = message,
              ["footer"] = {
                  ["text"] = "Server Timestamp: "..os.date("%x %X %p"),
              },
              ["thumbnail"] = {
                  ["url"] = "https://cdn.discordapp.com/attachments/1228999562103099503/1303116337702244503/discord.jpg?ex=672de0e9&is=672c8f69&hm=9cbcae8638468a4d785b7880195fa3a93814e7b2a09d74d570ffb423ef091652&",
              },
          }
    }
    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({username = "AURA Codes Script", embeds = embed, avatar_url = "https://cdn.discordapp.com/attachments/1228999562103099503/1303116337702244503/discord.jpg?ex=672de0e9&is=672c8f69&hm=9cbcae8638468a4d785b7880195fa3a93814e7b2a09d74d570ffb423ef091652&"}), { ['Content-Type'] = 'application/json' })
end