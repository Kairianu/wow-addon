local addonName, addonTable = ...


local WORLD_MAP_SCROLL_FRAME = WorldMapFrame.ScrollContainer.Child



local function StringStartsWith(str, prefix)
	return string.sub(str, 1, string.len(prefix)) == prefix
end



local MinimapCoordinateText = MinimapCluster:CreateFontString()
MinimapCoordinateText:SetFont(addonTable.Font:GetDefaultFontFamily(), addonTable.Font:GetFontSize(), "OUTLINE")
MinimapCoordinateText:SetPoint("Top", Minimap, "Bottom", -2, -11)
MinimapCoordinateText:SetHeight(11)
MinimapCoordinateText:SetTextColor(addonTable.Color:GetColor("yellow"):GetRGB())

local MapMouseCoordinateText = WorldMapFrame.BorderFrame.TitleContainer:CreateFontString()
MapMouseCoordinateText:SetFont(addonTable.Font:GetDefaultFont())
MapMouseCoordinateText:SetPoint("Left", WorldMapFrame.BorderFrame.Tutorial, "Right", 0, 2)

local MapCoordinateText = WorldMapFrame.BorderFrame.TitleContainer:CreateFontString()
MapCoordinateText:SetFont(addonTable.Font:GetDefaultFont())
MapCoordinateText:SetPoint("Center", MapMouseCoordinateText)
MapCoordinateText:SetPoint("Right", WorldMapFrame.BorderFrame.MaximizeMinimizeFrame, "Left", -12, 0)



local function UpdateCoordinateText()
	local coordinates = addonTable.C_Movement:GetPlayerCoordinates()

	if not coordinates then
		return
	end

	local coordText = addonTable.C_Coordinates:GetFormattedCoordsText(coordinates:GetXY())

	MinimapCoordinateText:SetText(coordText)
	MapCoordinateText:SetText(coordText)
end

local function UpdateMapMouseCoordinateText()
	local cursorX, cursorY = GetCursorPosition()

	local mapFrameScaledLeft, mapFrameScaledBottom, mapFrameScaledWidth, mapFrameScaledHeight = WORLD_MAP_SCROLL_FRAME:GetScaledRect()

	local playerPositionX = (cursorX - mapFrameScaledLeft) / mapFrameScaledWidth
	local playerPositionY = 1 - ((cursorY - mapFrameScaledBottom) / mapFrameScaledHeight)

	local coordText = addonTable.C_Coordinates:GetFormattedCoordsText(playerPositionX, playerPositionY)

	MapMouseCoordinateText:SetText(coordText)
end



local EventFrame = CreateFrame("EventFrame")

EventFrame.OnUpdate = function()
	if IsPlayerMoving() then
		UpdateCoordinateText()
	end

	if MouseIsOver(WORLD_MAP_SCROLL_FRAME) then
		UpdateMapMouseCoordinateText()
	end
end

-- function EventFrame:CheckOnUpdate()
-- 	if IsPlayerMoving() or MouseIsOver(WORLD_MAP_SCROLL_FRAME) then
-- 		self:SetScript("OnUpdate", self.OnUpdate)
-- 	else
-- 		self:SetScript("OnUpdate", nil)
-- 	end
-- end

EventFrame:SetScript("OnUpdate", EventFrame.OnUpdate)

EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
EventFrame:RegisterEvent("PLAYER_STARTED_MOVING")
EventFrame:RegisterEvent("PLAYER_STOPPED_MOVING")
EventFrame:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_ENTERING_WORLD" then
		UpdateCoordinateText()
	-- else
	-- 	self:CheckOnUpdate()
	end
end)





local C_Coordinates = {}
addonTable.C_Coordinates = C_Coordinates

function C_Coordinates:GetFormattedCoordsText(x, y)
	return string.format("%.2f %.2f", x * 100, y * 100)
end



SLASH_SETWAYPOINT1 = "/way"
SlashCmdList["SETWAYPOINT"] = function(argString)
	if argString == "" then
		C_Map.ClearUserWaypoint()
		return
	end

	local argTable = {}

	for arg in string.gmatch(argString, "[^%s]+") do
		table.insert(argTable, arg)
	end

	local x
	local y
	local uiMapID

	local arg1 = argTable[1]

	if StringStartsWith(arg1, "#") then
		uiMapID = string.sub(arg1, 2)
		x = argTable[2]
		y = argTable[3]
	else
		uiMapID = C_Map.GetBestMapForUnit("player")
		x = arg1
		y = argTable[2]
	end

	x = x:gsub("[^0-9.]", "")
	x = tonumber(x)

	y = y:gsub("[^0-9.]", "")
	y = tonumber(y)

	if not C_Map.CanSetUserWaypointOnMap(uiMapID) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffff0000Cannot set waypoint|r")
		return
	end

	C_Map.SetUserWaypoint(UiMapPoint.CreateFromCoordinates(uiMapID, x / 100, y / 100))
	C_SuperTrack.SetSuperTrackedUserWaypoint(true)
