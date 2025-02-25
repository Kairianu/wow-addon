local addonName, addonTable = ...


local PLAYER_UNIT_TOKEN = "player"



local function GetSpeedPercent(speed)
	speed = speed - BASE_MOVEMENT_SPEED

	local speedPercent = addonTable.Math:Round(speed / BASE_MOVEMENT_SPEED * 100)

	local speedPercentString = speedPercent .. "%"

	return speedPercent, speedPercentString
end


local C_Movement = {}
addonTable.C_Movement = C_Movement

function C_Movement:IsPlayerMoving()
	return self.playerMoving
end

function C_Movement:GetPlayerCoordinates()
	local uiMapID = C_Map.GetBestMapForUnit(PLAYER_UNIT_TOKEN)

	if uiMapID then
		return C_Map.GetPlayerMapPosition(uiMapID, PLAYER_UNIT_TOKEN)
	end
end



local SpeedFrame = CreateFrame("Frame", nil, UIParent)
SpeedFrame.elapsedTotal = 0
SpeedFrame.topSpeed = 0
SpeedFrame.topSpeedResetElapsed = 0
SpeedFrame.topSpeedResetTimeout = 10
SpeedFrame.totalYardsMoved = 0
SpeedFrame.updateInterval = 0.25

SpeedFrame:SetSize(1, 1)

SpeedFrame.SpeedText = SpeedFrame:CreateFontString()
SpeedFrame.SpeedText:SetPoint("Center")
SpeedFrame.SpeedText:SetFont(addonTable.Font:GetDefaultFontFamily(), addonTable.Font:GetFontSize(1.2), "OUTLINE")
SpeedFrame.SpeedText:SetTextColor(addonTable.Color:GetColor("yellow"):GetRGB())

SpeedFrame.TopSpeedButton = CreateFrame("Button", nil, SpeedFrame)
SpeedFrame.TopSpeedButton:SetPoint("Top", SpeedFrame.SpeedText, "Bottom")

SpeedFrame.TopSpeedButton:SetText("-")
SpeedFrame.TopSpeedButton:GetFontString():SetFont(addonTable.Font:GetDefaultFontFamily(), 12, "OUTLINE")
SpeedFrame.TopSpeedButton:GetFontString():SetTextColor(addonTable.Color:GetColor("gray"):GetRGB())
SpeedFrame.TopSpeedButton:SetText("")

hooksecurefunc(SpeedFrame.TopSpeedButton, "SetText", function(self)
	self:SetSize(self:GetFontString():GetSize())
end)

SpeedFrame.TopSpeedButton:SetScript("OnClick", function(self)
	self:GetParent():SetTopSpeed(0)
end)

function SpeedFrame:GetDefaultPoints()
	return {
		{"Right"},
		{"Bottom", MicroButtonAndBagsBar, "Top", 0, 5},
	}
end

function SpeedFrame:GetDragonridingPoints()
	return {
		{"Top", EncounterBar, "Bottom", 0, 20},
	}
end

function SpeedFrame:GetMapWorldSize()
	local uiMapID = C_Map.GetBestMapForUnit(PLAYER_UNIT_TOKEN)

	if uiMapID then
		return C_Map.GetMapWorldSize(uiMapID)
	end
end

function SpeedFrame:GetCoordinateSpeed(elapsed)
	self.elapsedTotal = self.elapsedTotal + elapsed

	if self.elapsedTotal < self.updateInterval then
		return
	end

	local currentMapCoordinates = C_Movement:GetPlayerCoordinates()

	if not currentMapCoordinates then
		return
	end

	local totalYardsX, totalYardsY = self:GetMapWorldSize()

	if not totalYardsX or not totalYardsY then
		return
	end

	local totalYardsPerSecond

	if self.previousMapCoordinates then
		local diffYardsX = math.abs(currentMapCoordinates.x - self.previousMapCoordinates.x) * totalYardsX
		local diffYardsY = math.abs(currentMapCoordinates.y - self.previousMapCoordinates.y) * totalYardsY

		local totalYardsMoved = math.sqrt(math.pow(diffYardsX, 2) + math.pow(diffYardsY, 2))

		if totalYardsMoved > 0 then
			C_Movement.playerMoving = true
		else
			C_Movement.playerMoving = false
		end

		local totalAdjustedPercentage = self.updateInterval / self.elapsedTotal
		local totalPerSecondMultiplier = 1 / self.updateInterval

		local totalYardsAdjusted = totalYardsMoved * totalAdjustedPercentage

		totalYardsPerSecond = math.floor(totalYardsAdjusted * totalPerSecondMultiplier)

		self.elapsedTotal = 0
	end

	self.previousMapCoordinates = currentMapCoordinates

	return totalYardsPerSecond
