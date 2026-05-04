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

MovementSpeedFrame:SetSize(1, 1)
MovementSpeedFrame:SetPoint('Right', BagsBar, 'Left', -5, 1.5)

MovementSpeedFrame.SpeedFontString = MovementSpeedFrame:CreateFontString()
MovementSpeedFrame.SpeedFontString:SetFont('fonts/blei00d.ttf', 18, 'outline')
MovementSpeedFrame.SpeedFontString:SetPoint('center')
MovementSpeedFrame.SpeedFontString:SetTextColor(1, 0.82, 0)

hooksecurefunc(MovementSpeedFrame.SpeedFontString, 'SetText', function(self)
	self:GetParent():SetSize(self:GetSize())
end)

MovementSpeedFrame.onUpdateElapsed = 0
MovementSpeedFrame.onUpdateTimeout = 0.1
MovementSpeedFrame:SetScript('onUpdate', function(self, elapsed)
	self.onUpdateElapsed = self.onUpdateElapsed + elapsed

	if self.onUpdateElapsed < self.onUpdateTimeout then
		return
	end

	self.onUpdateElapsed = 0

	local movementSpeed = MovementSpeedAPI:GetCurrentMovementSpeed()

	if not canaccessvalue(movementSpeed) or movementSpeed == 0 then
		self.SpeedFontString:SetText()
	else
		local movementSpeedPercentString = MovementSpeedAPI:GetMovementSpeedPercentString(movementSpeed)

		self.SpeedFontString:SetText(movementSpeedPercentString)
	end
end)
