--// Layout (Tabbed) //--
-- Sample layout: basic tabbed layout

local activeModule
-- Set activeModule to module priority #1 initially
for k, v in pairs(StyleMeter.modulepriority) do
	if v == 1 then
		activeModule = k
	end
end

local Lolzen = CreateFrame("Frame")
Lolzen:SetSize(250, 90)
Lolzen:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -100, 16) --CHANGE LATER

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
--		elseif button == "RightButton" then
--			if IsInGroup("player") then
--				local channel = IsInRaid("player") and "RAID" or "PARTY"
--				SendAddonMessage("Wham_RESET", nil, channel)
--			end
		end
	end
end)

Lolzen:SetScript("OnMouseUp", function()
	Lolzen:StopMovingOrSizing()
end)

-- Script for fake-scrolling
local viewrange = 1
Lolzen:SetScript("OnMouseWheel", function(self, direction)
	if IsAltKeyDown() then
		if direction == 1 then -- "up"
			if viewrange > 1 then
				viewrange = viewrange - 1
			end
		elseif direction == -1 then -- "down"
			if viewrange < 20 then
				viewrange = viewrange + 1
			end
		end
		StyleMeter.UpdateLayout()
	end
end)

-- Background
local bg = Lolzen:CreateTexture("Background")
bg:SetTexture("Interface\\Buttons\\WHITE8x8")
bg:SetVertexColor(0, 0, 0, 0.5)
bg:SetAllPoints(Lolzen)
--bg:SetAlpha(0)

-- Border
local border = CreateFrame("Frame", nil, Lolzen)
border:SetBackdrop({
	edgeFile = "Interface\\AddOns\\StyleMeter_Lolzen\\Textures\\border3", edgeSize = 8,
	insets = {left = 4, right = 4, top = 4, bottom = 4},
})
border:SetPoint("TOPLEFT", bg, -2, 1)
border:SetPoint("BOTTOMRIGHT", bg, 2, -1)
border:SetBackdropBorderColor(0.2, 0.2, 0.2)
--border:SetAlpha(0)

-- Copy Modulenames into modulenames table, witth StyleMeter.modulepriority in mind
local modulenames = {}
local activated = {}
for k, v in pairs(StyleMeter.datamodules) do
	tinsert(modulenames, StyleMeter.modulepriority[k], k)
	if v["activated"] == true then
		activated[k] = true
	end
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
		tabs[k]:SetAlpha(0.4)
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
		if activated[v] == true then
			tabs[k].label:SetFormattedText("%s", v)
		else
			tabs[k].label:SetFormattedText("|cff550000%s|r", v)
		end
	end
	-- Border
	if not tabs[k].border then
		tabs[k].border = CreateFrame("Frame", nil, Lolzen)
		tabs[k].border:SetBackdrop({
			edgeFile = "Interface\\AddOns\\StyleMeter_Lolzen\\Textures\\border3", edgeSize = 8,
			insets = {left = 4, right = 4, top = 4, bottom = 4},
		})
		tabs[k].border:SetBackdropBorderColor(0.2, 0.2, 0.2)
		tabs[k].border:SetPoint("TOPLEFT", tabs[k], -2, 1)
		tabs[k].border:SetPoint("BOTTOMRIGHT", tabs[k], 2, -1)
		tabs[k].border:SetAlpha(1)
	end
	-- clickscript for switching
	tabs[k]:SetScript("OnMouseDown", function(self, button)
		if activated[v] == true then
			switchMode(v)
			StyleMeter.UpdateLayout()
		else
			print("|cff5599ffStyleMeter:|r Module for "..v.." deactivated. Check your config.lua")
		end
	end)
end

-- Create the Statusbars
sb = {}

for i=1, 25, 1 do
	-- Create the StatusBars
	if not sb[i] then
		sb[i] = CreateFrame("StatusBar", "StatusBar"..i, Lolzen)
		sb[i]:SetHeight(15)
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
			edgeFile = "Interface\\AddOns\\StyleMeter_Lolzen\\Textures\\border3", edgeSize = 8,
			insets = {left = 4, right = 4, top = 4, bottom = 4},
		})
		sb[i].border:SetPoint("TOPLEFT", sb[i], -2, 1)
		sb[i].border:SetPoint("BOTTOMRIGHT", sb[i], 2, -1)
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
		sb[i].string1:SetPoint("TOPLEFT", sb[i], "TOPLEFT", 2, -2)
	end
	if not sb[i].string2 then
		-- modevalue (modevalue%)
		sb[i].string2 = sb[i]:CreateFontString(nil, "OVERLAY")
		sb[i].string2:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
		sb[i].string2:SetPoint("TOPRIGHT", sb[i], "TOPRIGHT", -2, -2)
	end
end

