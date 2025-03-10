local addonName, addonData = ...


local MovementSpeedAPI

local ImportLoadFrame = CreateFrame('frame')
ImportLoadFrame:RegisterEvent('ADDON_LOADED')
ImportLoadFrame:SetScript('onEvent', function(self, event, arg1)
	if arg1 == addonName then
		MovementSpeedAPI = addonData.CollectionsAPI:GetCollection('movementSpeed'):GetMixin('api')
	end
end)



local MovementSpeedFrame = CreateFrame('frame', nil, UIParent)

function MovementSpeedFrame:GetDefaultAnchorPoints()
	return {
		{'right', -5, 0},
		{'bottom', MicroButtonAndBagsBar, 'top', 0, 5},
	}
end

function MovementSpeedFrame:GetDragonridingAnchorPoints()
	return {
		{'top', EncounterBar, 'bottom', 0, 20},
	}
end

function MovementSpeedFrame:SetAnchorPoints(anchorPoints)
	self:ClearAllPoints()

	for _, anchorPoint in ipairs(anchorPoints) do
		self:SetPoint(unpack(anchorPoint))
	end
end

MovementSpeedFrame:SetAnchorPoints(MovementSpeedFrame:GetDefaultAnchorPoints())
MovementSpeedFrame:SetSize(1, 1)

MovementSpeedFrame.SpeedFontString = MovementSpeedFrame:CreateFontString()
MovementSpeedFrame.SpeedFontString:SetFont('fonts/blei00d.ttf', 18, 'outline')
MovementSpeedFrame.SpeedFontString:SetPoint('center')
MovementSpeedFrame.SpeedFontString:SetTextColor(1, 0.82, 0)

hooksecurefunc(MovementSpeedFrame.SpeedFontString, 'SetText', function(self)
	self:GetParent():SetSize(self:GetSize())
end)

MovementSpeedFrame:RegisterEvent('PLAYER_CAN_GLIDE_CHANGED')
MovementSpeedFrame:SetScript('onEvent', function(self, event, arg1)
	if event == 'PLAYER_CAN_GLIDE_CHANGED' then
		local anchorPoints

		if arg1 then
			anchorPoints = self:GetDragonridingAnchorPoints()
		else
			anchorPoints = self:GetDefaultAnchorPoints()
		end

		self:SetAnchorPoints(anchorPoints)
	end
end)

MovementSpeedFrame.onUpdateElapsed = 0
MovementSpeedFrame.onUpdateTimeout = 0.1
MovementSpeedFrame:SetScript('onUpdate', function(self, elapsed)
	self.onUpdateElapsed = self.onUpdateElapsed + elapsed

	if self.onUpdateElapsed < self.onUpdateTimeout then
		return
	end

	self.onUpdateElapsed = 0

	local isGliding, canGlide, glidingSpeed = C_PlayerInfo.GetGlidingInfo()

	local movementSpeed

	if isGliding then
		movementSpeed = glidingSpeed
	else
		movementSpeed = GetUnitSpeed('player')
	end

	if movementSpeed == 0 then
		self.SpeedFontString:SetText()
	else
		self.SpeedFontString:SetText(
			MovementSpeedAPI:GetMovementSpeedPercentString(movementSpeed)
		)
	end
end)
