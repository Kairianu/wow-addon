local addonName, addonData = ...

local BAR_TAB_BARREL_QUESTS = {
	[84305] = {
		location = {
			uiMapID = 2339,
			x = 44.09,
			y = 46.06,
		},
	},
}





-- UnitFullName()
-- UnitName()
-- UnitNameUnmodified()

-- npc
-- questnpc

local function getNPCInfo()
	local unitToken = "questnpc"
end

function ShowQuestInfo()
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



local EventFrame = CreateFrame("Frame")

EventFrame:RegisterEvent("QUEST_COMPLETE")
EventFrame:RegisterEvent("QUEST_DETAIL")
EventFrame:RegisterEvent("QUEST_PROGRESS")
EventFrame:SetScript("OnEvent", function(self, event)
	-- print(UnitGUID("npc"))
	-- print(UnitGUID("questnpc"))
end)
