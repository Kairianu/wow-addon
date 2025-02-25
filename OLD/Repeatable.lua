local addonName, addonData = ...

local RepeatableFrame = CreateFrame("frame", "MyAddon_RepeatableFrame", UIParent, "PortraitFrameTemplate")

RepeatableFrame:Hide()

RepeatableFrame:SetMovable(true)
RepeatableFrame:SetPoint("center")
RepeatableFrame:SetResizable(true)
RepeatableFrame:SetSize(1000, 500)
RepeatableFrame:SetTitle("Repeatable Tasks")

function RepeatableFrame:SetPortraitToClassCrest()
	local classFilename = select(2, UnitClass("player"))

	local classCrestTexturePath = string.format(
		"Interface/ICONS/crest_%s.blp",
		classFilename
	)

	self:SetPortraitTextureRaw(classCrestTexturePath)
end

RepeatableFrame:RegisterEvent("FIRST_FRAME_RENDERED")
RepeatableFrame:SetScript("OnEvent", function(self, event, ...)
	if event == "FIRST_FRAME_RENDERED" then
		self:SetPortraitToClassCrest()
	end
end)

RepeatableFrame:SetScript("OnKeyDown", function(self, key)
	local propagateKeyboardInput = true

	if key == "ESCAPE" then
		if self:IsShown() then
			self:Hide()

			propagateKeyboardInput = false
		end
	end

	self:SetPropagateKeyboardInput(propagateKeyboardInput)
end)

function RepeatableFrame.TitleContainer:OnDoubleClick()
	local parent = self:GetParent()

	parent:ClearAllPoints()
	parent:SetPoint("center")
end

RepeatableFrame.TitleContainer:SetScript("OnMouseDown", function(self)
	self.onMouseDownX, self.onMouseDownY = GetCursorPosition()

	self:GetParent():StartMoving()
end)

RepeatableFrame.TitleContainer:SetScript("OnMouseUp", function(self)
	local onMouseUpX, onMouseUpY = GetCursorPosition()

	if onMouseUpX == self.onMouseDownX and onMouseUpY == self.onMouseDownY then
		local currentTime = GetTimePreciseSec()

		if self.firstClickTime and currentTime - self.firstClickTime < 0.3 then
			self:OnDoubleClick()

			self.firstClickTime = nil
		else
			self.firstClickTime = currentTime
		end
	end

	self:GetParent():StopMovingOrSizing()
end)





local ExpansionSelectionContainer = CreateFrame("frame", nil, RepeatableFrame)
ExpansionSelectionContainer:SetPoint("Top", RepeatableFrame.TitleContainer, "Bottom", 0, -8)
ExpansionSelectionContainer:SetSize(1, 1)

ExpansionSelectionContainer.expansions = {
	{
		icon = "Interface/ICONS/ExpansionIcon_Classic.blp",
		id = LE_EXPANSION_CLASSIC,
	},
	{
		icon = "Interface/ICONS/ExpansionIcon_BurningCrusade.blp",
		id = LE_EXPANSION_BURNING_CRUSADE,
	},
	{
		icon = "Interface/ICONS/ExpansionIcon_WrathoftheLichKing.blp",
		id = LE_EXPANSION_WRATH_OF_THE_LICH_KING,
	},
	{
		icon = "Interface/ICONS/ExpansionIcon_Cataclysm.blp",
		id = LE_EXPANSION_CATACLYSM,
	},
	{
		icon = "Interface/ICONS/ExpansionIcon_MistsofPandaria.blp",
		id = LE_EXPANSION_MISTS_OF_PANDARIA,
	},
	{
		icon = "Interface/ICONS/EXPANSIONICON_Draenor.blp",
		id = LE_EXPANSION_WARLORDS_OF_DRAENOR,
	},
	{
		icon = "Interface/ICONS/Ability_DemonHunter_EyeofLeotheras.blp",
		id = LE_EXPANSION_LEGION,
	},
	{
		icon = "Interface/ICONS/INV_Zuldazar.blp",
		id = LE_EXPANSION_BATTLE_FOR_AZEROTH,
	},
	{
		icon = "Interface/ICONS/INV_Achievement_Raid_ProgenitorRaid_Jailer.blp",
		id = LE_EXPANSION_SHADOWLANDS,
	},
	{
		icon = "Interface/ICONS/INV_Shield_1H_DragonRaid_D_01.blp",
		id = LE_EXPANSION_DRAGONFLIGHT,
	},
	{
		icon = "Interface/ICONS/INV_Nullstone_Void.blp",
		id = LE_EXPANSION_WAR_WITHIN,
	},
}

