local addonName, addonTable = ...


local NPC_DATA = addonTable.database.npc
local QUEST_DATA = addonTable.database.quest

local HOLIDAY_DATA = {
	{
		dungeonID = 287,
		questCategoryID = 370,
		title = "Brewfest",
	},
	{
		questCategoryID = 41,
		title = "Day of the Dead",
	},
	{
		dungeonID = 285,
		questCategoryID = 21,
		title = "Hallow's End",
	},
	{
		questCategoryID = 375,
		title = "Pilgrim's Bounty",
	},
}



local HolidayFrame = CreateFrame("Frame", nil, UIParent)
HolidayFrame:Hide()
HolidayFrame:SetPoint("Bottom", 0, 200)
HolidayFrame:SetPoint("Right", -5, 0)
HolidayFrame:SetSize(200, 1)

function HolidayFrame:ResizeToContent()
	local _, titleBottom, _, titleHeight = self.TitleText:GetRect()
	local titleTop = titleBottom + titleHeight

	local _, questContainerBottom = self.QuestContainer:GetRect()

	self:SetHeight(titleTop - questContainerBottom)
end

HolidayFrame:RegisterEvent("FIRST_FRAME_RENDERED")
HolidayFrame:SetScript("OnEvent", function(self)
	addonTable.Calendar:UpdateEventList(addonTable.C_Holiday.GetHolidayInfo, addonTable.C_Holiday)
end)

HolidayFrame.TitleText = HolidayFrame:CreateFontString()
HolidayFrame.TitleText:SetFont(addonTable.Font:GetDefaultFontFamily(), 17, "Outline")
HolidayFrame.TitleText:SetPoint("Top")
HolidayFrame.TitleText:SetText("Holiday Title")
HolidayFrame.TitleText:SetTextColor(addonTable.Color:GetColor("yellow"):GetRGB())

HolidayFrame.DungeonButton = CreateFrame("Button", nil, HolidayFrame)
HolidayFrame.DungeonButton:SetPoint("Left")
HolidayFrame.DungeonButton:SetPoint("Right")
HolidayFrame.DungeonButton:SetPoint("Top", HolidayFrame.TitleText, "Bottom", 0, -5)
HolidayFrame.DungeonButton:SetText("Queue for Dungeon")

HolidayFrame.DungeonButton:GetFontString():SetFont(addonTable.Font:GetDefaultFontFamily(), 13, "Outline")

HolidayFrame.DungeonButton:SetSize(HolidayFrame.DungeonButton:GetFontString():GetSize())

HolidayFrame.DungeonButton:SetScript("OnClick", function(self)
	addonTable.C_LFG:JoinDungeon(self.dungeonID)
end)

HolidayFrame.DungeonButton:SetScript("OnHide", function(self)
	self:SetHeight(1)
end)

HolidayFrame.DungeonButton:SetScript("OnShow", function(self)
	self:SetSize(self:GetFontString():GetSize())
end)

HolidayFrame.QuestHeader = HolidayFrame:CreateFontString()
HolidayFrame.QuestHeader:SetFont(addonTable.Font:GetDefaultFontFamily(), 13, "Outline")
HolidayFrame.QuestHeader:SetJustifyH("Left")
HolidayFrame.QuestHeader:SetPoint("Left")
HolidayFrame.QuestHeader:SetPoint("Right")
HolidayFrame.QuestHeader:SetPoint("Top", HolidayFrame.DungeonButton, "Bottom", 0, -5)
HolidayFrame.QuestHeader:SetText("Quests")
HolidayFrame.QuestHeader:SetTextColor(addonTable.Color:GetColor("yellow"):GetRGB())

HolidayFrame.QuestContainer = CreateFrame("Frame", nil, HolidayFrame)

HolidayFrame.QuestContainer.buttonYOffset = -3
HolidayFrame.QuestContainer.maxButtonWidth = HolidayFrame:GetWidth()
HolidayFrame.QuestContainer.totalButtonHeight = 0

HolidayFrame.QuestContainer:SetHeight(1)
HolidayFrame.QuestContainer:SetPoint("Left", 5, 0)
HolidayFrame.QuestContainer:SetPoint("Right")
HolidayFrame.QuestContainer:SetPoint("Top", HolidayFrame.QuestHeader, "Bottom", 0, -3)

HolidayFrame.QuestContainer.questButtons = {}

