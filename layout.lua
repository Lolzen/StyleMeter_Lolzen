--// Layout (Tabbed) //--
-- Sample layout: basic tabbed layout

local siValue = function(val)
	if val >= 1e6 then
		return ('%.1f'):format(val / 1e6):gsub('%.', 'm')
	elseif val >= 1e4 then
		return ("%.1f"):format(val / 1e3):gsub('%.', 'k')
	else
		return val
	end
end

local Lolzen = CreateFrame("Frame")
Lolzen:SetSize(250, 80)
Lolzen:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -90, 16) --CHANGE LATER

Lolzen:EnableMouse(true)
Lolzen:SetMovable(true)
Lolzen:SetUserPlaced(true)

-- Script for moving the frame and resetting data
Lolzen:SetScript("OnMouseDown", function(self, button)
	if IsAltKeyDown() then
		Lolzen:ClearAllPoints()
		Lolzen:StartMoving()
	end
	if IsShiftKeyDown() then
		if button == "LeftButton" then
			StyleMeter.resetData()
			StyleMeter.UpdateLayout()
			print("|cff5599ffStyleMeter:|r Data has been resetted.")
		end
	end
end)

Lolzen:SetScript("OnMouseUp", function()
	Lolzen:StopMovingOrSizing()
end)

-- Script for fake-scrolling
local viewrange = 1
Lolzen:SetScript("OnMouseWheel", function(self, direction)
	if direction == 1 then -- "up"
		if viewrange > 1 then
			viewrange = viewrange - 1
		end
	elseif direction == -1 then -- "down"
		if viewrange < #StyleMeter.DB.rank then
			viewrange = viewrange + 1
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

-- Copy Modulenames into modulenames table, ordering them in their set priority
local modulenames = {}
for k, v in pairs(StyleMeter.module) do
	tinsert(modulenames, v.priority, k)
end

-- Create some clickable tabs
local tabs = {}
for k, v in pairs(modulenames) do
	-- Create the Tabs
	if not tabs[k] then
		tabs[k] = CreateFrame("Frame", v.."-Tab", Lolzen)
		if k == 1 then
			tabs[k]:SetPoint("TOPRIGHT", Lolzen, "TOPLEFT", -4, -1)
		else
			tabs[k]:SetPoint("TOP", tabs[k-1], "BOTTOM", 0, -3)
		end
		tabs[k]:SetSize(80, 12)
	end
	-- Backgrond
	if not tabs[k].bg then
		tabs[k].bg = tabs[k]:CreateTexture("Background")
		tabs[k].bg:SetTexture("Interface\\Buttons\\WHITE8x8")
		tabs[k].bg:SetAllPoints(tabs[k])
	end
	-- Labels
	if not tabs[k].label then
		tabs[k].label = tabs[k]:CreateFontString(nil, "OVERLAY")
		tabs[k].label:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
		tabs[k].label:SetPoint("CENTER", tabs[k], "CENTER", 0, 0)
		tabs[k].label:SetFormattedText("%s", v)
	end
	-- Border
	if not tabs[k].border then
		tabs[k].border = CreateFrame("Frame", nil, Lolzen)
		tabs[k].border:SetBackdrop({
			edgeFile = "Interface\\AddOns\\StyleMeter_Lolzen\\Textures\\border", edgeSize = 8,
			insets = {left = 4, right = 4, top = 4, bottom = 4},
		})
		tabs[k].border:SetBackdropBorderColor(0.2, 0.2, 0.2)
		tabs[k].border:SetPoint("TOPLEFT", tabs[k], -2, 1)
		tabs[k].border:SetPoint("BOTTOMRIGHT", tabs[k], 2, -1)
		tabs[k].border:SetAlpha(1)
	end
	-- clickscript for switching
	tabs[k]:SetScript("OnMouseDown", function(self, button)
		switchMode(v)
		StyleMeter.UpdateLayout()
	end)
end

-- Create the Statusbars
local sb = {}
for i=1, 5, 1 do
	-- Create the StatusBars
	if not sb[i] then
		sb[i] = CreateFrame("StatusBar", "StatusBar"..i, Lolzen)
		sb[i]:SetHeight(13)
		sb[i]:SetWidth(Lolzen:GetWidth() -8)
		sb[i]:SetStatusBarTexture("Interface\\AddOns\\StyleMeter_Lolzen\\Textures\\statusbar")
		if i == 1 then
			sb[i]:SetPoint("TOPLEFT", Lolzen, 4, -4)
		elseif i >= 1 and i <= 5 then
			sb[i]:SetPoint("TOP", sb[i-1], "BOTTOM", 0, -2)
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
		sb[i].string1:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
		sb[i].string1:SetPoint("TOPLEFT", sb[i], "TOPLEFT", 2, -1.5)
	end
	if not sb[i].string2 then
		-- modevalue (modevalue%)
		sb[i].string2 = sb[i]:CreateFontString(nil, "OVERLAY")
		sb[i].string2:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
		sb[i].string2:SetPoint("TOPRIGHT", sb[i], "TOPRIGHT", -2, -1.5)
	end

	-- More details on hovering the Statusbars
	if not sb[i].content then
		sb[i].content = {}
	end

	sb[i]:SetScript("OnEnter", function(self)
		local curModeVal = StyleMeter.moduleDB[StyleMeter.activeModule][StyleMeter.DB.rank[viewrange + i - 1]]
		if curModeVal and curModeVal > 0 then
			local sortedSpells = {}
			-- Sort Spells & Abilities by active mode, so they aren't getting displayed funny
			GameTooltip:SetOwner(sb[i], "ANCHOR_TOPLEFT", 0, 0)
			GameTooltip:AddDoubleLine(StyleMeter.DB.rank[viewrange + i - 1], StyleMeter.DB.players[StyleMeter.DB.rank[viewrange + i - 1]].class, 1, 1, 1, 1, 1, 1)
			GameTooltip:AddDoubleLine("Total", curModeVal.." ("..(curModeVal / StyleMeter.moduleDBtotal[StyleMeter.activeModule] * 100).."%)" or "", 85/255, 153/255, 255/255, 1, 1, 1)
			GameTooltip:AddDoubleLine(StyleMeter.activeModule.." per Second:", siValue(curModeVal / StyleMeter.DB.players[StyleMeter.DB.rank[viewrange + i - 1]].combatTime),85/255, 153/255, 255/255, 1, 1, 1)
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine("Spells/Abilities used", 85/255, 153/255, 255/255)
			for k, v in pairs(StyleMeter.DB.spells[StyleMeter.activeModule][StyleMeter.DB.rank[viewrange + i - 1]]) do
				-- Instert spellnames to sortedSpells
				tinsert(sortedSpells, k)
				-- Sort the spells
				sort(sortedSpells, function(a, b) return StyleMeter.DB.spells[StyleMeter.activeModule][StyleMeter.DB.rank[viewrange + i - 1]][a] > StyleMeter.DB.spells[StyleMeter.activeModule][StyleMeter.DB.rank[viewrange + i - 1]][b] end)
			end
			for _, v in pairs(sortedSpells) do
				GameTooltip:AddDoubleLine(v, StyleMeter.DB.spells[StyleMeter.activeModule][StyleMeter.DB.rank[viewrange + i - 1]][v]..format(" (%.0f%%)", StyleMeter.DB.spells[StyleMeter.activeModule][StyleMeter.DB.rank[viewrange + i - 1]][v] / (StyleMeter.moduleDB[StyleMeter.activeModule][StyleMeter.DB.rank[viewrange + i - 1]]) * 100), 1, 1, 1, 1, 1, 1)
			end
			GameTooltip:Show()
		end
	end)

	sb[i]:SetScript("OnLeave", function() 
		GameTooltip:Hide() 
	end)

	-- Script for moving the frame and resetting data
	-- duplicate, because we just want to click without precision; otherwise we'd have to click exactly on the "Lolzen" frame
	sb[i]:SetScript("OnMouseDown", function(self, button)
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
	end)
	sb[i]:SetScript("OnMouseUp", function()
		Lolzen:StopMovingOrSizing()
	end)
end

--//#Functions called by core#//--

function StyleMeter.layoutSpecificReset()
	for i=1, 5, 1 do
		for k, v in pairs(sb[i].content) do
			sb[i].content[v] = ""
		end
	end
end

function switchMode(mode)
	if mode ~= nil then
		StyleMeter.activeModule = mode
	end

	for k, v in pairs(modulenames) do
		if v == StyleMeter.activeModule then
			tabs[k].bg:SetVertexColor(0.5, 0, 0, 0.5)
		else
			tabs[k].bg:SetVertexColor(0, 0, 0, 0.5)
		end
	end

	-- Sort Statusbars by active mode, so they aren't getting displayed funny
	if StyleMeter.moduleDB[StyleMeter.activeModule] then
		sort(StyleMeter.DB.rank, StyleMeter.sortByModule)
	end

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
end

function StyleMeter.UpdateLogin()
	-- Update on login and select the module with priority 1
	switchMode(modulenames[1])
end

function StyleMeter.UpdateLayout()
	for i=1, 5, 1 do
		local curModeVal = StyleMeter.moduleDB[StyleMeter.activeModule][StyleMeter.DB.rank[viewrange + i - 1]]
		if curModeVal and curModeVal > 0 then
			if sb[i]:GetAlpha() == 0 then
				sb[i]:SetAlpha(1)
			end
			sb[i]:SetMinMaxValues(0, StyleMeter.moduleDB[StyleMeter.activeModule][StyleMeter.DB.rank[1]] or 0)
			sb[i]:SetValue(curModeVal)
			-- Strings
			sb[i].string2:SetFormattedText("%s (%.0f%%)", siValue(curModeVal), curModeVal / StyleMeter.moduleDBtotal[StyleMeter.activeModule] * 100)
			sb[i].string1:SetFormattedText("%d.  |cff%02x%02x%02x%s|r", viewrange + i - 1, StyleMeter.DB.players[StyleMeter.DB.rank[viewrange + i - 1]].classcolor.r*255, StyleMeter.DB.players[StyleMeter.DB.rank[viewrange + i - 1]].classcolor.g*255, StyleMeter.DB.players[StyleMeter.DB.rank[viewrange + i - 1]].classcolor.b*255, StyleMeter.DB.rank[viewrange + i - 1])
			sb[i].border:Show()
			sb[i].bg:Show()
		else
			if sb[i]:GetAlpha() == 1 then
				sb[i]:SetAlpha(0)
				sb[i].string1:SetText(nil)
				sb[i].string2:SetText(nil)
				sb[i].border:Hide()
				sb[i].bg:Hide()
				sb[i].content = {}
			end
		end
	end

	-- Sort Statusbars by active mode, so they aren't getting displayed funny
	if StyleMeter.moduleDB[StyleMeter.activeModule] then
		sort(StyleMeter.DB.rank, StyleMeter.sortByModule)
	end
end