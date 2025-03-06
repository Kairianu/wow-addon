local addonName, addonData = ...


-- SetBinding('J', 'SPELL ' .. spellInfo.name)


local ActionButtonTest = CreateFrame('button', 'MyAddon_ActionButtonTest', UIParent, 'SecureActionButtonTemplate')
ActionButtonTest:SetPoint('bottomLeft', 400, 350)
ActionButtonTest:SetSize(50, 50)
ActionButtonTest:RegisterForClicks('AnyDown')

-- Remove when working
ActionButtonTest:Hide()

ActionButtonTest.Background = ActionButtonTest:CreateTexture(nil, 'background')
ActionButtonTest.Background:SetAllPoints()
ActionButtonTest.Background:SetColorTexture(0, 0, 0, 0.3)

ActionButtonTest.Icon = ActionButtonTest:CreateTexture()
ActionButtonTest.Icon:SetAllPoints()






ActionButtonTest:SetScript('onEnter', function(self)
	if UnitAffectingCombat('player') then
		return
	end

	self:RegisterEvent('GLOBAL_MOUSE_UP')
end)

ActionButtonTest:SetScript('onLeave', function(self)
	self:UnregisterEvent('GLOBAL_MOUSE_UP')
end)

ActionButtonTest:SetScript('onEvent', function(self, event)
	if UnitAffectingCombat('player') then
		return
	end

	local cursorType, cursorArg1, cursorArg2, cursorArg3 = GetCursorInfo()

	if cursorType == 'spell' then
		local spellID = cursorArg3

		local spellInfo = C_Spell.GetSpellInfo(spellID)

		self.spellInfo = spellInfo

		self:SetAttribute('type', 'macro')
		self:SetAttribute('macrotext', '/cast ' .. spellInfo.name)

		self.Icon:SetTexture(spellInfo.iconID)

		SetBinding('J', 'CLICK ' .. self:GetName() .. ':LeftButton')

		ClearCursor()
	end
end)







addonData.CollectionsAPI:GetCollection('actionButton'):AddMixin('ui', function()
	local ActionButtonUI = {}


	return ActionButtonUI
end)
