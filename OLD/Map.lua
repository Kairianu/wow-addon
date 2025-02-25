local addonName, addonTable = ...



local CONTINENT_IDS = {
	dragonIsles = {
		2444,
		2454,
		2548,
	}
}


local ZONE_IDS = {
	dragonIsles = {
		2022,
		2023,
		2024,
		2025,
		2112,
		2133,
		2151,
		2200,
	}
}





local Map = {}
addonTable.Map = Map

Map.continentIDs = {
	dragonIsles = {
		[2444] = true,
		[2454] = true,
		-- [2512] = true,
		[2548] = true,
	},
}


function Map:IsOnContinent(continentIDTable)
	local uiMapID = C_Map.GetBestMapForUnit("player")

	if uiMapID then
		local mapPosition = C_Map.GetPlayerMapPosition(uiMapID, "player")

		if mapPosition then
			local continentID = C_Map.GetWorldPosFromMapPos(uiMapID, mapPosition)

			if continentIDTable[continentID] then
				return true
			end
		end
	end

	return false
end

function Map:GetContinentZoneIDs(continentName)
	return ZONE_IDS[continentName]
end


SLASH_POSITION_INFO1 = "/positioninfo"
SLASH_POSITION_INFO2 = "/pi"
SlashCmdList["POSITION_INFO"] = function()
	local mapPointType
	local mapPosition
	local uiMapID
	local waypointInfo = C_Map.GetUserWaypoint()

	if waypointInfo then
		mapPointType = "Waypoint"
		mapPosition = waypointInfo.position
		uiMapID = waypointInfo.uiMapID
	else
		mapPointType = "Player"
		uiMapID = C_Map.GetBestMapForUnit("player")

		if uiMapID then
			mapPosition = C_Map.GetPlayerMapPosition(uiMapID, "player")
		end
	end

	local message

	if mapPosition then
		message = addonTable.Color:WrapTextInColor("yellow", string.format("%s Position Info", mapPointType))

		if mapPosition then
			local continentID, worldPosition = C_Map.GetWorldPosFromMapPos(uiMapID, mapPosition)

			message = message .. addonTable.Color:WrapTextInColor("blue", "\nContinent:")
			message = message .. addonTable.Color:WrapTextInColor("bluelight", "\n    id  ") .. continentID
			message = message .. addonTable.Color:WrapTextInColor("bluelight", "\n    x   ") .. worldPosition.x
			message = message .. addonTable.Color:WrapTextInColor("bluelight", "\n    y   ") .. worldPosition.y
		end

		message = message .. addonTable.Color:WrapTextInColor("blue", "\nMap:")

		local mapInfo = C_Map.GetMapInfo(uiMapID)

		if mapInfo then
			message = message .. string.format(" %s", mapInfo.name)
		end

		message = message .. addonTable.Color:WrapTextInColor("bluelight", "\n    id  ") .. uiMapID

		if mapPosition then
			message = message .. addonTable.Color:WrapTextInColor("bluelight", "\n    x   ") .. mapPosition.x
			message = message .. addonTable.Color:WrapTextInColor("bluelight", "\n    y   ") .. mapPosition.y
		end
	else
		message = addonTable.Color:WrapTextInColor("red", "Unable to get map info")
	end

	DEFAULT_CHAT_FRAME:AddMessage(message)
end





SLASH_POSITION_TEST1 = "/pt"
SlashCmdList["POSITION_TEST"] = function()
	local worldX, worldY, worldZ, continentID = UnitPosition("player")

	local uiMapID, mapPosition1 = C_Map.GetMapPosFromWorldPos(continentID, {
		x = math.floor(worldX),
		y = math.floor(worldY),
	})

	print("Map Position:", mapPosition1:GetXY())


	local uiMapID = C_Map.GetBestMapForUnit("player")

	local mapPosition2 = C_Map.GetPlayerMapPosition(uiMapID, "player")

	local _, worldPosition = C_Map.GetWorldPosFromMapPos(uiMapID, mapPosition1)

	print("World Position:", math.floor(worldPosition.x), math.floor(worldPosition.y))


	local _, worldPosition2 = C_Map.GetWorldPosFromMapPos(uiMapID, mapPosition2)

	print("World Position 2:", math.floor(worldPosition.x), math.floor(worldPosition.y))
end