function ExpansionSelectionContainer:AddExpansionButtons()
	local expansionButtonSize = 30

	local iconBorderSelectedSize = expansionButtonSize * 1.5

	local parentHeight
	local parentLeft
	local parentRight
	local previousExpansionButton

	for _, expansionData in ipairs(self.expansions) do
		local expansionName = GetExpansionName(expansionData.id)

		local ExpansionButton = CreateFrame("button", nil, self)

		ExpansionButton:SetSize(expansionButtonSize, expansionButtonSize)

		if previousExpansionButton then
			ExpansionButton:SetPoint("left", previousExpansionButton, "right", 5, 0)
		else
			ExpansionButton:SetPoint("left")
		end

		ExpansionButton.icon = ExpansionButton:CreateTexture(nil, "background")
		ExpansionButton.icon:SetAllPoints()
		ExpansionButton.icon:SetMask("Interface/Masks/CircleMaskScalable.BLP")
		ExpansionButton.icon:SetTexture(expansionData.icon)

		ExpansionButton.iconBorder = ExpansionButton:CreateTexture(nil, "border")
		ExpansionButton.iconBorder:SetAllPoints()
		ExpansionButton.iconBorder:SetTexture("Interface/Azerite/AzeriteGoldRingRanks.BLP")

		ExpansionButton.iconBorderSelected = ExpansionButton:CreateTexture(nil, "border")
		ExpansionButton.iconBorderSelected:Hide()
		ExpansionButton.iconBorderSelected:SetPoint("center")
		ExpansionButton.iconBorderSelected:SetSize(iconBorderSelectedSize, iconBorderSelectedSize)
		ExpansionButton.iconBorderSelected:SetTexCoord(381 / 512, 426 / 512, 66 / 512, 110 / 512)
		ExpansionButton.iconBorderSelected:SetTexture("Interface/Transmogrify/Transmogrify.BLP")

		ExpansionButton:SetScript("OnClick", function(self)
			local parent = self:GetParent()

			if parent.selectedExpansionButton then
				parent.selectedExpansionButton.iconBorderSelected:Hide()
			end

			parent.selectedExpansionButton = self

			self.iconBorderSelected:Show()
		end)

		ExpansionButton:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:AddLine(expansionName)
			GameTooltip:Show()
		end)

		ExpansionButton:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)

		local left, bottom, width, height = ExpansionButton:GetRect()

		local right = left + width

		if not parentLeft or left < parentLeft then
			parentLeft = left
		end

		if not parentRight or right > parentRight then
			parentRight = right
		end

		if not parentHeight or height > parentHeight then
			parentHeight = height
		end

		previousExpansionButton = ExpansionButton
	end

	self:SetSize(parentRight - parentLeft, parentHeight)
end

ExpansionSelectionContainer:AddExpansionButtons()







local ContentFrame = CreateFrame("frame", nil, RepeatableFrame)

ContentFrame:SetPoint("bottom")
ContentFrame:SetPoint("left")
ContentFrame:SetPoint("right")
ContentFrame:SetPoint("top", ExpansionSelectionContainer, "bottom", 0, -3)

ContentFrame.NavigationContainer = CreateFrame("frame", nil, ContentFrame)

ContentFrame.NavigationContainer:SetSize(1, 1)
ContentFrame.NavigationContainer:SetPoint("top")

ContentFrame.NavigationContainer.Pool = addonData.Pool:Create({
	data = {
		parent = ContentFrame.NavigationContainer,
	},

	onCreate = function(pool)
		local TabButton = CreateFrame("button", nil, pool.data.parent)

		TabButton:SetSize(1, 1)

		local usedMembers = pool.members.used

		if #usedMembers == 0 then
			TabButton:SetPoint("left")
		else
			local lastVisualMember
			local largestLeft

			for _, member in ipairs(usedMembers) do
				local left = member:GetBoundsRect()

				if not largestLeft or left > largestLeft then
					largestLeft = left
					lastVisualMember = member
				end
			end

			TabButton:SetPoint("left", lastVisualMember, "right", 5, 0)
		end

		TabButton:SetText("-")
		TabButton:GetFontString():ClearAllPoints()
		TabButton:GetFontString():SetPoint("center", 0, 1)
		TabButton:GetFontString():SetFont(addonData.Font:GetDefaultFont())
		TabButton:SetText("")

		TabButton:SetScript("OnClick", function(self)
			local selectedButton = self:GetParent().selectedButton

			if selectedButton then
				selectedButton.background:SetColorTexture(0.3, 0.3, 0.4)
			end

			self.background:SetColorTexture(0.3, 0.3, 0.8)

			self:GetParent().selectedButton = self
		end)

		TabButton:SetScript("OnSizeChanged", function(self)
			self:GetParent():ResizeToChildren()
		end)

		hooksecurefunc(TabButton, "SetText", function(self)
			local fontStringWidth, fontStringHeight = self:GetFontString():GetSize()

			self:SetSize(fontStringWidth + 8, fontStringHeight + 5)
		end)

		TabButton.background = TabButton:CreateTexture()
		TabButton.background:SetAllPoints()
		TabButton.background:SetColorTexture(0.3, 0.3, 0.4)

		return TabButton
	end,
})

function ContentFrame.NavigationContainer:ResizeToChildren()
	local bottom
	local left
	local right
	local top

	-- print("---------------------------------------")
	-- print(self:GetChildren())

	for _, child in ipairs({ self:GetChildren() }) do
		local childLeft, childBottom, childWidth, childHeight = child:GetRect()

		-- print(child:GetText(), childLeft, childBottom, childWidth, childHeight)

		if childLeft then
			local childRight = childLeft + childWidth
			local childTop = childBottom + childHeight

			if not left or childLeft < left then
				left = childLeft
			end

			if not right or childRight > right then
				right = childRight
			end

			if not bottom or childBottom < bottom then
				bottom = childBottom
			end

			if not top or childTop > top then
				top = childTop
			end
		end
	end

	self:SetSize(right - left, top - bottom)
end



local TabButtonMounts = ContentFrame.NavigationContainer.Pool:Acquire()
TabButtonMounts:SetText("Mounts")

local TabButtonPets = ContentFrame.NavigationContainer.Pool:Acquire()
TabButtonPets:SetText("Pets")

local TabButtonToys = ContentFrame.NavigationContainer.Pool:Acquire()
TabButtonToys:SetText("Toys")