HolidayFrame.QuestContainer:RegisterEvent("QUEST_LOG_UPDATE")
HolidayFrame.QuestContainer:SetScript("OnEvent", function(self, event)
	if not self.questIDs or #self.questIDs == 0 then
		return
	end

	self.availableQuestIDs = {}

	for questIndex, questID in ipairs(self.questIDs) do
		local questData = QUEST_DATA[questID]

		local isQuestFlaggedCompleted = C_QuestLog.IsQuestFlaggedCompleted(questID)
		local isQuestForPlayerFaction
		local playerFaction = UnitFactionGroup("player")
		local playerFactionID

		-- isQuestFlaggedCompleted = false

		if playerFaction == "Alliance" then
			playerFactionID = LE_QUEST_FACTION_ALLIANCE
		elseif playerFaction == "Horde" then
			playerFactionID = LE_QUEST_FACTION_HORDE
		end

		local questFactionID = GetQuestFactionGroup(questID)

		if not questFactionID and questData.factionID then
			questFactionID = questData.factionID
		end

		if not questFactionID or questFactionID == playerFactionID then
			isQuestForPlayerFaction = true
		end

		if not isQuestFlaggedCompleted and isQuestForPlayerFaction then
			if questData.isCompleted then
				if not questData.isCompleted() then
					table.insert(self.availableQuestIDs, questID)
				end
			else
				table.insert(self.availableQuestIDs, questID)
			end
		end
	end

	if #self.availableQuestIDs == 0 then
		return
	end

	table.sort(self.availableQuestIDs, function(lQuestID, rQuestID)
		local lQuestName = C_QuestLog.GetTitleForQuestID(lQuestID)
		local rQuestName = C_QuestLog.GetTitleForQuestID(rQuestID)

		if not lQuestName or not rQuestName or lQuestName == rQuestName then
			return lQuestID < rQuestID
		end

		return lQuestName < rQuestName
	end)

	self:ClearQuestButtons()

	local questButtonIndex = 1

	for i, questID in ipairs(self.availableQuestIDs) do
		self:SetQuestButton(questButtonIndex, questID, questData)

		questButtonIndex = questButtonIndex + 1
	end

	self:SetHeight(self.totalButtonHeight)

	HolidayFrame:SetWidth(self.maxButtonWidth)

	HolidayFrame:ResizeToContent()
end)

function HolidayFrame.QuestContainer:ClearQuestButtons()
	for i, QuestButton in ipairs(self.questButtons) do
		QuestButton:Hide()
		QuestButton:SetText()
	end

	self.maxButtonWidth = 200
	self.totalButtonHeight = 0
end

function HolidayFrame.QuestContainer:SetQuestButton(questButtonIndex, questID, questData)
	local questTitle = C_QuestLog.GetTitleForQuestID(questID)

	if not questTitle then
		return
	end

	local QuestButton = self.questButtons[questButtonIndex]

	if not QuestButton then
		QuestButton = self:CreateQuestButton(questID, questData)
	end

	QuestButton.questID = questID

	local textColor

	if C_QuestLog.IsRepeatableQuest(questID) then
		textColor = "|cff00ccff"
	else
		textColor = "|cffffffff"
	end

	QuestButton:SetText(textColor .. questTitle .. " (" .. questID .. ")|r")

	local fontString = QuestButton:GetFontString()

	fontString:SetFont(addonTable.Font:GetDefaultFontFamily(), 11, "Outline")
	fontString:SetTextColor(addonTable.Color:GetColor("white"):GetRGB())
	fontString:SetPoint("Left")
	-- fontString:SetAllPoints()
	-- fontString:SetJustifyH("Left")

	QuestButton:SetHeight(QuestButton:GetTextHeight())

	QuestButton:Show()

	self.totalButtonHeight = self.totalButtonHeight + QuestButton:GetHeight()

	if questButtonIndex ~= 1 then
		self.totalButtonHeight = self.totalButtonHeight + math.abs(self.buttonYOffset)
	end

	self.maxButtonWidth = math.max(self.maxButtonWidth, QuestButton:GetTextWidth() + 5)
end

