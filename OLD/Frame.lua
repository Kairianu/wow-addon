local addonName, addonTable = ...



local BaseScrollFrameMetatable = {}

function BaseScrollFrameMetatable:AddChild(child)
	if not self.childFrames then
		self.childFrames = {}
	end

	table.insert(self.childFrames, child)

	child:SetParent(self.ScrollFrame:GetScrollChild())

	return child
end

function BaseScrollFrameMetatable:CreateFontString(...)
	return self.ScrollFrame:GetScrollChild():CreateFontString(...)
end

function BaseScrollFrameMetatable:SetBackgroundColorTexture(...)
	local Background = self.Background

	if not Background then
		Background = self:CreateTexture("Background")

		Background:SetAllPoints()
	end

	Background:SetColorTexture(...)
end



local Frame = {}
addonTable.Frame = Frame

function Frame:CreateScrollFrame(options)
	local BaseFrame = CreateFrame("Frame", nil, options and options.parent or UIParent)

	BaseFrame:SetClampedToScreen(true)
	BaseFrame:SetMovable(true)

	local BaseFrameTopBarFrame = CreateFrame("Frame", nil, BaseFrame)
	BaseFrame.TopBarFrame = BaseFrameTopBarFrame
	BaseFrameTopBarFrame:SetHeight(20)
	BaseFrameTopBarFrame:SetPoint("Right")
	BaseFrameTopBarFrame:SetPoint("TopLeft")

	BaseFrameTopBarFrame:SetScript("OnMouseDown", function(self)
		self:GetParent():StartMoving()
	end)

	BaseFrameTopBarFrame:SetScript("OnMouseUp", function(self)
		self:GetParent():StopMovingOrSizing()
	end)

	if options and options.title then
		local BaseFrameTitle = BaseFrameTopBarFrame:CreateFontString()
		BaseFrame.Title = BaseFrameTitle
		BaseFrameTitle:SetFont(addonTable.Font:GetDefaultFontFamily(), 12)
		BaseFrameTitle:SetText(options.title)
		BaseFrameTitle:SetPoint("Center")
	end

	setmetatable(BaseFrame, {
		__index = function(self, key)
			for _, metatable in ipairs(getmetatable(self).metatables) do
				local metatableKeyValue = metatable[key]

				if metatableKeyValue ~= nil then
					return metatableKeyValue
				end
			end

			return rawget(self, key)
		end,

		metatables = {
			BaseScrollFrameMetatable,
			getmetatable(BaseFrame).__index,
		},
	})

	local ScrollFrame = CreateFrame("ScrollFrame", nil, BaseFrame)
	BaseFrame.ScrollFrame = ScrollFrame

	local ScrollChildFrame = CreateFrame("Frame", nil, ScrollFrame)
	ScrollFrame:SetScrollChild(ScrollChildFrame)

	if options and options.padding then
		ScrollFrame:SetPoint("BottomRight", -options.padding.right, options.padding.bottom)
		ScrollFrame:SetPoint("TopLeft", options.padding.left, -options.padding.top)
	else
		ScrollFrame:SetAllPoints()
	end

	ScrollFrame:SetScript("OnSizeChanged", function(self)
		self:GetScrollChild():SetSize(self:GetSize())
	end)

	ScrollFrame:SetScript("OnMouseWheel", function(self, delta)
		local verticalScroll = self:GetVerticalScroll() - delta
		local verticalScrollRange = self:GetVerticalScrollRange()

		if verticalScroll < 0 then
			verticalScroll = 0
		elseif verticalScroll > verticalScrollRange then
			verticalScroll = verticalScrollRange
		end

		self:SetVerticalScroll(verticalScroll)
	end)

	local ScrollChildFrame = CreateFrame("Frame", nil, ScrollFrame)
	ScrollFrame:SetScrollChild(ScrollChildFrame)

	return BaseFrame
end



-- local f = Frame:CreateScrollFrame({
-- 	title = "Test Frame"
-- })

-- f:SetPoint("Center")
-- f:SetSize(500, 500)

-- f:SetBackgroundColorTexture(0, 0, 0)

-- local c = f:CreateFontString()
-- c:SetFont(addonTable.Font:GetDefaultFontFamily())
-- c:SetPoint("Center")
-- c:SetText("Test")







local questFramesPointInfo = {}

