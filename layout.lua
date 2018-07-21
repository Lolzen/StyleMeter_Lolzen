--// Layout //--
-- Reference layout: basic layout

local Lolzen = CreateFrame("Frame", nil, UIParent)
Lolzen:SetSize(350, 100)
Lolzen:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -10, 10) --CHANGE LATER

Lolzen:EnableMouse(true)
Lolzen:SetMovable(true)
Lolzen:SetUserPlaced(true)
StyleMeter.LayoutFrame = Lolzen

-- Script for moving the frame and resetting data
local registerClicks = function(self, button)
	if IsAltKeyDown() then
		Lolzen:ClearAllPoints()
		Lolzen:StartMoving()
	end
	if IsShiftKeyDown() then
		if button == "LeftButton" then
			StyleMeter.resetData()
			StyleMeter.UpdateLayout()
			print("|cff5599ffStyleMeter:|r Data has been reset.")
		end
	end
	-- Reporting data from context menu
	if button == "RightButton" then
		-- Disable report spells used to function when not clicking statusbars
		if self:GetName() ~= nil then
			ToggleDropDownMenu(1, nil, StyleMeter.Lolzen_DropDownMenu, self:GetName(), 0, 0)
			StyleMeter.clicked = tonumber(string.match(self:GetName(), "%d"))
		else
			ToggleDropDownMenu(1, nil, StyleMeter.Lolzen_DropDownMenu, StyleMeter.LayoutFrame, 0, 0)
			StyleMeter.clicked = 0
		end
	end
end
Lolzen:SetScript("OnMouseDown", registerClicks)

Lolzen:SetScript("OnMouseUp", function()
	Lolzen:StopMovingOrSizing()
end)

-- Script for fake-scrolling
local viewrange = 0
Lolzen:SetScript("OnMouseWheel", function(self, direction)
	if IsShiftKeyDown() then
		if direction == 1 then -- "up"
		--	if viewrange > 0 then
				viewrange = 0
		--	end
		elseif direction == -1 then -- "down"
		--	if viewrange +5 < #StyleMeter.DB.rank then
			if #StyleMeter.DB.rank > 6 then
				viewrange = #StyleMeter.DB.rank - 5
			end
		end
	else
		if direction == 1 then -- "up"
			if viewrange > 0 then
				viewrange = viewrange - 1
			end
		elseif direction == -1 then -- "down"
			if viewrange +5 < #StyleMeter.DB.rank then
				viewrange = viewrange + 1
			end
		end
	end
	StyleMeter.UpdateLayout()
end)

-- Background
local bg = Lolzen:CreateTexture("Background")
bg:SetTexture("Interface\\Buttons\\WHITE8x8")
bg:SetVertexColor(0, 0, 0, 0.5)
bg:SetAllPoints(Lolzen)

-- Border
local border = CreateFrame("Frame", nil, Lolzen)
border:SetBackdrop({
	edgeFile = "Interface\\AddOns\\StyleMeter_Lolzen\\Textures\\border", edgeSize = 8,
	insets = {left = 4, right = 4, top = 4, bottom = 4},
})
border:SetPoint("TOPLEFT", bg, -2, 1)
border:SetPoint("BOTTOMRIGHT", bg, 2, -1)
border:SetBackdropBorderColor(0.2, 0.2, 0.2)