end

function SpeedFrame:SetTopSpeed(value)
	self.topSpeed = value

	self.TopSpeedButton:SetText(select(2, GetSpeedPercent(value)))
end

SpeedFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
SpeedFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
SpeedFrame:SetScript("OnEvent", function(self)
	self.previousMapCoordinates = C_Movement:GetPlayerCoordinates()
end)

SpeedFrame:SetScript("OnUpdate", function(self, elapsed)
	local isGliding, canGlide, glideSpeed = C_PlayerInfo.GetGlidingInfo()

	local speed

	if isGliding then
		speed = glideSpeed
	else
		speed = GetUnitSpeed("player")
	end

	if speed == 0 then
		self.topSpeedResetElapsed = self.topSpeedResetElapsed + elapsed

		if self.topSpeedResetElapsed >= self.topSpeedResetTimeout then
			self.topSpeedResetElapsed = 0

			self:SetTopSpeed(0)
		end
	else
		self.topSpeedResetElapsed = 0

		addonTable.C_FrameHide:ShowFrame(self)
	end

	self.SpeedText:SetText(select(2, GetSpeedPercent(speed)))

	if speed > self.topSpeed then
		self:SetTopSpeed(speed)
	end

	local points

	if canGlide then
		points = self:GetDragonridingPoints()
	else
		points = self:GetDefaultPoints()
	end

	self:ClearAllPoints()

	for _, point in ipairs(points) do
		self:SetPoint(unpack(point))
	end

	local width = math.max(self.SpeedText:GetWidth(), self.TopSpeedButton:GetWidth())
	local height = self.SpeedText:GetHeight() + self.TopSpeedButton:GetHeight()

	self:SetSize(width, height)
end)



addonTable.C_FrameHide:SetupFrame(SpeedFrame)




local StaticChargeFrame = CreateFrame("Frame", nil, EncounterBar)
StaticChargeFrame:SetPoint("Left", -20, 0)
StaticChargeFrame:SetSize(1, 1)

StaticChargeFrame.Text = StaticChargeFrame:CreateFontString()
StaticChargeFrame.Text.defaultFontColor = addonTable.Color:GetColor("blue")
StaticChargeFrame.Text.fullFontColor = addonTable.Color:GetColor("green")
StaticChargeFrame.Text:SetPoint("Center")
StaticChargeFrame.Text:SetFont(addonTable.Font:GetDefaultFontFamily(), addonTable.Font:GetFontSize(2))
StaticChargeFrame.Text:SetTextColor(StaticChargeFrame.Text.defaultFontColor:GetRGB())

function StaticChargeFrame:SetText(text)
	self.Text:SetText(text)

	if self.Text:GetText() == "0" then
		self:Hide()
	else
		self:Show()
	end

	if self.Text:GetText() == "10" then
		self.Text:SetTextColor(StaticChargeFrame.Text.fullFontColor:GetRGB())
	else
		self.Text:SetTextColor(StaticChargeFrame.Text.defaultFontColor:GetRGB())
	end

	self:SetSize(self.Text:GetSize())
end

StaticChargeFrame:RegisterEvent("UNIT_AURA")
StaticChargeFrame:SetScript("OnEvent", function(self, event, arg1, arg2)
	if event == "UNIT_AURA" then
		if arg1 == "player" then
			local staticChargeAuraData = C_UnitAuras.GetPlayerAuraBySpellID(418590)

			if staticChargeAuraData then
				self:SetText(staticChargeAuraData.applications)
			else
				self:SetText(0)
			end
		end
	end
end)

StaticChargeFrame:SetText("0")
