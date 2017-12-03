--// Context menu //--

StyleMeter.Lolzen_DropDownMenu = CreateFrame("Frame", "Lolzen_DropDownMenu")
StyleMeter.Lolzen_DropDownMenu.displayMode = "MENU"

-- Modify the Background & Border textures/colors
local LolzenBackdrop = {
	edgeFile = "Interface\\AddOns\\StyleMeter_Lolzen\\Textures\\borderwhite", edgeSize = 12,
	bgFile = "Interface\\Buttons\\WHITE8x8",
	insets = {left = 2, right = 2, top = 2, bottom = 2},
}

hooksecurefunc("ToggleDropDownMenu", function(level, ...)
	if not level then
		level = 1
	end
	local menu1 = _G["DropDownList"..level.."Backdrop"]
	local menu2 = _G["DropDownList"..level.."MenuBackdrop"]
	if menu1 then
		menu1:SetBackdrop(LolzenBackdrop)
		menu1:SetBackdropBorderColor(0.8, 0.8, 0.8, 1)
		menu1:SetBackdropColor(0, 0, 0, 1)
	end
	if menu2 then
		menu2:SetBackdrop(LolzenBackdrop)
		menu2:SetBackdropBorderColor(0.8, 0.8, 0.8, 1)
		menu2:SetBackdropColor(0, 0, 0, 1)
	end
end)

local ReportDataWhisperFunc = function(self)
	local text = self.editBox:GetText()
	SendChatMessage("StyleMeter report for : ["..StyleMeter.activeModule.."]", "WHISPER", nil, text)
	for i=1, 5, 1 do
		local curModeVal, curModeTotal = StyleMeter.getModeData(i)
		local curModeCombatTime = StyleMeter.getTimeAndSpells(i)
		if i and curModeVal then
			SendChatMessage(string.format("%d. %s: %s (%s, %.0f%%) [%s]", i, StyleMeter.DB.rank[i], tostring(curModeVal), tostring(StyleMeter.siValue(curModeVal / curModeCombatTime)), tostring(curModeVal / curModeTotal * 100), StyleMeter.DB.players[StyleMeter.DB.rank[i]].class), "WHISPER", nil, text)
		end
	end
end

--Create a Popupdialogs for whispering
StaticPopupDialogs["WHISPER_TO_REPORT"] = {
	text = "Whisper to",
	button1 = "OK",
	button2 = "Cancel",
	hasEditBox = true,
	OnAccept = function(self)
		ReportDataWhisperFunc(self)
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent()
		ReportDataWhisperFunc(parent)
		parent:Hide()
	end,
	EditBoxOnEscapePressed = function(self)
		local parent = self:GetParent()
		parent:Hide()
	end,
	timeout = 0,
	whileDead = true,
	preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}

local WhisperToSpellsFunc = function(self)
	local text = self.editBox:GetText()
	local sortedSpells = {}
	local spells = StyleMeter.data.overall[StyleMeter.DB.rank[StyleMeter.clicked]][StyleMeter.activeModule].spells
	if spells then
		SendChatMessage("StyleMeter report for : [Spells used in "..StyleMeter.activeModule.."] from ["..StyleMeter.DB.rank[StyleMeter.clicked].."]", "WHISPER", nil, text)
		for k, v in pairs(spells) do
			if not sortedSpells[k] then
				tinsert(sortedSpells, k)
				sort(sortedSpells, function(a, b) return spells[a].amount > spells[b].amount end)
			end
		end
		for _, v in pairs(sortedSpells) do
			SendChatMessage(v.." "..spells[v].amount.." "..format(" (%.0f%%)", spells[v].amount / StyleMeter.data.overall[StyleMeter.DB.rank[StyleMeter.clicked]][StyleMeter.activeModule].total * 100), "WHISPER", nil, text)
		end
	end
end

StaticPopupDialogs["WHISPER_TO_REPORT_SPELLS"] = {
	text = "Whisper spells used to",
	button1 = "OK",
	button2 = "Cancel",
	hasEditBox = true,
	OnAccept = function(self)
		WhisperToSpellsFunc(self)
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent()
		WhisperToSpellsFunc(parent)
		parent:Hide()
	end,
	EditBoxOnEscapePressed = function(self)
		local parent = self:GetParent()
		parent:Hide()
	end,
	timeout = 0,
	whileDead = true,
	preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}

StyleMeter.Lolzen_DropDownMenu.report = function(dropdownbutton, arg1)
	if arg1 == "WHISPER" then
		StaticPopup_Show("WHISPER_TO_REPORT")
		CloseDropDownMenus()
	else
		SendChatMessage("StyleMeter report for : ["..StyleMeter.activeModule.."]", arg1, nil)
		for i=1, 5, 1 do
			local curModeVal, curModeTotal = StyleMeter.getModeData(i)
			local curModeCombatTime = StyleMeter.getTimeAndSpells(i)
			if i and curModeVal then
				SendChatMessage(string.format("%d. %s: %s (%s, %.0f%%) [%s]", i, StyleMeter.DB.rank[i], tostring(curModeVal), tostring(StyleMeter.siValue(curModeVal / curModeCombatTime)), tostring(curModeVal / curModeTotal * 100), StyleMeter.DB.players[StyleMeter.DB.rank[i]].class), arg1, nil)
			end
		end
	end
	CloseDropDownMenus()
end

