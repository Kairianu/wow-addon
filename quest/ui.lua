local addonName, addonData = ...


local QuestFrameIDText = QuestFrame:CreateFontString()
QuestFrameIDText:SetFont('fonts/frizqt__.ttf', 10)
QuestFrameIDText:SetPoint('center', QuestFrame.TopTileStreaks, -10, 0)
QuestFrameIDText:SetText('Quest ID:')

local QuestFrameIDEditBox = CreateFrame('editBox', nil, QuestFrame)
QuestFrameIDEditBox:SetAutoFocus(false)
QuestFrameIDEditBox:SetFont(QuestFrameIDText:GetFont())
QuestFrameIDEditBox:SetPoint('left', QuestFrameIDText, 'right', 3, 0)
QuestFrameIDEditBox:SetSize(50, 15)
QuestFrameIDEditBox:SetTextColor(1, 1, 1)

hooksecurefunc(QuestFrameIDEditBox, 'SetText', function(self, text)
	self.originalText = text
end)

QuestFrameIDEditBox:SetScript('onTextChanged', function(self)
	self:SetText(self.originalText)
end)

QuestFrameIDEditBox:SetScript('onEscapePressed', function(self)
	self:SetPropagateKeyboardInput(true)
end)

QuestFrameIDEditBox:SetScript('onEditFocusGained', function(self)
	self:SetPropagateKeyboardInput(false)
	self:HighlightText()
end)

local QuestFrameIDEventFrame = CreateFrame("frame")
QuestFrameIDEventFrame:RegisterEvent("QUEST_COMPLETE")
QuestFrameIDEventFrame:RegisterEvent("QUEST_DETAIL")
QuestFrameIDEventFrame:RegisterEvent("QUEST_FINISHED")
QuestFrameIDEventFrame:RegisterEvent("QUEST_PROGRESS")
QuestFrameIDEventFrame:SetScript("OnEvent", function(self, event)
	if event == "QUEST_FINISHED" then
		QuestFrameIDEditBox:SetText('')
	else
		QuestFrameIDEditBox:SetText(GetQuestID())
	end
end)






local QuestLogIDText = QuestMapFrame.DetailsFrame.BackFrame:CreateFontString()
QuestLogIDText:SetFont(QuestFrameIDText:GetFont())
QuestLogIDText:SetPoint('left', QuestMapFrame.DetailsFrame.BackFrame.BackButton, 'right', 50, 0)
QuestLogIDText:SetText('Quest ID:')

local QuestLogIDEditBox = CreateFrame('editBox', nil, QuestLogIDText:GetParent())
QuestLogIDEditBox:SetAutoFocus(false)
QuestLogIDEditBox:SetFont(QuestLogIDText:GetFont())
QuestLogIDEditBox:SetPoint('left', QuestLogIDText, 'right', 3, 0)
QuestLogIDEditBox:SetSize(50, 15)
QuestLogIDEditBox:SetTextColor(1, 1, 1)

hooksecurefunc(QuestLogIDEditBox, 'SetText', function(self, text)
	self.originalText = text
end)

QuestLogIDEditBox:SetScript('onEditFocusGained', function(self)
	self:SetPropagateKeyboardInput(false)
	self:HighlightText()
end)

QuestLogIDEditBox:SetScript('onEscapePressed', function(self)
	self:SetPropagateKeyboardInput(true)
end)

QuestLogIDEditBox:SetScript('onHide', function(self)
	self:SetText('')
end)

QuestLogIDEditBox:SetScript('onShow', function(self)
	self:SetText(C_QuestLog.GetSelectedQuest())
end)

QuestLogIDEditBox:SetScript('onTextChanged', function(self)
	if self.originalText then
		self:SetText(self.originalText)
	end
end)






-- addonData.CollectionsAPI:GetCollection('quest'):AddMixin('ui', function()end)












-- local SCALED_FRAMES = {
-- 	GossipFrame,
-- 	MerchantFrame,
-- 	QuestFrame,
-- }

-- for i, scaledFrame in ipairs(SCALED_FRAMES) do
-- 	scaledFrame:SetScale(scaledFrame:GetScale() + 0.2)
-- end




-- local Quest = {}
-- addonTable.Quest = Quest

-- function Quest:IsUnitOnQuest(questID, unit)
-- 	if not unit then
-- 		unit = "player"
-- 	end

-- 	for questLogIndex = 1, C_QuestLog.GetNumQuestLogEntries() do
-- 		local questLogInfo = C_QuestLog.GetInfo(questLogIndex)

-- 		if questID == questLogInfo.questID then
-- 			return true
-- 		end
-- 	end

-- 	return false
-- end

-- function Quest:IsQuestCompleted(...)
-- 	return addonTable.D_Quest:IsQuestCompleted(...)
-- end

-- function Quest:GetCompletedQuests(questIDs)
-- 	local completedQuests = {}

-- 	if type(questIDs) == "number" then
-- 		local questID = questIDs

-- 		if self:IsQuestCompleted(questID) then
-- 			table.insert(completedQuests, questID)
-- 		end
-- 	else
-- 		for _, questID in ipairs(questIDs) do
-- 			if self:IsQuestCompleted(questID) then
-- 				table.insert(completedQuests, questID)
-- 			end
-- 		end
-- 	end

-- 	return completedQuests
-- end

-- function Quest:GetObtainedQuests(questIDs, unit)
-- 	if not unit then
-- 		unit = "player"
-- 	end

-- 	local obtainedQuests = {}

-- 	if type(questIDs) == "number" then
-- 		local questID = questIDs

-- 		if self:IsUnitOnQuest(questID) then
-- 			table.insert(obtainedQuests, questID)
-- 		end
-- 	else
-- 		for _, questID in ipairs(questIDs) do
-- 			if self:IsUnitOnQuest(questID) then
-- 				table.insert(obtainedQuests, questID)
-- 			end
-- 		end
-- 	end

-- 	return obtainedQuests
-- end

-- function Quest:GetZoneWorldQuests(zoneID)
-- 	return C_TaskQuest.GetQuestsForPlayerByMapID(zoneID)
-- end

-- function Quest:GetAllPvPWorldQuests()
-- 	local foundQuestIDs = {}
-- 	local pvpWorldQuests = {}

-- 	local zoneIDs = addonTable.Map:GetContinentZoneIDs("dragonIsles")

-- 	for _, zoneID in ipairs(zoneIDs) do
-- 		local zoneWorldQuests = C_TaskQuest.GetQuestsForPlayerByMapID(zoneID)

-- 		if zoneWorldQuests then
-- 			for _, worldQuestInfo in ipairs(zoneWorldQuests) do
-- 				local worldQuestID = worldQuestInfo.questId

-- 				local questTagInfo = C_QuestLog.GetQuestTagInfo(worldQuestID)

-- 				if questTagInfo then
-- 					if questTagInfo.worldQuestType == Enum.QuestTagType.PvP then
-- 						if not foundQuestIDs[worldQuestID] then
-- 							foundQuestIDs[worldQuestID] = true

-- 							table.insert(pvpWorldQuests, worldQuestInfo)
-- 						end
-- 					end
-- 				end
-- 			end
-- 		end
-- 	end

-- 	return pvpWorldQuests
-- end


-- local pvpWorldQuests = Quest:GetAllPvPWorldQuests()

-- print(#pvpWorldQuests)

-- for _, questInfo in ipairs(pvpWorldQuests) do
-- 	print(C_QuestLog.GetTitleForQuestID(questInfo.questId))
-- end
