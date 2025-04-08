local addonName, addonData = ...


-- SetBinding('J', 'CLICK MyAddon_ActionButtonTest:LeftButton')



local ActionButtonMetatable = {}

local function actionButtonMetatableIndex(ActionButtonFrame, key)
	local value = rawget(ActionButtonFrame, key)

	if value == nil then
		value = ActionButtonMetatable[key]

		if value == nil then
			value = getmetatable(ActionButtonFrame).secureActionButtonMixin[key]
		end
	end

	return value
end

function ActionButtonMetatable:SetIconTexture(...)
	self.Icon:SetTexture(...)
end

function ActionButtonMetatable:SetActionFromCursor()
	local cursorType, cursorArg1, cursorArg2, cursorArg3 = GetCursorInfo()

	if not cursorType then
		return
	end

	if cursorType == 'battlepet' then
		self:SetBattlePetAction(cursorArg1)
	elseif cursorType == 'flyout' then
	elseif cursorType == 'item' then
		self:SetItemAction(cursorArg1, cursorArg2)
	elseif cursorType == 'macro' then
	elseif cursorType == 'merchant' then
	elseif cursorType == 'mount' then
		self:SetMacroAction(cursorArg1)
	elseif cursorType == 'spell' then
		self:SetSpellAction(cursorArg1, cursorArg2, cursorArg3)
	end

	ClearCursor()
end

function ActionButtonMetatable:SetBattlePetAction(battlePetGUID)
	local battlePetSpeciesID, battlePetCustomName, battlePetLevel, battlePetXP, battlePetMaxXP, battlePetDisplayID, battlePetIsFavorite, battlePetName, battlePetIconTexture, battlePetPetType, battlePetCreatureID, battlePetSourceText, battlePetDescription, battlePetIsWild, battlePetCanBattle, battlePetIsTradable, battlePetIsUnique, battlePetIsObtainable = C_PetJournal.GetPetInfoByPetID(battlePetGUID)

	self:SetAttribute('type', 'macro')
	self:SetAttribute('macrotext', '/summonpet ' .. battlePetGUID)

	self:SetIconTexture(battlePetIconTexture)
end

function ActionButtonMetatable:SetItemAction(itemID, itemLink)
	local itemName, _itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLocation, itemIconTexture, itemSellPrice, itemClassID, itemSubClassID, itemBindType, itemExpacID, itemSetID, itemIsCraftingReagent = GetItemInfo(itemLink)

	self:SetAttribute('type', 'item')
	self:SetAttribute('item', itemLink)

	self:SetIconTexture(itemIconTexture)
end

function ActionButtonMetatable:SetMacroAction(macroIndex)
	-- TODO: Needs macro collection to handle getting the correct macro when index changes.

	local macroName, macroIconTexture, macroText = GetMacroInfo(macroIndex)

	self:SetAttribute('type', 'macro')
	self:SetAttribute('macro', macroIndex)

	self:SetIconTexture(macroIconTexture)
end

function ActionButtonMetatable:SetSpellAction(spellIndex, spellBookType, spellID)
	local spellInfo = C_Spell.GetSpellInfo(spellID)

	self:SetAttribute('type', 'spell')
	self:SetAttribute('spell', spellID)

	self:SetIconTexture(spellInfo.iconID)
end






local ActionButtonTest = CreateFrame('button', 'MyAddon_ActionButtonTest', UIParent, 'SecureActionButtonTemplate')

setmetatable(ActionButtonTest, {
	__index = actionButtonMetatableIndex,

	secureActionButtonMixin = getmetatable(ActionButtonTest).__index,
})

ActionButtonTest.registeredClicks = {'AnyDown'}

ActionButtonTest:SetPoint('bottomLeft', 100, 400)
ActionButtonTest:SetSize(75, 75)
ActionButtonTest:RegisterForClicks(unpack(ActionButtonTest.registeredClicks))

ActionButtonTest.Background = ActionButtonTest:CreateTexture(nil, 'background')
ActionButtonTest.Background:SetAllPoints()
ActionButtonTest.Background:SetColorTexture(0, 0, 0, 0.3)

ActionButtonTest.Icon = ActionButtonTest:CreateTexture()
ActionButtonTest.Icon:SetAllPoints()








ActionButtonTest.TempText1 = ActionButtonTest:CreateFontString()
ActionButtonTest.TempText1:SetFont('fonts/blei00d.ttf', 12)
ActionButtonTest.TempText1:SetPoint('top', ActionButtonTest, 'bottom')
ActionButtonTest.TempText1:SetSize(200, 12)

ActionButtonTest.TempText2 = ActionButtonTest:CreateFontString()
ActionButtonTest.TempText2:SetFont('fonts/blei00d.ttf', 12)
ActionButtonTest.TempText2:SetPoint('top', ActionButtonTest.TempText1, 'bottom')
ActionButtonTest.TempText2:SetSize(200, 12)



ActionButtonTest:SetScript('onEnter', function(self)
	self:RegisterEvent('GLOBAL_MOUSE_UP')
end)

ActionButtonTest:SetScript('onLeave', function(self)
	self:UnregisterEvent('GLOBAL_MOUSE_UP')
end)

ActionButtonTest:SetScript('onEvent', function(self, event, ...)
	if UnitAffectingCombat('player') then
		return
	end

	if event == 'GLOBAL_MOUSE_UP' then
		local cursorType, cursorArg1, cursorArg2, cursorArg3 = GetCursorInfo()

		if cursorType then
			local primaryText

			if cursorType == 'battlepet' then
				local battlePetSpeciesID, battlePetCustomName, battlePetLevel, battlePetXP, battlePetMaxXP, battlePetDisplayID, battlePetIsFavorite, battlePetName, battlePetIconTexture, battlePetPetType, battlePetCreatureID, battlePetSourceText, battlePetDescription, battlePetIsWild, battlePetCanBattle, battlePetIsTradable, battlePetIsUnique, battlePetIsObtainable = C_PetJournal.GetPetInfoByPetID(cursorArg1)

				if battlePetCustomName then
					primaryText = battlePetCustomName .. ' (' .. battlePetName .. ')'
				else
					primaryText = battlePetName
				end

				primaryText = primaryText .. ' [' .. battlePetLevel .. ']'
			elseif cursorType == 'flyout' then
			elseif cursorType == 'item' then
				primaryText = cursorArg2 .. ' (' .. cursorArg1 .. ')'
			elseif cursorType == 'macro' then
				primaryText = GetMacroInfo(cursorArg1)
			elseif cursorType == 'merchant' then
			elseif cursorType == 'mount' then
			elseif cursorType == 'spell' then
				local spellInfo = C_Spell.GetSpellInfo(cursorArg3)

				primaryText = spellInfo.name .. ' (' .. cursorArg3 .. ')'
			else
				self.Icon:SetTexture()
			end

			ActionButtonTest.TempText1:SetText(primaryText)
			ActionButtonTest.TempText2:SetText(cursorType)
		end

		self:SetActionFromCursor()

		C_Timer.After(0, function()
			self:RegisterForClicks(unpack(self.registeredClicks))
		end)
	end
end)




addonData.CollectionsAPI:GetCollection('actionButton'):AddMixin('ui', function()
	local ActionButtonUI = {}


	-- TEMP
	ActionButtonUI.ActionButtonTest = ActionButtonTest


	return ActionButtonUI
end)