function Lolzen:UpdateDisplay()
	for i=1, 5, 1 do
		if i == 1 then
			if StyleMeter.moduleDBtotal[activeModule] and StyleMeter.moduleDBtotal[activeModule] > 0 then
				local curModeVal = StyleMeter.moduleDB[activeModule][StyleMeter.guidDB.rank[viewrange]] or 0
				if curModeVal and curModeVal > 0 then
					--Statusbars
					if sb[i]:GetAlpha() == 0 then
						sb[i]:SetAlpha(1)
					end
					sb[i]:SetMinMaxValues(0, StyleMeter.moduleDBtotal[activeModule] or 0)
					sb[i]:SetValue(StyleMeter.moduleDB[activeModule][StyleMeter.guidDB.rank[viewrange]] or 0)
					-- Strings
					local rcColor
					for _, guid in pairs(StyleMeter.guidDB.players) do
						rcColor = guid.classcolor or {r = 0.3, g = 0.3, b = 0.3}
					end
					sb[i].string2:SetFormattedText("%d (%.0f%%)", curModeVal, curModeVal / StyleMeter.moduleDBtotal[activeModule] * 100)
					sb[i].string1:SetFormattedText("%d.  |cff%02x%02x%02x%s|r", viewrange, rcColor.r*255, rcColor.g*255, rcColor.b*255, StyleMeter.guidDB.rank[viewrange])
					sb[i].border:Show()
					sb[i].bg:Show()
				end
			else
				if sb[i]:GetAlpha() == 1 then
					sb[i]:SetAlpha(0)
				end
				sb[i].string1:SetText(nil)
				sb[i].string2:SetText(nil)
				sb[i].border:Hide()
				sb[i].bg:Hide()
			end
		else
			if StyleMeter.moduleDBtotal[activeModule] and StyleMeter.moduleDBtotal[activeModule] > 0 then
			local curModeVal = StyleMeter.moduleDB[activeModule][StyleMeter.guidDB.rank[viewrange + i - 1]] or 0
				if curModeVal and curModeVal > 0 then
--					-- Statusbars
					if sb[i]:GetAlpha() == 0 then
						sb[i]:SetAlpha(1)
					end
--					ns.sb[i]:SetMinMaxValues(0, ns.modeData[ns.guidDB.rank[1]] or 0)
--					ns.sb[i]:SetValue(ns.modeData[ns.guidDB.rank[ns.viewrange + i - 1]] or 0)
--					-- Strings
					local rcColor 
					for _, guid in pairs(StyleMeter.guidDB.players) do
						rcColor = guid.classcolor  or {r = 0.3, g = 0.3, b = 0.3}
					end
					sb[i].string2:SetFormattedText("%d (%.0f%%)", curModeVal, curModeVal / StyleMeter.moduleDBtotal[activeModule] * 100)
					sb[i].string1:SetFormattedText("%d.  |cff%02x%02x%02x%s|r", viewrange + i - 1, rcColor.r*255, rcColor.g*255, rcColor.b*255, StyleMeter.guidDB.rank[viewrange + i - 1])
					sb[i].border:Show()
					sb[i].bg:Show()
				end
			else
				if sb[i]:GetAlpha() == 1 then
					sb[i]:SetAlpha(0)
				end
				sb[i].string1:SetText(nil)
				sb[i].string2:SetText(nil)
				sb[i].border:Hide()
				sb[i].bg:Hide()
			end
		end
	end
end

--//#Functions called by core#//--

--function StyleMeter.layoutSpecificReset()
--	for i=1, 25, 1 do
--		sb[i]:SetValue(0)
--		sb[i].bg:Hide()
--		sb[i].string1:SetText(nil)
--		sb[i].string2:SetText(nil)
--		sb[i].border:Hide()
--		sb[i].bg:Hide()
--	end
--	bg:SetAlpha(0)
--	border:SetAlpha(0)
--end

function switchMode(mode)
	if mode ~= nil then
		activeModule = mode
	end

	for k, v in pairs(modulenames) do
		if v == activeModule then
			tabs[k].bg:SetVertexColor(0.5, 0, 0, 0.5)
		else
			tabs[k].bg:SetVertexColor(0, 0, 0, 0.5)
		end
	end
	
	-- Sort Statusbars by active mode, so they aren't getting displayed funny
--		sort(StyleMeter.guidDB.rank, StyleMeter.sortByModule(activeModule))
	
	for i=1, 25, 1 do
		if activeModule == "Damage" or activeModule == "Damage Taken" then
			sb[i]:SetStatusBarColor(0.8, 0, 0)
		elseif activeModule == "Heal" or activeModule == "OverHeal" then
			sb[i]:SetStatusBarColor(0, 0.8, 0)
		elseif activeModule == "Absorb" then
			sb[i]:SetStatusBarColor(0.8, 0.8, 0)
		elseif activeModule == "Deaths" then
			sb[i]:SetStatusBarColor(0.2, 0.2, 0.2)
		else
			sb[i]:SetStatusBarColor(0.7, 0.7, 0.7)
		end
	end
end

function StyleMeter.UpdateLayout()
	-- ensure we're always getting fresh modedata
	switchMode()

	-- Show background and border when data is stored
--	for i=1, 25, 1 do
--		if ns.modeData[ns.guidDB.rank[i]] then
--			if ns.bg:GetAlpha() ~= 1 then
--				ns.bg:SetAlpha(1)
--			end
--			if ns.border:GetAlpha() ~=1 then
--				ns.border:SetAlpha(1)
--			end
--		end
--	end

	Lolzen:UpdateDisplay()
end