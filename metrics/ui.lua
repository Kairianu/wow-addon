local addonName, addonData = ...


local imports = {
	metrics = {
		api = true,
	},
}


addonData.CollectionsAPI:GetCollection('metrics'):AddMixin('ui', imports, function()
	local MetricsUI = CreateFrame('frame', nil, UIParent)

	MetricsUI:SetPoint('topLeft', 3, 0)
	MetricsUI:SetSize(1, 1)

	MetricsUI.PlayerDamageText = CreateFrame('button', nil, MetricsUI)
	MetricsUI.PlayerDamageText:SetPoint('left')
	MetricsUI.PlayerDamageText:SetText('-')
	MetricsUI.PlayerDamageText:GetFontString():SetFont('Fonts/blei00d.ttf', 16)
	MetricsUI.PlayerDamageText:GetFontString():SetTextColor(1, 0.82, 0)

	hooksecurefunc(MetricsUI.PlayerDamageText, 'SetText', function(self)
		self:SetSize(self:GetFontString():GetSize())

		MetricsUI:ResizeToText()
	end)

	MetricsUI.PlayerDamageText:SetScript("onClick", function()
		imports.metrics.api:ResetUnitDamage(UnitGUID('player'))
	end)


	function MetricsUI:UpdateDamageText()
		local playerGUID = UnitGUID('player')

		local unitDamagePerSecond = math.floor(imports.metrics.api:GetUnitDamagePerSecond(playerGUID))

		if unitDamagePerSecond == 0 then
			self.PlayerDamageText:Hide()
			self.PlayerDamageText:SetText('')
		else
			local formattedUnitDamagePerSecond

			if ( unitDamagePerSecond > 1000000 ) then
				formattedUnitDamagePerSecond = math.floor(unitDamagePerSecond / 100000) / 10 .. "m"
			elseif ( unitDamagePerSecond > 1000 ) then
				formattedUnitDamagePerSecond = math.floor(unitDamagePerSecond / 100) / 10 .. "k"
			else
				formattedUnitDamagePerSecond = unitDamagePerSecond
			end

			self.PlayerDamageText:Show()
			self.PlayerDamageText:SetText(formattedUnitDamagePerSecond)
		end
	end

	function MetricsUI:ResizeToText()
		local height = 0
		local width = 0

		local childWidth, childHeight = self.PlayerDamageText:GetSize()

		if childWidth > width then
			width = childWidth
		end

		if childHeight > height then
			height = childHeight
		end

		self:SetSize(width, height)
	end


	C_Timer.NewTicker(0.25, function()
		MetricsUI:UpdateDamageText()
	end)


	return MetricsUI
end)
