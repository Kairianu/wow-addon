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
