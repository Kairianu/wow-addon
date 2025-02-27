local addonName, addonData = ...


local imports = {
	metrics = {
		api = true,
	},
}


addonData.CollectionsAPI:GetCollection('metrics'):AddMixin('ui', imports, function()
	local MetricsUI = CreateFrame('button', nil, UIParent)

	MetricsUI.textUpdateInterval = 0.3

	MetricsUI:Hide()
	MetricsUI:SetPoint('topLeft', 3, 0)
	MetricsUI:SetSize(1, 1)

	MetricsUI.PlayerDamageText = MetricsUI:CreateFontString()
	MetricsUI.PlayerDamageText:SetFont('Fonts/blei00d.ttf', 16)
	MetricsUI.PlayerDamageText:SetPoint('left')
	MetricsUI.PlayerDamageText:SetTextColor(1, 0.82, 0)

	hooksecurefunc(MetricsUI.PlayerDamageText, 'SetText', function()
		MetricsUI:ResizeToText()
	end)

	function MetricsUI.PlayerDamageText:OnClick()
		imports.metrics.api:ResetUnitDamage(UnitGUID('player'))

		MetricsUI:UpdateDamageText()
	end

	function MetricsUI:UpdateDamageText()
		local playerGUID = UnitGUID('player')

		local unitDamagePerSecond = math.floor(imports.metrics.api:GetUnitDamagePerSecond(playerGUID))

		if unitDamagePerSecond == 0 then
			self.PlayerDamageText:Hide()
			self.PlayerDamageText:SetText('')
		else
			local formattedUnitDamagePerSecond

			if ( unitDamagePerSecond > 1000000 ) then
				formattedUnitDamagePerSecond = math.floor(unitDamagePerSecond / 100000) / 10 .. 'm'
			elseif ( unitDamagePerSecond > 1000 ) then
				formattedUnitDamagePerSecond = math.floor(unitDamagePerSecond / 100) / 10 .. 'k'
			else
				formattedUnitDamagePerSecond = unitDamagePerSecond
			end

			self.PlayerDamageText:Show()
			self.PlayerDamageText:SetText(formattedUnitDamagePerSecond)
		end
	end

	function MetricsUI:ToggleDisplay()
		if self:IsShown() then
			self:Hide()
		else
			self:Show()
		end
	end

	function MetricsUI:GetFontStrings()
		return {
			self.PlayerDamageText,
		}
	end

	function MetricsUI:ResizeToText()
		local bottom
		local left
		local right
		local top

		for _, fontString in ipairs(self:GetFontStrings()) do
			local fontStringLeft, fontStringBottom, fontStringWidth, fontStringHeight = fontString:GetRect()

			local fontStringRight = fontStringLeft + fontStringWidth
			local fontStringTop = fontStringBottom + fontStringHeight

			if not bottom or fontStringBottom < bottom then
				bottom = fontStringBottom
			end

			if not left or fontStringLeft < left then
				left = fontStringLeft
			end

			if not right or fontStringRight > right then
				right = fontStringRight
			end

			if not top or fontStringTop > top then
				top = fontStringTop
			end
		end

		local height = top - bottom
		local width = right - left

		self:SetSize(width, height)
	end

	MetricsUI.onUpdateElapsed = 0
	function MetricsUI:OnUpdate(elapsed)
		self.onUpdateElapsed = self.onUpdateElapsed + elapsed

		if self.onUpdateElapsed < self.textUpdateInterval then
			return
		end

		self:UpdateDamageText()

		self.onUpdateElapsed = 0
	end



	MetricsUI:RegisterForClicks('AnyUp')
	MetricsUI:SetScript('onClick', function(self, button)
		if button == 'LeftButton' then
			for _, fontString in ipairs(self:GetFontStrings()) do
				if fontString:IsMouseOver() then
					if type(fontString.OnClick) == 'function' then
						fontString:OnClick(button)
					end
				end
			end
		elseif button == 'RightButton' then
			self:ToggleDisplay()
		end
	end)

	MetricsUI:SetScript('onUpdate', MetricsUI.OnUpdate)


	return MetricsUI
end)
