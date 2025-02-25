local addonName, addonTable = ...


local EVENT_TITLE = "Brewfest"

local DUNGEON_ID = 287

local QUESTS_INFO = addonTable.database.quest





local Brewfest = {}
addonTable.Brewfest = Brewfest

function Brewfest:Initialize()
	local isEventActive = true -- addonTable.Calendar:IsEventActive(EVENT_TITLE)

	if not isEventActive then
		return
	end

	local BrewfestFrame = CreateFrame("Frame", nil, UIParent)
	Brewfest.BrewfestFrame = BrewfestFrame
	BrewfestFrame:Hide()
	BrewfestFrame:SetPoint("Bottom", 0, 200)
	BrewfestFrame:SetPoint("Right", -5, 0)
	BrewfestFrame:SetSize(200, 0.00001)

	function BrewfestFrame:ResizeToContent()
		local _, titleBottom, _, titleHeight = self.TitleText:GetRect()
		local titleTop = titleBottom + titleHeight

		local _, questContainerBottom = self.QuestContainer:GetRect()

		self:SetHeight(titleTop - questContainerBottom)
	end

	addonTable.C_FrameHide:SetupFrame(BrewfestFrame, {
		hiddenAlpha = 0.2,
	})

	local TitleText = BrewfestFrame:CreateFontString()
	BrewfestFrame.TitleText = TitleText
	TitleText:SetFont(addonTable.Font:GetDefaultFontFamily(), 17, "Outline")
	TitleText:SetPoint("Top")
	TitleText:SetText(EVENT_TITLE)
	TitleText:SetTextColor(addonTable.Color:GetColor("yellow"):GetRGB())

	local DungeonButton = CreateFrame("Button", nil, BrewfestFrame)
	BrewfestFrame.DungeonButton = DungeonButton

	DungeonButton:SetPoint("Left")
	DungeonButton:SetPoint("Right")
	DungeonButton:SetPoint("Top", TitleText, "Bottom", 0, -5)

	local doneToday, moneyAmount, moneyVar, experienceGained, experienceVar, numRewards, spellID = GetLFGDungeonRewards(DUNGEON_ID)

	if doneToday then
		DungeonButton:SetHeight(0.00001)
	else
		DungeonButton:SetText("Queue for Dungeon")

		DungeonButton:GetFontString():SetFont(addonTable.Font:GetDefaultFontFamily(), 13, "Outline")
		DungeonButton:GetFontString():SetTextColor(addonTable.Color:GetColor("blue"):GetRGB())

		DungeonButton:SetSize(DungeonButton:GetFontString():GetSize())

		DungeonButton:SetScript("OnClick", function()
			addonTable.C_LFG:JoinDungeon(DUNGEON_ID)
		end)
	end

	local QuestHeader = BrewfestFrame:CreateFontString()
	BrewfestFrame.QuestHeader = QuestHeader
	QuestHeader:SetFont(addonTable.Font:GetDefaultFontFamily(), 13, "Outline")
	QuestHeader:SetJustifyH("Left")
	QuestHeader:SetPoint("Left")
	QuestHeader:SetPoint("Right")
	QuestHeader:SetPoint("Top", DungeonButton, "Bottom", 0, -5)
	QuestHeader:SetText("Quests")
	QuestHeader:SetTextColor(addonTable.Color:GetColor("yellow"):GetRGB())

	local QuestContainer = CreateFrame("Frame", nil, BrewfestFrame)
	BrewfestFrame.QuestContainer = QuestContainer

	QuestContainer.buttonYOffset = -3
	QuestContainer.maxButtonWidth = BrewfestFrame:GetWidth()
	QuestContainer.totalButtonHeight = 0

	QuestContainer:SetHeight(0.00001)
	QuestContainer:SetPoint("Left", 5, 0)
	QuestContainer:SetPoint("Right")
	QuestContainer:SetPoint("Top", QuestHeader, "Bottom", 0, -3)

	QuestContainer.questButtons = {}

	QuestContainer:RegisterEvent("QUEST_LOG_UPDATE")
	QuestContainer:SetScript("OnEvent", function(self, event)
		self.availableQuestIDs = {}

		for questID, questData in pairs(QUESTS_INFO) do
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
			BrewfestFrame:Hide()

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

		BrewfestFrame:SetWidth(self.maxButtonWidth)

		BrewfestFrame:ResizeToContent()
	end)

	function QuestContainer:ClearQuestButtons()
		for i, QuestButton in ipairs(self.questButtons) do
			QuestButton:Hide()
			QuestButton:SetText()
		end

		self.maxButtonWidth = 200
		self.totalButtonHeight = 0
	end

	function QuestContainer:SetQuestButton(questButtonIndex, questID, questData)
		local questTitle = C_QuestLog.GetTitleForQuestID(questID)

		if not questTitle then
			return
		end

		local QuestButton = self.questButtons[questButtonIndex]

		if not QuestButton then
			QuestButton = QuestContainer:CreateQuestButton(questID, questData)
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

	function QuestContainer:CreateQuestButton(questID, questData)
		local QuestButton = CreateFrame("Button", nil, QuestContainer)

		table.insert(QuestContainer.questButtons, QuestButton)

		if #QuestContainer.questButtons == 1 then
			QuestButton:SetPoint("Top")
		else
			QuestButton:SetPoint("Top", QuestContainer.questButtons[#QuestContainer.questButtons - 1], "Bottom", 0, self.buttonYOffset)
		end

		QuestButton:SetPoint("Left")
		QuestButton:SetPoint("Right")

		QuestButton:SetScript("OnClick", function(self)
			local location = QUESTS_INFO[self.questID].location

			if location then
				C_Map.SetUserWaypoint(UiMapPoint.CreateFromCoordinates(location.uiMapID, location.x, location.y))
				C_SuperTrack.SetSuperTrackedUserWaypoint(true)
			end
		end)

		return QuestButton
	end

	for questID, questData in pairs(QUESTS_INFO) do
		C_QuestLog.RequestLoadQuestByID(questID)
	end
end



addonTable.Calendar:UpdateEventList(Brewfest.Initialize, Brewfest)



SLASH_BREWFEST_QUESTS1 = "/bf"
SlashCmdList["BREWFEST_QUESTS"] = function()
	local BrewfestFrame = Brewfest.BrewfestFrame

	if BrewfestFrame then
		if BrewfestFrame:IsShown() then
			BrewfestFrame:Hide()
		else
			BrewfestFrame:Show()
		end
	end
end
