local addonName, addonTable = ...

local INITIAL_TIMESTAMP = 1685037600
local SPAWN_DURATION = 360
local SPAWN_INTERVAL = 1800
local ZONE_ROTATION = {
	84,	-- Stormwind
	2023,	-- Ohn'ahran Plains
	85,	-- Orgrimmar
	2024,	-- The Azure Span
	84,	-- Stormwind
	2025,	-- Thaldraszus
	85,	-- Orgrimmar
	2112,	-- Valdrakken
	84,	-- Stormwind
	2022,	-- The Waking Shores
	85,	-- Orgrimmar
	2023,	-- Ohn'ahran Plains
	84,	-- Stormwind
	2024,	-- The Azure Span
	85,	-- Orgrimmar
	2025,	-- Thaldraszus
	84,	-- Stormwind
	2112,	-- Valdrakken
	85,	-- Orgrimmar
	2022,	-- The Waking Shores
}

local function ValidateIndex(index)
	index = index % #ZONE_ROTATION

	if index == 0 then
		index = #ZONE_ROTATION
	end

	return index
end

local function GetZoneNameFromIndex(index)
	return C_Map.GetMapInfo(ZONE_ROTATION[ValidateIndex(index)]).name
end


local GreedyEmissaryFrame = CreateFrame("Frame", nil, UIParent)

GreedyEmissaryFrame.textColors = {
	default = addonTable.Color:GetColor("yellow"),
	green = addonTable.Color:GetColor("green"),
}

GreedyEmissaryFrame:SetPoint("TopRight", BuffFrame, "TopLeft")
GreedyEmissaryFrame:SetSize(100, 50)

local function fd(t)
	for key, value in pairs(t) do
		if v and v.GetText then
			print(v:GetText())
		else
			pcall(fd, v)
		end
	end
end

GreedyEmissaryFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
GreedyEmissaryFrame:SetScript("OnEvent", function(self, event, namePlateUnitToken)
	local nameplate = C_NamePlate.GetNamePlateForUnit(namePlateUnitToken)

	if namePlateUnitToken == "nameplate1" then
		-- pcall(fd, nameplate.UnitFrame.WidgetContainer)
	end
end)

GreedyEmissaryFrame.SpawnTimeText = GreedyEmissaryFrame:CreateFontString()
GreedyEmissaryFrame.SpawnTimeText:SetFont(addonTable.Font:GetDefaultFontFamily(), 14, "Outline")
GreedyEmissaryFrame.SpawnTimeText:SetPoint("Top")
GreedyEmissaryFrame.SpawnTimeText:SetTextColor(GreedyEmissaryFrame.textColors.default:GetRGB())

GreedyEmissaryFrame.PreviousLocationText = GreedyEmissaryFrame:CreateFontString()
GreedyEmissaryFrame.PreviousLocationText:SetFont(addonTable.Font:GetDefaultFontFamily(), 12, "Outline")
GreedyEmissaryFrame.PreviousLocationText:SetPoint("Top", GreedyEmissaryFrame.SpawnTimeText, "Bottom")
GreedyEmissaryFrame.PreviousLocationText:SetTextColor(addonTable.Color:GetColor("gray"):GetRGB())

GreedyEmissaryFrame.UpcomingLocationText = GreedyEmissaryFrame:CreateFontString()
GreedyEmissaryFrame.UpcomingLocationText:SetFont(addonTable.Font:GetDefaultFontFamily(), 14, "Outline")
GreedyEmissaryFrame.UpcomingLocationText:SetPoint("Top", GreedyEmissaryFrame.PreviousLocationText, "Bottom")
GreedyEmissaryFrame.UpcomingLocationText:SetTextColor(GreedyEmissaryFrame.textColors.default:GetRGB())

GreedyEmissaryFrame.NextLocationText = GreedyEmissaryFrame:CreateFontString()
GreedyEmissaryFrame.NextLocationText:SetFont(addonTable.Font:GetDefaultFontFamily(), 12, "Outline")
GreedyEmissaryFrame.NextLocationText:SetPoint("Top", GreedyEmissaryFrame.UpcomingLocationText, "Bottom")
GreedyEmissaryFrame.NextLocationText:SetTextColor(addonTable.Color:GetColor("white"):GetRGB())

addonTable.C_FrameHide:SetupFrame(GreedyEmissaryFrame)


C_Timer.NewTicker(1, function()
	local secondsSinceInitalSpawn = GetServerTime() - INITIAL_TIMESTAMP

	local secondsUntilNextSpawn = SPAWN_INTERVAL - secondsSinceInitalSpawn % SPAWN_INTERVAL

	local upcomingZoneIndex = math.floor(secondsSinceInitalSpawn / SPAWN_INTERVAL % #ZONE_ROTATION)

	local minutesRemaining
	local secondsRemaining
	local textColor

	if secondsUntilNextSpawn < SPAWN_INTERVAL - SPAWN_DURATION then
		minutesRemaining = math.floor(secondsUntilNextSpawn / 60)
		secondsRemaining = secondsUntilNextSpawn % 60
		textColor = GreedyEmissaryFrame.textColors.default
	else
		upcomingZoneIndex = upcomingZoneIndex - 1

		local secondsRemainingForSpawn = SPAWN_DURATION - (SPAWN_INTERVAL - secondsUntilNextSpawn)

		minutesRemaining = math.floor(secondsRemainingForSpawn / 60)
		secondsRemaining = secondsRemainingForSpawn % 60
		textColor = GreedyEmissaryFrame.textColors.green

		addonTable.C_FrameHide:ShowFrame(GreedyEmissaryFrame, true)
	end

	if secondsRemaining < 10 then
		secondsRemaining = "0" .. secondsRemaining
	end

	local previousZoneIndex = upcomingZoneIndex - 1
	local nextZoneIndex = upcomingZoneIndex + 1

	GreedyEmissaryFrame.SpawnTimeText:SetText(minutesRemaining .. ":" .. secondsRemaining)
	GreedyEmissaryFrame.SpawnTimeText:SetTextColor(textColor:GetRGB())

	GreedyEmissaryFrame.PreviousLocationText:SetText(GetZoneNameFromIndex(previousZoneIndex))

	GreedyEmissaryFrame.UpcomingLocationText:SetText(GetZoneNameFromIndex(upcomingZoneIndex) .. " (" .. ValidateIndex(upcomingZoneIndex) .. ")")
	GreedyEmissaryFrame.UpcomingLocationText:SetTextColor(textColor:GetRGB())

	GreedyEmissaryFrame.NextLocationText:SetText(GetZoneNameFromIndex(nextZoneIndex))
end)
