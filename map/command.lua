local addonName, addonData = ...


local imports = {
	command = {
		api = {
			preLoad = true,
		},
	},
}

addonData.CollectionsAPI:GetCollection('map'):AddMixin('command', imports, function()
	imports.command.api:AddCommand(
		'MAP_POSITION_INFO',
		function()
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
				message = string.format(
					'%s%s Position Info|r',
					'|cffffd100', -- yellow
					mapPointType
				)

				if mapPosition then
					local continentID, worldPosition = C_Map.GetWorldPosFromMapPos(uiMapID, mapPosition)

					message = string.format(
						'%s%s\nContinent|r\n    %sid|r  %s\n    %sx|r   %s\n    %sy|r   %s',
						message,
						'|cff0099ff', -- blue
						'|cff00ccff', -- bluelight
						continentID,
						'|cff00ccff', -- bluelight
						worldPosition.x,
						'|cff00ccff',
						worldPosition.y
					)
				end

				message = string.format(
					'%s%s\nMap|r',
					message,
					'|cff0099ff' -- blue
				)

				local mapInfo = C_Map.GetMapInfo(uiMapID)

				if mapInfo then
					message = string.format(
						'%s%s:|r %s',
						message,
						'|cff0099ff',
						mapInfo.name
					)
				end

				message = string.format(
					'%s\n    %sid|r  %s',
					message,
					'|cff00ccff', -- bluelight
					uiMapID
				)

				if mapPosition then
					message = string.format(
						'%s\n    %sx|r   %s\n    %sy|r   %s',
						message,
						'|cff00ccff', -- bluelight
						mapPosition.x,
						'|cff00ccff', -- bluelight
						mapPosition.y
					)
				end
			else
				message = '|cffff0000Unable to get map info|r'
			end

			DEFAULT_CHAT_FRAME:AddMessage(message)
		end
	)


	-- TODO: This is old code
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

		if string.sub(arg1, 1, string.len('#')) == '#' then
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
end)