local movableFrames = {
	{
		frameName = "BankFrame.TitleContainer",
		movableFrameName = "BankFrame",
	},
	{
		frameName = "CharacterFrame.TitleContainer",
		movableFrameName = "CharacterFrame",
	},
	{
		addonName = "Blizzard_Collections",
		frameName = "CollectionsJournal.TitleContainer",
		movableFrameName = "CollectionsJournal",
	},
	{
		frameName = "GossipFrame.TitleContainer",
		movableFrameName = "GossipFrame",
		pointInfo = questFramesPointInfo,
	},
	{
		frameName = "MailFrame.TitleContainer",
		movableFrameName = "MailFrame",
	},
	{
		frameName = "MerchantFrame.TitleContainer",
		movableFrameName = "MerchantFrame",
		pointInfo = questFramesPointInfo,
	},
	{
		frameName = "QuestFrame.TitleContainer",
		movableFrameName = "QuestFrame",
		pointInfo = questFramesPointInfo,
	},
	{
		frameName = "WorldMapFrame.BorderFrame.TitleContainer",
		movableFrameName = "WorldMapFrame",
	},
}

local function SetupMovableFrame(frameInfo)
	local movingFrameNameList = {}

	for movingFrameNamePart in frameInfo.frameName:gmatch("[^.]+") do
		table.insert(movingFrameNameList, movingFrameNamePart)
	end

	local MovingFrame = _G[movingFrameNameList[1]]

	for i = 2, #movingFrameNameList do
		if not MovingFrame then
			return
		end

		MovingFrame = MovingFrame[movingFrameNameList[i]]
	end

	if not MovingFrame then
		return
	end


	local MovableFrame

	if frameInfo.movableFrameName then
		local movableFrameNameList = {}

		for movableFrameNamePart in frameInfo.movableFrameName:gmatch("[^.]+") do
			table.insert(movableFrameNameList, movableFrameNamePart)
		end

		MovableFrame = _G[movableFrameNameList[1]]

		for i = 2, #movableFrameNameList do
			if not MovableFrame then
				return
			end

			MovableFrame = MovableFrame[movableFrameNameList[i]]
		end

		if not MovableFrame then
			return
		end
	else
		MovableFrame = MovingFrame
	end


	if not frameInfo.pointInfo then
		frameInfo.pointInfo = {}
	end

	frameInfo.UpdateFrame = CreateFrame("Frame", nil, MovingFrame)
	frameInfo.UpdateFrame:SetAllPoints()

	frameInfo.UpdateFrame.OnUpdate = function(self)
		local cursorLeft, cursorBottom = GetCursorPosition()

		local movableFrameEffectiveScale = MovableFrame:GetEffectiveScale()
		local movableFrameLeft, movableFrameBottom, movableFrameWidth, movableFrameHeight = MovableFrame:GetRect()

		local newLeft = movableFrameLeft + ((cursorLeft - self.cursorLeft) / movableFrameEffectiveScale)
		local newBottom = movableFrameBottom + ((cursorBottom - self.cursorBottom) / movableFrameEffectiveScale)

		newLeft = math.min(math.max(0, newLeft), GetScreenWidth() - movableFrameWidth)
		newBottom = math.min(math.max(0, newBottom), GetScreenHeight() - movableFrameHeight)

		MovableFrame:ClearAllPoints()
		MovableFrame:SetPoint("BottomLeft", UIParent, newLeft, newBottom)

		frameInfo.pointInfo.left = newLeft
		frameInfo.pointInfo.bottom = newBottom

		self.cursorLeft = cursorLeft
		self.cursorBottom = cursorBottom
	end

	frameInfo.UpdateFrame:SetScript("OnMouseDown", function(self)
		self.cursorLeft, self.cursorBottom = GetCursorPosition()

		self:SetScript("OnUpdate", self.OnUpdate)
	end)

	frameInfo.UpdateFrame:SetScript("OnMouseUp", function(self)
		self:SetScript("OnUpdate", nil)
	end)

	frameInfo.UpdateFrame:SetScript("OnShow", function(self)
		if frameInfo.pointInfo.bottom and frameInfo.pointInfo.left then
			MovableFrame:ClearAllPoints()
			MovableFrame:SetPoint("BottomLeft", UIParent, frameInfo.pointInfo.left, frameInfo.pointInfo.bottom)
		end
	end)
end

local MovableFramesEventFrame = CreateFrame("EventFrame")
MovableFramesEventFrame:RegisterEvent("ADDON_LOADED")
MovableFramesEventFrame:RegisterEvent("FIRST_FRAME_RENDERED")
MovableFramesEventFrame:SetScript("OnEvent", function(self, event, arg1)
	for _, frameInfo in ipairs(movableFrames) do
		if
			(event == "ADDON_LOADED" and frameInfo.addonName == arg1)
			or (event == "FIRST_FRAME_RENDERED" and not frameInfo.addonName)
		then
			SetupMovableFrame(frameInfo)
		end
	end
end)
