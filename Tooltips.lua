--[[ Determines if we give a crap at all about the instance for looting. --]]
function DH_DoWeCareHere()
    local doWeCare = false
    local instance = GetRealZoneText()
    local instancesWeCareAbout = {
        "Molten Core",
        "Blackwing Lair",
        "Onyxia's Lair",
        "Zul'Gurub",
        "Ruins of Ahn'Qiraj",
        "Temple of Ahn'Qiraj",
        "Naxxramas",
        'Ragefire Chasm' -- testing
    };

    for k,v in pairs(instancesWeCareAbout) do
       if (v == instance) then
        doWeCare = true
       end
    end

    return doWeCare
end

--[[ Booleans to see if we show the tip --]]
local DH_DEBUG = false

--[[ Class Colours --]]
local DH_DRUID_COLOUR = '|cFFFF7D0A'
local DH_HUNTER_COLOUR = '|cFFA9D271'
local DH_MAGE_COLOUR = '|cFF40C7EB'
local DH_PRIEST_COLOUR = '|cFFFFFFFF'
local DH_ROGUE_COLOUR = '|cFFFFF569'
local DH_SHAMAN_COLOUR = '|cFFF58CBA'
local DH_WARLOCK_COLOUR = '|cFF8787ED'
local DH_WARRIOR_COLOUR = '|cFFC79C6E'

--[[ Header Colours ]]
local DH_PURPLE = '|cFFB242A3'
local DH_RED = '|cFFEF163F'
local DH_BLUE = '|cFF83AEC6'

--[[ This function handles the loot event display, adding data to the items tooltip. --]] 
function DH_OnToolTipSetItem(self)
    --[[ This checks if we're in raid, have master looting on, and that we care about the instance. --]]
    
    if (DH_DEBUG or (IsInRaid() and GetLootMethod() == "master" and DH_DoWeCareHere())) then
        local name, link = self:GetItem()
        if link then 
            local linkSplit = DH_Split(link, ':')
            local itemId = linkSplit[2];

            if DH_LOOT_LIST[itemId] then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine(DH_RED .. "DH LOOT PRIORITY", 1, 1, 1, false)

                local bisList = {}
                local nearBisList = {}
                
                -- organise the array data into proper groups
                for k,v in pairs(DH_LOOT_LIST[itemId]) do
                    if v == 1 then 
                        local role = DH_MapRole(k)
                        if bisList[role] == nil then
                            bisList[role] = {}
                        end 
                        table.insert(bisList[role], DH_MapClass(k))
                    elseif v == 2 then 
                        local role = DH_MapRole(k)
                        if nearBisList[role] == nil then
                            nearBisList[role] = {}
                        end
                        table.insert(nearBisList[role], DH_MapClass(k))
                    else 
                        -- do nothing
                    end
                end

                -- work out if we're displaying the sections, only if table not empty
                local next = next
                local shownSomething = false
                if next(bisList) ~= nil then
                    displayRoles("BIS", bisList)
                    shownSomething = true
                end
                if next(nearBisList) ~= nil then
                    displayRoles("NEAR BIS", nearBisList)
                    shownSomething = true
                end

                if shownSomething then 
                    -- nada
                else 
                    GameTooltip:AddLine(DH_BLUE .. "MS > OS", 1, 1, 1, false)
                end
            end
        end
    end
end

--[[ Splits the item link string to get just the item ID --]]
function DH_Split(input, seperator)
    if seperator == nil then
        seperator = "%s"
    end

    local t = {}

    for str in string.gmatch(input, "([^"..seperator.."]+)") do
        table.insert(t, str)
    end

    return t
end

--[[ Displays the role data for each table. --]]
function displayRoles(title, data) 
    GameTooltip:AddLine(DH_PURPLE .. title)
    if data['HEALS'] ~= nil then
        GameTooltip:AddLine(DH_BLUE .. 'HEALS »  ' .. table.concat(data['HEALS'], ' '), 1, 1, 1, false)
    end
    if data['MDPS'] ~= nil then
        GameTooltip:AddLine(DH_BLUE .. 'MDPS »  ' .. table.concat(data['MDPS'], ' '), 1, 1, 1, false)
    end
    if data['RDPS'] ~= nil then
        GameTooltip:AddLine(DH_BLUE .. 'RDPS »  ' .. table.concat(data['RDPS'], ' '), 1, 1, 1, false)
    end
    if data['TANK'] ~= nil then
        GameTooltip:AddLine(DH_BLUE .. 'TANK »  ' .. table.concat(data['TANK'], ' '), 1, 1, 1, false)
    end
end

--[[ Maps an array key position to a Role from our data --]]
function DH_MapRole(type)
    local types = {
        "HEALS",
        "MDPS",
        "RDPS",
        "TANK",
        "RDPS",
        "RDPS",
        "HEALS",
        "RDPS",
        "MDPS",
        "HEALS",
        "MDPS",
        "RDPS",
        "RDPS",
        "MDPS",
        "TANK"
    }

    return types[type];
end

--[[ Maps an array key position to a Class from our data --]]
function DH_MapClass(type) 
    local types = {
        DH_DRUID_COLOUR .. "Druid",
        DH_DRUID_COLOUR .. "Druid",
        DH_DRUID_COLOUR .. "Druid",
        DH_DRUID_COLOUR .. "Druid",
        DH_HUNTER_COLOUR .. "Hunter",
        DH_MAGE_COLOUR .. "Mage",
        DH_PRIEST_COLOUR .. "Priest",
        DH_PRIEST_COLOUR .. "Priest",
        DH_ROGUE_COLOUR .. "Rogue",
        DH_SHAMAN_COLOUR .. "Shaman",
        DH_SHAMAN_COLOUR .. "Shaman",
        DH_SHAMAN_COLOUR .. "Shaman",
        DH_WARLOCK_COLOUR .. "Warlock",
        DH_WARRIOR_COLOUR .. "Warrior",
        DH_WARRIOR_COLOUR .. "Warrior"
    }

    return types[type];
end


--[[ Hooks the function into the tooltip renderer --]]
GameTooltip:HookScript("OnTooltipSetItem", DH_OnToolTipSetItem)