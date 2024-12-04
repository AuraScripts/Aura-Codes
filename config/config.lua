AURA = {}

---------------------------------------------------------------------------------
-------------------------------Important Configurations---------------------------
---------------------------------------------------------------------------------
AURA.Framework = "esx" --"qb-core" or "esx"
AURA.NotificationSystem = "framework" -- ['mythic_old', 'mythic_new', 'tnotify', 'okoknotify', 'print', 'framework', 'none'] --Notify you want to use

AURA.FriendCodeLength = 6 --Friend code length (Max is 12)
AURA.ClaimFriendCodePlaytimeMax = 120 --This is the amount of time a player has to claim a friend's code before being locked out (in minutes)

AURA.CheckCodesInterval = 5 --How often no longer valid codes are checked (in minutes)
AURA.UpdatePlayersInDatabase = 5 --How often is the database updated with player playing time (minutes)

---------------------------------------------------------------------------------
-------------------------------Identifier Configurations--------------------
---------------------------------------------------------------------------------
AURA.Identifier = "license" --Can be one of the following values: ["license", "steam", "discord", "fivem"]

--ADD CREATOR CODES IN SRC\SERVER\SERVER.LUA FILE

---------------------------------------------------------------------------------
-------------------------------Reward Configurations----------------------------
---------------------------------------------------------------------------------
AURA.DefaultReward = { --Default rewards for each friend code redeem
    Claimer = { --The person who redeems the code
        Items = { --Any items as reward after redeeming the code
            --Example: ["item_name"] = 0 --Quantity
        },
        Money = 500 --The amount of money redeemer will receive
    },
    CodeOwner = { --Code Owner
        Items = { --Any items as reward after someone redeems his code
            --Example: ["item_name"] = 0 --Quantity
        },
        Money = 1500 --The amount of money code owner will receive
    }
}

AURA.SpecialRewardMilestones = { --Each time the owner of the code reaches a certain amount of code usage, he can receive a special reward
--[[
    Example:

    ["usage_number"] = { --Number of his code usage (has to be number, e.g., "5")
        Items = {--Items that code owner gets when he reaches milestone
            --Example: ["item_name"] = 0 --Quantity
        },
        Money = 0 --The amount of money code owner will receive, when he reaches milestone
    }
]]
    ["5"] = {
        Items = {

        },
        Money = 10000
    },
    ["10"] = {
        Items = {

        },
        Money = 20000
    },
}