function HolidayFrame.QuestContainer:CreateQuestButton(questID, questData)
	local QuestButton = CreateFrame("Button", nil, self)

	table.insert(self.questButtons, QuestButton)

	if #self.questButtons == 1 then
		QuestButton:SetPoint("Top")
	else
		QuestButton:SetPoint("Top", self.questButtons[#self.questButtons - 1], "Bottom", 0, self.buttonYOffset)
	end

	QuestButton:SetPoint("Left")
	QuestButton:SetPoint("Right")

	QuestButton:SetScript("OnClick", function(self)
		local obtainData = QUEST_DATA[self.questID].obtain

		if obtainData then
			if obtainData.type == "npc" then
				local positions = NPC_DATA[obtainData.id].positions

				if #positions > 0 then
					local position = positions[1]

					if position then
						C_Map.SetUserWaypoint(UiMapPoint.CreateFromCoordinates(position.uiMapID, position.x, position.y))
						C_SuperTrack.SetSuperTrackedUserWaypoint(true)
					end
				end
			end
		end
	end)

	return QuestButton
end


addonTable.C_FrameHide:SetupFrame(HolidayFrame, {
	hiddenAlpha = 0.2,
})



local C_Holiday = {}
addonTable.C_Holiday = C_Holiday

function C_Holiday:IsActive()
	return self.isHolidayActive, self.inactiveReason
end

function C_Holiday:SetActive()
	self.inactiveReason = nil
	self.isHolidayActive = true

	HolidayFrame:Show()
end

function C_Holiday:SetInactive(message)
	self.isHolidayActive = false

	if message then
		self.inactiveReason = message
	else
		self.inactiveReason = nil
	end

	HolidayFrame:Hide()
end

function C_Holiday:GetHolidayInfo()
	self:SetInactive()

	for i, holidayData in ipairs(HOLIDAY_DATA) do
		local isEventActive = addonTable.Calendar:IsEventActive(holidayData.title)

		if isEventActive then
			addonTable.C_Holiday:ShowHoliday(holidayData)

			HolidayFrame:Show()

			return
		end
	end
end

function C_Holiday:ShowHoliday(holidayData)
	local dungeonID = holidayData.dungeonID
	local eventTitle = holidayData.title
	local questCategoryID = holidayData.questCategoryID

	local isEventActive = addonTable.Calendar:IsEventActive(eventTitle)

	if not isEventActive then
		self:SetInactive(string.format("|cffffff00%s is not currently active.|r", eventTitle))

		return
	end

	local allQuestsCompleted = true

	HolidayFrame.QuestContainer.questIDs = {}

	for questID, questData in pairs(QUEST_DATA) do
		if questData.categoryID == questCategoryID then
			if not addonTable.D_Quest:IsQuestCompleted(questID) then
				allQuestsCompleted = false
			end

			table.insert(HolidayFrame.QuestContainer.questIDs, questID)

			C_QuestLog.RequestLoadQuestByID(questID)
		end
	end

	local dungeonDoneToday

	if dungeonID then
		dungeonDoneToday = GetLFGDungeonRewards(dungeonID)
	else
		dungeonDoneToday = true
	end

	if allQuestsCompleted and dungeonDoneToday then
		self:SetInactive(string.format("|cff00ff00All %s events completed today!|r", eventTitle))

		return
	end

	HolidayFrame.TitleText:SetText(eventTitle)

	HolidayFrame.DungeonButton.dungeonID = dungeonID

	local DungeonButtonFontString = HolidayFrame.DungeonButton:GetFontString()

	if dungeonID then
		if dungeonDoneToday then
			DungeonButtonFontString:SetText("Dungeon Complete")
			DungeonButtonFontString:SetTextColor(addonTable.Color:GetColor("green"):GetRGB())
		else
			DungeonButtonFontString:SetText("Queue for Dungeon")
			DungeonButtonFontString:SetTextColor(addonTable.Color:GetColor("orange"):GetRGB())
		end
	else
		DungeonButtonFontString:SetText("No Event Dungeon")
		DungeonButtonFontString:SetTextColor(addonTable.Color:GetColor("gray"):GetRGB())
	end

	self:SetActive()
end



SLASH_HOLIDAY_FRAME1 = "/holidayframe"
SLASH_HOLIDAY_FRAME2 = "/hf"
SlashCmdList["HOLIDAY_FRAME"] = function()
	local isHolidayActive, inactiveReason = C_Holiday:IsActive()

	if not isHolidayActive then
		HolidayFrame:Hide()

		if inactiveReason then
			DEFAULT_CHAT_FRAME:AddMessage(inactiveReason)
		end

		return
	end

	if HolidayFrame:IsShown() then
		HolidayFrame:Hide()
	else
		HolidayFrame:Show()
	end
end





-- local doneToday, moneyAmount, moneyVar, experienceGained, experienceVar, numRewards, spellID = GetLFGDungeonRewards(dungeonID)
-- local dungeonName, typeID, subtypeID, minLevel, maxLevel, recLevel, minRecLevel, maxRecLevel, expansionLevel, groupID, textureFilename, difficulty, maxPlayers, description, isHoliday, bonusRepAmount, minPlayers, isTimeWalker, mapName, minGear = GetLFGDungeonInfo(dungeonIndex)

-- C_TransmogCollection.PlayerHasTransmog(56836)