-- Color table for spellSchool colors
-- all colors, except physical taken from https://wow.gamepedia.com/COMBAT_LOG_EVENT
-- physical uses plain white instead of yellow
-- colors mixed with http://www.colorhexa.com/
-- and converted to rgb using "rgb to hex" in google
local spellSchoolColors = {
	[1] = {r=255, g=255, b=255}, --Physical #FFFFFF, rgb(255, 255, 255)
	[2] = {r=255, g=230, b=128}, --Holy #FFE680, rgb(255, 230, 128)
	[4] = {r=255, g=128, b=0}, --Fire #FF8000, rgb(255, 128, 0)
	[8] = {r=77, g=255, b=77}, --Nature #4DFF4D, rgb(77, 255, 77)
	[16] = {r=128, g=255, b=255}, --Frost #80FFFF, rgb(128, 255, 255)
	[32] = {r=128, g=128, b=255}, --Shadow #8080FF, rgb(128, 128, 255)
	[64] = {r=255, g=128, b=255}, --Arcane #FF80FF, rgb(255, 128, 255)
	-- to be done; custom colors for double schools
	[3] = {r=255, g=243, b=192}, --Holy + Physical #FFF3C0, rgb(255, 243, 192)
	[5] = {r=255, g=192, b=128}, --Fire + Physical #FFC080, rgb(255, 192, 128)
	[6] = {r=255, g=179, b=64}, --Fire + Holy #FFB340, rgb(255, 179, 64)
	[9] = {r=166, g=255, b=166}, --Nature + Physical #A6FFA6, rgb(166, 255, 166)
	[10] = {r=166, g=243, b=103}, --Nature + Holy #A6F367, rgb(166, 243, 103)
	[12] = {r=166, g=192, b=39}, --Nature + Fire #A6C027, rgb(166, 192, 39)
	[17] = {r=192, g=255, b=255}, --Frost + Physical #C0FFFF, rgb(192, 255, 255)
	[18] = {r=192, g=243, b=192}, --Frost + Holy #C0F3C0, rgb(192, 243, 192)
	[20] = {r=192, g=192, b=128}, --Frost + Fire #C0C080, rgb(192, 192, 128)
	[24] = {r=103, g=255, b=166}, --Frost + Nature #67FFA6, rgb(103, 255, 166)
	[33] = {r=192, g=192, b=255}, --Shadow + Physical #C0C0FF, rgb(192, 192, 255)
	[34] = {r=192, g=179, b=192}, --Shadow + Holy #C0B3C0, rgb(192, 179, 192)
	[36] = {r=192, g=128, b=128}, --Shadow + Fire #C08080, rgb(192, 128, 128)
	[40] = {r=103, g=192, b=166}, --Shadow + Nature #67C0A6, rgb(103, 192, 166)
	[48] = {r=128, g=192, b=255}, --Shadow + Frost #80C0FF, rgb(128, 192, 255)
	[65] = {r=255, g=192, b=255}, --Arcane + Physical #FFC0FF,rgb(255, 192, 255)
	[66] = {r=255, g=179, b=192}, --Arcane + Holy #FFB3C0, rgb(255, 179, 192)
	[68] = {r=255, g=128, b=128}, --Arcane + Fire #FF8080, rgb(255, 128, 128)
	[72] = {r=166, g=192, b=166}, --Arcane + Nature #A6C0A6, rgb(166, 192, 166)
	[80] = {r=192, g=192, b=255}, --Arcane + Frost #C0C0FF, rgb(192, 192, 255)
	[96] = {r=192, g=128, b=255}, --Arcane + Shadow #C080FF, rgb(192, 128, 255)
	-- tripple or more schools
	[28] = {r=153, g=213, b=111}, --Frost + Nature + Fire #99D56F, rgb(153, 213, 111)
	[124] = {r=169, g=179, b=169}, --Arcane + Shadow + Frost + Nature + Fire #A9B3A8, rgb(169, 179, 168)
	[126] = {r=183, g=187, b=162}, --Arcane + Shadow + Frost + Nature + Fire + Holy #B7BBA2, rgb(183, 187, 162)
	[127] = {r=193, g=197, b=175}, --Arcane + Shadow + Frost + Nature + Fire + Holy + Physical #C1C5AF, rgb(193, 197, 175)
}

