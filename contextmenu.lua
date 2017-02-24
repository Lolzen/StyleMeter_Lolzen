--// Context menu //--

StyleMeter.Lolzen_DropDownMenu = CreateFrame("Frame", "Lolzen_DropDownMenu")
StyleMeter.Lolzen_DropDownMenu.displayMode = "MENU"

--Create a Popupdialogs for whispering
StaticPopupDialogs["WHISPER_TO_REPORT"] = {
	text = "Whisper to",
	button1 = "OK",
	button2 = "Cancel",
	hasEditBox = true,
	OnAccept = function(self, data)
		local text = self.editBox:GetText()
		SendChatMessage("StyleMeter report for : ["..StyleMeter.activeModule.."]", "WHISPER", nil, text)
		for i=1, 5, 1 do
			local curModeVal = StyleMeter.moduleDB[StyleMeter.activeModule][StyleMeter.DB.rank[i]]
			if i and StyleMeter.moduleDB[StyleMeter.activeModule][StyleMeter.DB.rank[i]] then
				SendChatMessage(string.format("%d. %s: %d (%s, %.0f%%) [%s]", i, StyleMeter.DB.rank[i], curModeVal, StyleMeter.siValue(curModeVal / StyleMeter.DB.players[StyleMeter.DB.rank[i]][StyleMeter.activeModule].combatTime), curModeVal / StyleMeter.moduleDBtotal[StyleMeter.activeModule] * 100, StyleMeter.DB.players[StyleMeter.DB.rank[i]].class), "WHISPER", nil, text)
			end
		end
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	enterClicksFirstButton = true,
	preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}

StaticPopupDialogs["WHISPER_TO_REPORT_SPELLS"] = {
	text = "Whisper spells used to",
	button1 = "OK",
	button2 = "Cancel",
	hasEditBox = true,
	OnAccept = function(self, data)
		local text = self.editBox:GetText()
		local sortedSpells = {}
		if StyleMeter.DB.spells[StyleMeter.activeModule][StyleMeter.DB.rank[StyleMeter.clicked]] then
			SendChatMessage("StyleMeter report for : [Spells used in "..StyleMeter.activeModule.."] from ["..StyleMeter.DB.rank[StyleMeter.clicked].."]", "WHISPER", nil, text)
			for k, v in pairs(StyleMeter.DB.spells[StyleMeter.activeModule][StyleMeter.DB.rank[StyleMeter.clicked]]) do
				tinsert(sortedSpells, k)
				sort(sortedSpells, function(a, b) return StyleMeter.DB.spells[StyleMeter.activeModule][StyleMeter.DB.rank[StyleMeter.clicked]][a] > StyleMeter.DB.spells[StyleMeter.activeModule][StyleMeter.DB.rank[StyleMeter.clicked]][b] end)
			end
			for _, v in pairs(sortedSpells) do
				local link
				if GetSpellLink(v) ~= nil then
					link = GetSpellLink(v)
				else
					link = v
				end
				SendChatMessage(link.." "..StyleMeter.DB.spells[StyleMeter.activeModule][StyleMeter.DB.rank[StyleMeter.clicked]][v].." "..format(" (%.0f%%)", StyleMeter.DB.spells[StyleMeter.activeModule][StyleMeter.DB.rank[StyleMeter.clicked]][v] / StyleMeter.moduleDB[StyleMeter.activeModule][StyleMeter.DB.rank[StyleMeter.clicked]] * 100), "WHISPER", nil, text)
			end
		end
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	enterClicksFirstButton = true,
	preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}