StyleMeter.Lolzen_DropDownMenu.report_spells = function(dropdownbutton, arg1)
	if arg1 == "WHISPER" then
		StaticPopup_Show("WHISPER_TO_REPORT_SPELLS")
		CloseDropDownMenus()
	else
		local sortedSpells = {}
		local spells = StyleMeter.data.overall[StyleMeter.DB.rank[StyleMeter.clicked]][StyleMeter.activeModule].spells
		if spells then
			SendChatMessage("StyleMeter report for : [Spells used in "..StyleMeter.activeModule.."] from ["..StyleMeter.DB.rank[StyleMeter.clicked].."]", arg1, nil)
			for k, v in pairs(spells) do
				if not sortedSpells[k] then
					tinsert(sortedSpells, k)
				end
				sort(sortedSpells, function(a, b) return spells[a].amount > spells[b].amount end)
			end
			for _, v in pairs(sortedSpells) do
				SendChatMessage(v.." "..spells[v].amount.." "..format(" (%.0f%%)", spells[v].amount / StyleMeter.data.overall[StyleMeter.DB.rank[StyleMeter.clicked]][StyleMeter.activeModule].total * 100), arg1, nil)
			end
		end
		CloseDropDownMenus()
	end
end

StyleMeter.Lolzen_DropDownMenu.switchModule = function(dropdownbutton, arg1)
	StyleMetercfg.displaymodule = arg1
	StyleMeter.switchModule(arg1)
	StyleMeter.UpdateLayout()
	CloseDropDownMenus()
end

StyleMeter.Lolzen_DropDownMenu.switchMode = function(dropdownbutton, arg1)
	StyleMetercfg.displaymode = arg1
	StyleMeter.switchMode(arg1)
	StyleMeter.UpdateLayout()
	CloseDropDownMenus()
end

local info = {}
StyleMeter.Lolzen_DropDownMenu.initialize = function(self, level)
	if not level then return end
	wipe(info)
	if level == 1 then
		info.text = "Module (current: "..StyleMeter.activeModule..")"
		info.notCheckable = 1
		info.hasArrow = 1
		info.value = "module"
		UIDropDownMenu_AddButton(info, level)
		
		info.text = "Display Mode (current: "..StyleMeter.activeMode..")"
		info.notCheckable = 1
		info.hasArrow = 1
		info.value = "mode"
		UIDropDownMenu_AddButton(info, level)

		info.text = "Report to"
		info.notCheckable = 1
		info.hasArrow = 1
		info.value = "reportto1"
		UIDropDownMenu_AddButton(info, level)

		if StyleMeter.clicked ~= 0 then
			info.text = "Report spells used to"
			info.notCheckable = 1
			info.hasArrow = 1
			info.value = "reportto2"
			UIDropDownMenu_AddButton(info, level)
		end

		info.text = "Cancel"
		info.notCheckable = 1
		info.hasArrow = false
		info.value = "cancel"
		info.func = CloseDropDownMenus()
		UIDropDownMenu_AddButton(info, level)
		
	elseif level == 2 then 
		if UIDROPDOWNMENU_MENU_VALUE == "module" then
			for module in pairs(StyleMeter.module) do
				info.text = module
				if info.text == StyleMeter.activeModule then
					info.checked = true
				else
					info.checked = false
				end
				info.func = self.switchModule
				info.arg1 = module
				UIDropDownMenu_AddButton(info, level)
			end
		elseif UIDROPDOWNMENU_MENU_VALUE == "mode" then
			for _, mode in pairs({"Current", "Overall", "Hybrid"}) do
				info.text = mode
				if info.text == StyleMeter.activeMode then
					info.checked = true
				else
					info.checked = false
				end
				info.func = self.switchMode
				info.arg1 = mode
				UIDropDownMenu_AddButton(info, level)
			end
		elseif UIDROPDOWNMENU_MENU_VALUE == "reportto1" then
			info.text = "Say"
			info.notCheckable = 1
			info.func = self.report
			info.arg1 = "SAY"
			UIDropDownMenu_AddButton(info, level)
			
			info.text = "Party"
			info.notCheckable = 1
			info.func = self.report
			info.arg1 = "PARTY"
			UIDropDownMenu_AddButton(info, level)
			
			info.text = "Guild"
			info.notCheckable = 1
			info.func = self.report
			info.arg1 = "GUILD"
			UIDropDownMenu_AddButton(info, level)
			
			info.text = "Raid"
			info.notCheckable = 1
			info.func = self.report
			info.arg1 = "RAID"
			UIDropDownMenu_AddButton(info, level)
			
			info.text = "Instance"
			info.notCheckable = 1
			info.func = self.report
			info.arg1 = "INSTANCE"
			UIDropDownMenu_AddButton(info, level)
			
			info.text = "Whisper to"
			info.notCheckable = 1
			info.func = self.report
			info.arg1 = "WHISPER"
			UIDropDownMenu_AddButton(info, level)	
		elseif UIDROPDOWNMENU_MENU_VALUE == "reportto2" then
			info.text = "Say"
			info.notCheckable = 1
			info.func = self.report_spells
			info.arg1 = "SAY"
			UIDropDownMenu_AddButton(info, level)
			
			info.text = "Party"
			info.notCheckable = 1
			info.func = self.report_spells
			info.arg1 = "PARTY"
			UIDropDownMenu_AddButton(info, level)
			
			info.text = "Guild"
			info.notCheckable = 1
			info.func = self.report_spells
			info.arg1 = "GUILD"
			UIDropDownMenu_AddButton(info, level)
			
			info.text = "Raid"
			info.notCheckable = 1
			info.func = self.report_spells
			info.arg1 = "RAID"
			UIDropDownMenu_AddButton(info, level)
			
			info.text = "Instance"
			info.notCheckable = 1
			info.func = self.report_spells
			info.arg1 = "INSTANCE"
			UIDropDownMenu_AddButton(info, level)
			
			info.text = "Whisper to"
			info.notCheckable = 1
			info.func = self.report_spells
			info.arg1 = "WHISPER"
			UIDropDownMenu_AddButton(info, level)	
		end
	end
end