-- Create the Statusbars
local sb = {}
for i=1, 5, 1 do
	-- Create the StatusBars
	if not sb[i] then
		sb[i] = CreateFrame("StatusBar", "StatusBar"..i, Lolzen)
		sb[i]:SetHeight(15)
		sb[i]:SetWidth(Lolzen:GetWidth() -12)
		sb[i]:SetStatusBarTexture("Interface\\AddOns\\StyleMeter_Lolzen\\Textures\\statusbar")
		if i == 1 then
			sb[i]:SetPoint("TOPLEFT", Lolzen, 6, -7)
		elseif i >= 1 and i <= 5 then
			sb[i]:SetPoint("TOP", sb[i-1], "BOTTOM", 0, -3)
		end
	end

	-- Border
	if not sb[i].border then
		sb[i].border = CreateFrame("Frame", nil, sb[i])
		sb[i].border:SetBackdrop({
			edgeFile = "Interface\\AddOns\\StyleMeter_Lolzen\\Textures\\border", edgeSize = 8,
			insets = {left = 4, right = 4, top = 4, bottom = 4},
		})
		sb[i].border:SetPoint("TOPLEFT", sb[i], -2, 2)
		sb[i].border:SetPoint("BOTTOMRIGHT", sb[i], 2, -2)
		sb[i].border:SetBackdropBorderColor(0.2, 0.2, 0.2)
	end

	-- StatusBars background
	if not sb[i].bg then
		sb[i].bg = sb[i]:CreateTexture(nil, "BACKGROUND")
		sb[i].bg:SetAllPoints(sb[i])
		sb[i].bg:SetTexture("Interface\\AddOns\\StyleMeter_Lolzen\\Textures\\statusbar")
		sb[i].bg:SetVertexColor(0.3, 0.3, 0.3)
	end

	-- Create the FontStrings
	if not sb[i].string1 then
		-- #. Name
		sb[i].string1 = sb[i]:CreateFontString(nil, "OVERLAY")
		sb[i].string1:SetFont("Interface\\AddOns\\StyleMeter_Lolzen\\fonts\\DroidSans.ttf", 12, "OUTLINE")
		sb[i].string1:SetPoint("TOPLEFT", sb[i], "TOPLEFT", 2, -0.5)
	end
	if not sb[i].string2 then
		-- modevalue (modevalue%)
		sb[i].string2 = sb[i]:CreateFontString(nil, "OVERLAY")
		sb[i].string2:SetFont("Interface\\AddOns\\StyleMeter_Lolzen\\fonts\\DroidSans.ttf", 12, "OUTLINE")
		sb[i].string2:SetPoint("TOPRIGHT", sb[i], "TOPRIGHT", -2, -0.5)
	end

	sb[i]:SetScript("OnEnter", function(self)
		local curModeVal, curModeTotal = StyleMeter.getModeData(viewrange + i)
		local curModeCombatTime, curModeSpells = StyleMeter.getTimeAndSpells(viewrange + i)
		if curModeVal and curModeVal > 0 then
			local sortedSpells = {}
			GameTooltip:SetOwner(sb[i], "ANCHOR_TOPLEFT", 0, 0)
			GameTooltip:AddDoubleLine(StyleMeter.DB.rank[viewrange + i], StyleMeter.DB.players[StyleMeter.DB.rank[viewrange + i]].class, 1, 1, 1, 1, 1, 1)
			GameTooltip:AddDoubleLine("Total", curModeVal.." ("..(curModeVal / curModeTotal * 100).."%)" or "", 85/255, 153/255, 255/255, 1, 1, 1)
			if not StyleMeter.module[StyleMeter.activeModule].limitdata == true then
				GameTooltip:AddDoubleLine(StyleMeter.activeModule.." per Second:", StyleMeter.siValue(curModeVal / curModeCombatTime), 85/255, 153/255, 255/255, 1, 1, 1)
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine("Spells/Abilities used", 85/255, 153/255, 255/255)
				for k, v in pairs(curModeSpells) do
					-- Instert spellnames to sortedSpells
					if not sortedSpells[k] then
						tinsert(sortedSpells, k)
					end
					-- Sort the spells
					sort(sortedSpells, function(a, b) return curModeSpells[a].amount > curModeSpells[b].amount end)
				end
				for _, v in pairs(sortedSpells) do
					GameTooltip:AddDoubleLine(format("|cff%02x%02x%02x%s|r", spellSchoolColors[curModeSpells[v].spellSchool].r, spellSchoolColors[curModeSpells[v].spellSchool].g, spellSchoolColors[curModeSpells[v].spellSchool].b, v), curModeSpells[v].amount..format(" (%.0f%%)", curModeSpells[v].amount / curModeVal * 100), 1, 1, 1, 1, 1, 1)
				end
			end
			GameTooltip:Show()
		end
	end)

	sb[i]:SetScript("OnLeave", function() 
		GameTooltip:Hide() 
	end)

	-- Register sb[i] for click events
	sb[i]:SetScript("OnMouseDown", registerClicks)
	sb[i]:SetScript("OnMouseUp", function()
		Lolzen:StopMovingOrSizing()
	end)