end

SLASH_PLAYER_POSITION1 = "/playerposition"
SLASH_PLAYER_POSITION2 = "/pp"
SlashCmdList["PLAYER_POSITION"] = function()
	local uiMapID = C_Map.GetBestMapForUnit("player")

	if uiMapID then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Position|r")
		DEFAULT_CHAT_FRAME:AddMessage("  |cff00ccffuiMapID:|r " .. uiMapID)

		local mapPosition = C_Map.GetPlayerMapPosition(uiMapID, "player")

		if mapPosition then
			local coordsText = C_Coordinates:GetFormattedCoordsText(mapPosition.x, mapPosition.y)

			DEFAULT_CHAT_FRAME:AddMessage("  |cffffff00Coordinates:|r " .. coordsText)
		end
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffff8800Cannot get player position|r")
	end
end


local CHANNEL_TYPES = {
	CHANNEL = true,
	GUILD = true,
	INSTANCE_CHAT = true,
	OFFICER = true,
	PARTY = true,
	RAID = true,
	SAY = true,
	WHISPER = true,
	YELL = true,
}


SHARE_LOCATION_ERROR_MESSAGE = addonTable.Color:WrapTextInColor("red", "Unable to share your current location.")
SLASH_SHARE_LOCATION1 = "/sharelocation"
SLASH_SHARE_LOCATION2 = "/sl"
SlashCmdList["SHARE_LOCATION"] = function(argString)
	local args = {}

	for arg in string.gmatch(argString, "[^%s]+") do
		table.insert(args, arg)
	end

	local channelTarget
	local channelType = args[1]
	local messageStartIndex = 1

	if channelType then
		channelType = string.upper(channelType)

		if CHANNEL_TYPES[channelType] then
			messageStartIndex = messageStartIndex + 1

			if args[2] then
				if channelType == "CHANNEL" then
					channelTarget = tonumber(args[2])
				elseif channelType == "WHISPER" then
					channelTarget = args[2]
				end

				if channelTarget then
					messageStartIndex = messageStartIndex + 1
				end
			end
		else
			channelType = nil
		end
	end

	if not channelType then
		channelType = "CHANNEL"
	end

	if not channelTarget then
		if channelType == "CHANNEL" then
			channelTarget = 1
		elseif channelType == "WHISPER" then
			DEFAULT_CHAT_FRAME:AddMessage(addonTable.Color:WrapTextInColor("red", "Must provide whisper target."))

			return
		end
	end

	local message = ""

	for messageIndex = messageStartIndex, #args do
		if message ~= "" then
			message = message .. " "
		end

		message = message .. args[messageIndex]
	end

	local uiMapID = C_Map.GetBestMapForUnit("player")

	if not C_Map.CanSetUserWaypointOnMap(uiMapID) then
		DEFAULT_CHAT_FRAME:AddMessage(SHARE_LOCATION_ERROR_MESSAGE)

		return
	end

	local mapPosition = C_Map.GetPlayerMapPosition(uiMapID, "player")

	if not mapPosition then
		DEFAULT_CHAT_FRAME:AddMessage(SHARE_LOCATION_ERROR_MESSAGE)

		return
	end

	local originalUIMapPoint = C_Map.GetUserWaypoint()

	local uiMapPoint = UiMapPoint.CreateFromCoordinates(uiMapID, mapPosition.x, mapPosition.y)

	C_Map.SetUserWaypoint(uiMapPoint)

	local waypointHyperlink = C_Map.GetUserWaypointHyperlink()

	if message then
		message = string.format("%s %s", message, waypointHyperlink)
	else
		message = waypointHyperlink
	end

	SendChatMessage(message, channelType, nil, channelTarget)

	if originalUIMapPoint then
		C_Map.SetUserWaypoint(originalUIMapPoint)
	else
		C_Map.ClearUserWaypoint()
	end
end
