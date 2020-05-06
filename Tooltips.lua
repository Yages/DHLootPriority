--[[ Booleans to see if we show the tip --]]
local DH_SHOW_TIP = IsInRaid() and GetLootMethod() == "master" and DoWeCareHere()
local DH_DEBUG = true

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
    
    if (DH_DEBUG or DH_SHOW_TIP) then
        local name, link = self:GetItem()
        if link then 
            local linkSplit = DH_Split(link, ':')
            local itemId = linkSplit[2];

            if DH_LOOT_LIST[itemId] then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine(DH_RED .. "DIVINE HERESY LOOT PRIORITY", 1, 1, 1, false)

                local mainSpec = {}
                local offSpec = {}
                local frSpec = {}
                local lootCouncil = {}
                
                -- organise the array data into proper groups
                for k,v in pairs(DH_LOOT_LIST[itemId]) do
                    if v == 1 then 
                        local role = DH_MapRole(k)
                        if mainSpec[role] == nil then
                            mainSpec[role] = {}
                        end 
                        table.insert(mainSpec[role], DH_MapClass(k))
                    elseif v == 2 then 
                        local role = DH_MapRole(k)
                        if offSpec[role] == nil then
                            offSpec[role] = {}
                        end
                        table.insert(offSpec[role], DH_MapClass(k))
                    elseif v == 3 then  
                        local role = DH_MapRole(k)
                        if frSpec[role] == nil then
                            frSpec[role] = {}
                        end
                        table.insert(frSpec[role], DH_MapClass(k))
                    elseif v == 4 then
                        local role = DH_MapRole(k)
                        if lootCouncil[role] == nil then
                            lootCouncil[role] = {}
                        end
                        table.insert(lootCouncil[role], DH_MapClass(k))
                    else 
                        -- do nothing
                    end
                end

                -- work out if we're displaying the sections, only if table not empty
                local next = next
                local shownSomething = false
                if next(mainSpec) ~= nil then
                    displayRoles("MAIN SPEC", mainSpec)
                    shownSomething = true
                end
                if next(offSpec) ~= nil then
                    displayRoles("OFF SPEC", offSpec)
                    shownSomething = true
                end
                if next(frSpec) ~= nil then
                    displayRoles("FIRE RESISTANCE", frSpec)
                    shownSomething = true
                end
                if next(lootCouncil) ~= nil then
                    displayRoles("LOOT COUNCIL", lootCouncil)
                    shownSomething = true
                end

                if shownSomething then 
                    -- nada
                else 
                    GameTooltip:AddLine(DH_BLUE .. "MAIN SPEC > OFF SPEC", 1, 1, 1, false)
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
    if data['Healer'] ~= nil then
        GameTooltip:AddLine(DH_BLUE .. 'HEALER »  ' .. table.concat(data['Healer'], ' '), 1, 1, 1, false)
    end
    if data['Melee DPS'] ~= nil then
        GameTooltip:AddLine(DH_BLUE .. 'MELEE HAM »  ' .. table.concat(data['Melee DPS'], ' '), 1, 1, 1, false)
    end
    if data['Ranged DPS'] ~= nil then
        GameTooltip:AddLine(DH_BLUE .. 'RANGED HAM »  ' .. table.concat(data['Ranged DPS'], ' '), 1, 1, 1, false)
    end
    if data['Tank'] ~= nil then
        GameTooltip:AddLine(DH_BLUE .. 'TANK »  ' .. table.concat(data['Tank'], ' '), 1, 1, 1, false)
    end
end

--[[ Maps an array key position to a Role from our data --]]
function DH_MapRole(type)
    local types = {
        "Healer",
        "Melee DPS",
        "Ranged DPS",
        "Tank",
        "Ranged DPS",
        "Ranged DPS",
        "Healer",
        "Ranged DPS",
        "Melee DPS",
        "Healer",
        "Melee DPS",
        "Ranged DPS",
        "Ranged DPS",
        "Melee DPS",
        "Tank"
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

--[[ Determines if we give a crap at all about the instance for looting. --]]
function DH_DoWeCareHere()
    local doWeCare = false;
    local instance = GetRealZoneText();
    local instancesWeCareAbout = {
        "Molten Core",
        "Blackwing Lair",
        "Onyxia's Lair",
        "Zul'Gurub"
    };

    for k,v in instancesWeCareAbout do
       if (v == instance) then
        doWeCare = true;
       end
    end
end

--[[ Hooks the function into the tooltip renderer --]]
GameTooltip:HookScript("OnTooltipSetItem", DH_OnToolTipSetItem)