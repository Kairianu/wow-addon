local addonName, addonTable = ...


local Database = addonTable.Database



local function GetNPCIDFromGUID(guid)
	local guidInfo = {}

	for part in string.gmatch(guid, "[^-]+") do
		table.insert(guidInfo, part)
	end

	return guidInfo[6]
end



local EditBox = CreateFrame("EditBox", nil, UIParent)
EditBox:Hide()
EditBox:SetFont(addonTable.Font:GetDefaultFontFamily(), 12, "")
EditBox:SetMultiLine(true)
EditBox:SetPoint("Center", 0, 250)
EditBox:SetText("Test")
EditBox:SetTextColor(addonTable.Color:GetColor("white"):GetRGB())
EditBox:SetTextInsets(5, 5, 5, 5)
EditBox:SetWidth(250)

EditBox.Background = EditBox:CreateTexture()
EditBox.Background:SetAllPoints()
EditBox.Background:SetColorTexture(0, 0, 0)

hooksecurefunc(EditBox, "SetText", function(self, text)
	self.originalText = text
	self:Show()
	self:HighlightText()
end)

EditBox:RegisterEvent("PLAYER_STOPPED_MOVING")
EditBox:RegisterEvent("UNIT_TARGET")
EditBox:SetScript("OnEvent", function(self)
	if self:IsShown() then
		ShowNPCInfo()
	end
end)

EditBox:SetScript("OnShow", function(self)
	self:Disable()

	C_Timer.After(0.1, function()
		self:Enable()
	end)
end)

EditBox:SetScript("OnKeyUp", function(self, key)
	if IsControlKeyDown() then
		if key == "A" or key == "C" then
			return
		end
	end

	self:SetText(self.originalText)
end)

EditBox:SetScript("OnEscapePressed", function(self)
	self:Hide()
end)




function ShowNPCInfo()
	local npcGUID = UnitGUID("target")

	if not npcGUID then
		DEFAULT_CHAT_FRAME:AddMessage(SLASH_NPC_INFO1 .. ": |cffffcc00No target found|r")

		return
	end

	local npcID = GetNPCIDFromGUID(npcGUID)

	if not npcID then
		DEFAULT_CHAT_FRAME:AddMessage(SLASH_NPC_INFO1 .. ": |cffff0000Cannot get NPC ID|r")

		return
	end

	local npcName = UnitName("target")

	if not npcName then
		DEFAULT_CHAT_FRAME:AddMessage(SLASH_NPC_INFO1 .. ": |cffff0000Cannot get NPC name|r")

		return
	end

	local output = string.format("[%s] = {\n", npcID)

	local classID = select(3, UnitClass("target"))

	if classID ~= nil and classID ~= 1 then
		output = output .. string.format("\tclassID = %s,\n", classID)
	end

	local factionGroup = UnitFactionGroup("target")

	if factionGroup ~= nil then
		local factionID

		if factionGroup == "Alliance" then
			factionID = LE_QUEST_FACTION_ALLIANCE
		elseif factionGroup == "Horde" then
			factionID = LE_QUEST_FACTION_HORDE
		else
			factionID = "\"" .. factionGroup .. "\""
		end

		output = output .. string.format("\tfactionID = %s,\n", factionID)
	end

	output = output .. string.format("\tname = \"%s\",\n", npcName)

	output = output .. "\tpositions = {"

	local uiMapID = C_Map.GetBestMapForUnit("player")

	if uiMapID then
		output = output .. string.format("\n\t\t{\n\t\t\tuiMapID = %s,\n", uiMapID)

		local mapPosition = C_Map.GetPlayerMapPosition(uiMapID, "player")

		if mapPosition then
			local x, y = Database:FormatCoordinates(mapPosition.x, mapPosition.y)

			output = output .. string.format("\t\t\tx = %s,\n\t\t\ty = %s,\n", x, y)
		end

		output = output .. "\t\t},\n\t},\n"
	else
		output = output .. "},\n"
	end

	local npcRaceID = select(3, UnitRace("target"))

	if npcRaceID ~= nil then
		output = output .. string.format("\traceID = %s,\n", npcRaceID)
	end

	local npcSexID = UnitSex("target")

	if npcSexID ~= nil then
		output = output .. string.format("\tsexID = %s,\n", npcSexID)
	end

	output = output .. "},"

	EditBox:SetText(output)
end



SLASH_NPC_INFO1 = "/npcinfo"
SLASH_NPC_INFO2 = "/ni"
SlashCmdList["NPC_INFO"] = function()
	ShowNPCInfo()
end


SLASH_MAP_QUEST_INFO1 = "/mapquests"
SLASH_MAP_QUEST_INFO2 = "/mq"
SlashCmdList["MAP_QUEST_INFO"] = function()
	local uiMapID = C_QuestLog.GetMapForQuestPOIs()

	local quests = C_QuestLog.GetQuestsOnMap(uiMapID)

	for i, questData in ipairs(C_TaskQuest.GetQuestsForPlayerByMapID(uiMapID)) do
		questData.isTaskQuest = true

		table.insert(quests, questData)
	end

	for i, questData in ipairs(C_QuestLine.GetAvailableQuestLines(uiMapID)) do
		questData.isQuestLine = true

		table.insert(quests, questData)
	end

	table.sort(quests, function(left, right)
		local leftQuestID = left.questID or left.questId
		local rightQuestID = right.questID or right.questId

		return C_QuestLog.GetTitleForQuestID(leftQuestID) < C_QuestLog.GetTitleForQuestID(rightQuestID)
	end)

	DEFAULT_CHAT_FRAME:AddMessage("Map ID: " .. uiMapID)
	DEFAULT_CHAT_FRAME:AddMessage("Quest Count: " .. #quests)

	for i, questData in ipairs(quests) do
		local questID = questData.questID or questData.questId
		local questTypeIdentifier = ""

		if questData.isQuestLine then
			questTypeIdentifier = "L"
		elseif questData.isTaskQuest then
			questTypeIdentifier = "T"
		else
			questTypeIdentifier = "C"
		end

		DEFAULT_CHAT_FRAME:AddMessage("   " .. C_QuestLog.GetTitleForQuestID(questID) .. " (" .. questID .. ") [" .. questTypeIdentifier .. "]")
	end
end


SLASH_MINIMAP_RESIZE1 = "/minimapresize"
SLASH_MINIMAP_RESIZE2 = "/mmr"
SlashCmdList["MINIMAP_RESIZE"] = function()
	MinimapBackdrop:Hide()

	Minimap:ClearAllPoints()
	Minimap:SetPoint("Center", UIParent)
	Minimap:SetScale(Minimap:GetScale() + 0.6)
	Minimap:SetSize(700, 700)
end


local MODEL_FRAME

SLASH_SHOW_MODEL1 = "/showmodel"
SLASH_SHOW_MODEL2 = "/sm"
SlashCmdList["SHOW_MODEL"] = function(argString)
	argString = tonumber(argString)

	if argString then
		if not MODEL_FRAME then
			MODEL_FRAME = CreateFrame("PlayerModel")
			MODEL_FRAME:SetPoint("CENTER")
			MODEL_FRAME:SetSize(200, 200)
		end

		print(MODEL_FRAME:SetModel(argString))
	end
end
