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
end)