StyleMeter.Lolzen_DropDownMenu.report = function(dropdownbutton, arg1)
	if arg1 == "WHISPER" then
		StaticPopup_Show("WHISPER_TO_REPORT")
		CloseDropDownMenus()
	else
		SendChatMessage("StyleMeter report for : ["..StyleMeter.activeModule.."]", arg1, nil)
		for i=1, 5, 1 do
			local curModeVal = StyleMeter.moduleDB[StyleMeter.activeModule][StyleMeter.DB.rank[i]]
			if i and StyleMeter.moduleDB[StyleMeter.activeModule][StyleMeter.DB.rank[i]] then
				SendChatMessage(string.format("%d. %s: %d (%s, %.0f%%) [%s]", i, StyleMeter.DB.rank[i], curModeVal, StyleMeter.siValue(curModeVal / StyleMeter.DB.players[StyleMeter.DB.rank[i]][StyleMeter.activeModule].combatTime), curModeVal / StyleMeter.moduleDBtotal[StyleMeter.activeModule] * 100, StyleMeter.DB.players[StyleMeter.DB.rank[i]].class), arg1, nil)
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
		if StyleMeter.DB.spells[StyleMeter.activeModule][StyleMeter.DB.rank[StyleMeter.clicked]] then
			SendChatMessage("StyleMeter report for : [Spells used in "..StyleMeter.activeModule.."] from ["..StyleMeter.DB.rank[StyleMeter.clicked].."]", arg1, nil)
			for k, v in pairs(StyleMeter.DB.spells[StyleMeter.activeModule][StyleMeter.DB.rank[StyleMeter.clicked]]) do
				tinsert(sortedSpells, k)
				sort(sortedSpells, function(a, b) return StyleMeter.DB.spells[StyleMeter.activeModule][StyleMeter.DB.rank[StyleMeter.clicked]][a] > StyleMeter.DB.spells[StyleMeter.activeModule][StyleMeter.DB.rank[StyleMeter.clicked]][b] end)
			end
			for _, v in pairs(sortedSpells) do
				local link
				if GetSpellLink(v) ~= nil then
					link = GetSpellLink(v)
				else
					link = v
				end
				SendChatMessage(link.." "..StyleMeter.DB.spells[StyleMeter.activeModule][StyleMeter.DB.rank[StyleMeter.clicked]][v].." "..format(" (%.0f%%)", StyleMeter.DB.spells[StyleMeter.activeModule][StyleMeter.DB.rank[StyleMeter.clicked]][v] / StyleMeter.moduleDB[StyleMeter.activeModule][StyleMeter.DB.rank[StyleMeter.clicked]] * 100), arg1, nil)
			end
		end
		CloseDropDownMenus()
	end
end

StyleMeter.Lolzen_DropDownMenu.switchMode = function(dropdownbutton, arg1)
	StyleMeter.switchMode(arg1)
	StyleMeter.UpdateLayout()
	CloseDropDownMenus()
end

local info = {}
StyleMeter.Lolzen_DropDownMenu.initialize = function(self, level)
	if not level then return end
	wipe(info)
	if level == 1 then
		info.text = "Mode (current: "..StyleMeter.activeModule..")"
		info.notCheckable = 1
		info.hasArrow = 1
		info.value = "mode"
		UIDropDownMenu_AddButton(info, level)

		info.text = "Report to"
		info.notCheckable = 1
		info.hasArrow = 1
		info.value = "reportto1"
		UIDropDownMenu_AddButton(info, level)

		info.text = "Report spells used to"
		info.notCheckable = 1
		info.hasArrow = 1
		info.value = "reportto2"
		UIDropDownMenu_AddButton(info, level)

		info.text = "Cancel"
		info.notCheckable = 1
		info.hasArrow = false
		info.value = "cancel"
		info.func = CloseDropDownMenus()
		UIDropDownMenu_AddButton(info, level)
		
	elseif level == 2 then 
		if UIDROPDOWNMENU_MENU_VALUE == "mode" then
			for module in pairs(StyleMeter.module) do
				info.text = module
				if info.text == StyleMeter.activeModule then
					info.checked = true
				else
					info.checked = false
				end
				info.func = self.switchMode
				info.arg1 = module
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