end

--//#Layout Functions#//--
-- hook into switchModule to colorize the statusbars
hooksecurefunc(StyleMeter, "switchModule", function(self)
	for i=1, 5, 1 do
		if StyleMeter.activeModule == "Damage" or StyleMeter.activeModule == "Damage Taken" then
			sb[i]:SetStatusBarColor(0.8, 0, 0)
		elseif StyleMeter.activeModule == "Heal" or StyleMeter.activeModule == "OverHeal" then
			sb[i]:SetStatusBarColor(0, 0.8, 0)
		elseif StyleMeter.activeModule == "Absorb" then
			sb[i]:SetStatusBarColor(0.8, 0.8, 0)
		elseif StyleMeter.activeModule == "Deaths" then
			sb[i]:SetStatusBarColor(0.2, 0.2, 0.2)
		else
			sb[i]:SetStatusBarColor(0.7, 0.7, 0.7)
		end
	end 
end)

function StyleMeter.UpdateLayout()
	for i=1, 5, 1 do
		local curModeVal, curModeTotal = StyleMeter.getModeData(viewrange + i)
		local curModeCombatTime, curModeSpells = StyleMeter.getTimeAndSpells(viewrange + i)
		if curModeVal and curModeVal > 0 then
			if sb[i]:GetAlpha() == 0 then
				sb[i]:SetAlpha(1)
				sb[i].border:Show()
				sb[i].bg:Show()
			end
			sb[i]:SetMinMaxValues(0, StyleMeter.getModeData(1))
			sb[i]:SetValue(curModeVal)
			-- Strings
			if StyleMeter.module[StyleMeter.activeModule].limitdata == true then
				sb[i].string2:SetFormattedText("%s", StyleMeter.siValue(curModeVal))
			else
				sb[i].string2:SetFormattedText("%s [%s] (%.0f%%)", StyleMeter.siValue(curModeVal), StyleMeter.siValue(curModeVal / curModeCombatTime).." "..string.sub(StyleMeter.activeModule, 1, 1).."ps", curModeVal / curModeTotal * 100)
			end
			sb[i].string1:SetFormattedText("%d.  |cff%02x%02x%02x%s|r", viewrange + i, StyleMeter.DB.players[StyleMeter.DB.rank[viewrange + i]].classcolor.r*255, StyleMeter.DB.players[StyleMeter.DB.rank[viewrange + i]].classcolor.g*255, StyleMeter.DB.players[StyleMeter.DB.rank[viewrange + i]].classcolor.b*255, StyleMeter.DB.rank[viewrange + i])
		else
			if sb[i]:GetAlpha() == 1 then
				sb[i]:SetAlpha(0)
				sb[i].string1:SetText(nil)
				sb[i].string2:SetText(nil)
				sb[i].border:Hide()
				sb[i].bg:Hide()
			end
		end
	end

	-- Sort Statusbars
	StyleMeter.sortRank()
end