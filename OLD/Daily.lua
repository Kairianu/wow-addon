local addonName, addonTable = ...


--[[ tww
	pvp weekly: 80189
]]


local COLORS = {
	complete = addonTable.Color:GetColor("green"),
	obtained = addonTable.Color:GetColor("yellow"),
	obtainedPartially = addonTable.Color:GetColor("orange"),
	unobtained = addonTable.Color:GetColor("red"),
}

local WorldPvPSavedVariables = addonTable.WorldPvPSavedVariables



local SPARKS_OF_LIFE_QUEST_IDS = {
	72646,
	72647,
	72648,
	72649,
	74871,
	75305,
	78097,
}

local KAZRA_WEEKLY_QUEST_IDS = {
	72719,
	72720,
	72721,
	72722,
	72723,
	72724,
	72725,
	72726,
	72727,
	72728,
	72810,
}

local MALICIA_WEEKLY_QUEST_IDS = {
	71026,
	72166,
	72167,
	72168,
	72169,
	72170,
	72171,
	78128,
	78129,
}

local THERAZAL_WEEKLY_QUEST_IDS = {
	70750,
	72068,
	72373,
	72374,
	72375,
	75259,
	75859,
	75860,
	75861,
	77254,
	77976,
	78446,
	78447,
}

local EMERALD_DREAM_REPUTATION_QUEST_ID = 78444
local ZARALEK_CAVERN_REPUTATION_QUEST_ID = 75665




local function IsHeightResizeableFrame(Frame)
	local isBottomAnchored = false
	local isTopAnchored = false

	for pointIndex = 1, Frame:GetNumPoints() do
		local point, anchor, anchorPoint, x, y = Frame:GetPoint(pointIndex)

		if point:find("BOTTOM") then
			isBottomAnchored = true
		elseif point:find("TOP") then
			isTopAnchored = true
		end
	end

	if not isBottomAnchored or not isTopAnchored then
		return true
	end

	return false
end

local function IsScrollChild(Frame)
	local ParentFrame = Frame:GetParent()

	if ParentFrame.GetScrollChild and ParentFrame:GetScrollChild() == Frame then
		return true
	end

	return false
end

local function ResizeFrameToChildren(StartFrame, EndFrame)
	local resizeFramesUsableChildren = {}
	local resizeFramesOrder = { StartFrame }

	local ParentFrame = StartFrame:GetParent()
	local parentFrameUsableChildren

	while ParentFrame ~= EndFrame:GetParent() do
		if not ParentFrame.GetScrollChild then
			if not IsHeightResizeableFrame(ParentFrame) or IsScrollChild(ParentFrame) then
				parentFrameUsableChildren = addonTable.C_Table:MergeInsert({ ParentFrame:GetChildren() }, parentFrameUsableChildren)
			else
				if parentFrameUsableChildren then
					resizeFramesUsableChildren[tostring(ParentFrame)] = parentFrameUsableChildren

					parentFrameUsableChildren = nil
				end

				table.insert(resizeFramesOrder, ParentFrame)
			end
		end

		ParentFrame = ParentFrame:GetParent()
	end

	for _, ResizeFrame in ipairs(resizeFramesOrder) do
		local children = resizeFramesUsableChildren[tostring(ResizeFrame)] or { ResizeFrame:GetChildren() }

		table.insert(children, ResizeFrame.Title)

		if ResizeFrame.GetScrollChild then
			local ScrollChildFrameChildren = { ResizeFrame:GetScrollChild():GetChildren() }

			for _, ScrollChildFrameChild in ipairs(ScrollChildFrameChildren) do
				table.insert(children, ScrollChildFrameChild)
			end
		end

		local bottom
		local top

		for _, child in ipairs(children) do
			local childLeft, childBottom, childWidth, childHeight = child:GetRect()

			local childTop = childBottom + childHeight

			if not bottom or childBottom < bottom then
				bottom = childBottom
			end

			if not top or childTop > top then
				top = childTop
			end
		end

		local maxHeight = ResizeFrame.maxHeight
		local minHeight = ResizeFrame.minHeight

		local height

		if bottom and top then
			height = top - bottom

			if minHeight and height < minHeight then
				height = minHeight
			elseif maxHeight and height > maxHeight then
				height = maxHeight
			end
		elseif minHeight then
			height = minHeight
		end

		if height then
			ResizeFrame:SetHeight(height)
		end
	end
end



local RepeatableFrame = CreateFrame("Frame", nil, UIParent)

RepeatableFrame.style = {
	maxHeight = 500,
	maxWidth = 500,
	padding = {
		bottom = 3,
		left = 3,
		right = 3,
		top = 5,
	},
}

RepeatableFrame:SetClampedToScreen(true)
RepeatableFrame:SetMovable(true)
RepeatableFrame:SetPoint("TopLeft", 90, -5)
RepeatableFrame:SetSize(215, 1)

RepeatableFrame:SetScript("OnMouseDown", function(self)
	self:StartMoving()
end)

RepeatableFrame:SetScript("OnMouseUp", function(self)
	self:StopMovingOrSizing()
end)

RepeatableFrame.Background = RepeatableFrame:CreateTexture("Background")
RepeatableFrame.Background:SetAllPoints()
RepeatableFrame.Background:SetColorTexture(0, 0, 0, 0.4)

RepeatableFrame.ScrollFrame = CreateFrame("ScrollFrame", nil, RepeatableFrame)
RepeatableFrame.ScrollFrame:SetPoint("BottomRight", -3, 3)
RepeatableFrame.ScrollFrame:SetPoint("TopLeft", 3, -5)

RepeatableFrame.ScrollFrame:SetScript("OnMouseWheel", function(self, delta)
	local verticalScroll = self:GetVerticalScroll() - delta
	local verticalScrollRange = self:GetVerticalScrollRange()

	if verticalScroll < 0 then
		verticalScroll = 0
	elseif verticalScroll > verticalScrollRange then
		verticalScroll = verticalScrollRange
	end

	self:SetVerticalScroll(verticalScroll)
end)

RepeatableFrame.ScrollFrame:SetScript("OnSizeChanged", function(self, width, height)
	local ScrollChildFrame = self:GetScrollChild()

	if ScrollChildFrame then
		ScrollChildFrame:SetSize(width, height)
	end
end)

local ScrollFrameParent = RepeatableFrame.ScrollFrame

RepeatableFrame.ScrollFrame.ScrollChildFrame = CreateFrame("Frame", nil, ScrollFrameParent)

ScrollFrameParent:SetScrollChild(RepeatableFrame.ScrollFrame.ScrollChildFrame)


local RepeatableFrameDirectChildParent = ScrollFrameParent:GetScrollChild()

RepeatableFrame.DailyFrame = CreateFrame("Frame", nil, RepeatableFrameDirectChildParent)
RepeatableFrame.DailyFrame.sections = {}
RepeatableFrame.DailyFrame:SetHeight(1)
RepeatableFrame.DailyFrame:SetPoint("Right")
RepeatableFrame.DailyFrame:SetPoint("TopLeft")

RepeatableFrame.DailyFrame.Title = RepeatableFrame.DailyFrame:CreateFontString()
RepeatableFrame.DailyFrame.Title:SetFont(addonTable.Font:GetDefaultFontFamily(), addonTable.Font:GetFontSize(1.2))
RepeatableFrame.DailyFrame.Title:SetPoint("Right")
RepeatableFrame.DailyFrame.Title:SetPoint("TopLeft")
RepeatableFrame.DailyFrame.Title:SetText("Daily")
RepeatableFrame.DailyFrame.Title:SetTextColor(addonTable.Color:GetColor("blue"):GetRGB())

RepeatableFrame.WeeklyFrame = CreateFrame("Frame", nil, RepeatableFrameDirectChildParent)
RepeatableFrame.WeeklyFrame.sections = {}
RepeatableFrame.WeeklyFrame:SetHeight(1)
RepeatableFrame.WeeklyFrame:SetPoint("Right")
RepeatableFrame.WeeklyFrame:SetPoint("Left")
RepeatableFrame.WeeklyFrame:SetPoint("Top", RepeatableFrame.DailyFrame, "Bottom", 0, -5)

RepeatableFrame.WeeklyFrame.Title = RepeatableFrame.WeeklyFrame:CreateFontString()
RepeatableFrame.WeeklyFrame.Title:SetFont(RepeatableFrame.DailyFrame.Title:GetFont())
RepeatableFrame.WeeklyFrame.Title:SetPoint("Right")
RepeatableFrame.WeeklyFrame.Title:SetPoint("TopLeft")
RepeatableFrame.WeeklyFrame.Title:SetText("Weekly")
RepeatableFrame.WeeklyFrame.Title:SetTextColor(addonTable.Color:GetColor("yellow"):GetRGB())

ResizeFrameToChildren(RepeatableFrame.DailyFrame, RepeatableFrame)
ResizeFrameToChildren(RepeatableFrame.WeeklyFrame, RepeatableFrame)


RepeatableFrame.sectionsAvailable = {}
RepeatableFrame.sectionsInUse = {}

function RepeatableFrame:AddSection(sectionType, options)
	sectionType = string.lower(sectionType)

	local SectionParent

	if sectionType == "daily" then
		SectionParent = self.DailyFrame
	elseif sectionType == "weekly" then
		SectionParent = self.WeeklyFrame
	else
		return
	end

	local Section = self:GetOrCreateSection()

	Section:SetParent(SectionParent)

	local anchorFrame = SectionParent.sections[#SectionParent.sections]

	if not anchorFrame then
		anchorFrame = SectionParent.Title
	end

	Section:ClearAllPoints()
	Section:SetPoint("Left", anchorFrame)
	Section:SetPoint("Right", anchorFrame)
	Section:SetPoint("Top", anchorFrame, "Bottom", 0, -3)

	if options.title then
		Section.TitleButton:SetText(options.title)
	end

	if options.eventNames then
		for _, eventName in ipairs(options.eventNames) do
			Section:RegisterEvent(eventName)
		end
	end

	if options.OnEvent then
		Section:SetScript("OnEvent", options.OnEvent)
	end

	if options.OnAdd then
		options.OnAdd(Section)
	end

	table.insert(SectionParent.sections, Section)

	ResizeFrameToChildren(Section, self)

	return Section
end

function RepeatableFrame:CreateSection()
	local Section = CreateFrame("Frame")

	Section.id = math.random(100000, 999999)
	Section.sectionChildren = {}

	Section:SetHeight(1)

	Section.TitleButton = CreateFrame("Button", nil, Section)
	Section.TitleButton:SetPoint("Right")
	Section.TitleButton:SetPoint("TopLeft")
	Section.TitleButton:SetText("-")

	local TitleButtonFontString = Section.TitleButton:GetFontString()

	TitleButtonFontString:SetFont(addonTable.Font:GetDefaultFontFamily(), addonTable.Font:GetFontSize())
	TitleButtonFontString:SetJustifyH("Left")
	TitleButtonFontString:SetPoint("Left")
	TitleButtonFontString:SetPoint("Right")

	Section.TitleButton:SetText("")

	hooksecurefunc(Section.TitleButton, "SetText", function(self)
		self:SetHeight(self:GetFontString():GetHeight())
	end)

	return Section
end

function RepeatableFrame:GetOrCreateSection()
	local Section = table.remove(self.sectionsAvailable)

	if not Section then
		Section = self:CreateSection()
	end

	table.insert(self.sectionsInUse, Section)

	return Section
end

function RepeatableFrame:RemoveSection(sectionID)end



RepeatableFrame.sectionChildsAvailable = {}
RepeatableFrame.sectionChildsInUse = {}

function RepeatableFrame:AddSectionChild(Section, options)
	local SectionChild = self:GetOrCreateSectionChild()

	SectionChild:SetParent(Section)

	local anchorFrame = Section.sectionChildren[#Section.sectionChildren]

	if not anchorFrame then
		anchorFrame = Section.TitleButton
	end

	SectionChild:ClearAllPoints()
	SectionChild:SetPoint("TopLeft", anchorFrame, "BottomLeft")
	SectionChild:SetPoint("TopRight", anchorFrame, "BottomRight")

	table.insert(Section.sectionChildren, SectionChild)
end

function RepeatableFrame:CreateSectionChild()
	local SectionChild = CreateFrame("Button")
	SectionChild:SetText()
	SectionChild:GetFontString():SetFont(addonTable.Font:GetDefaultFontFamily(), addonTable.Font:GetFontSize())

	return SectionChild
end

function RepeatableFrame:GetOrCreateSectionChild()
	local SectionChild = table.remove(self.sectionChildsAvailable)

	if not SectionChild then
		SectionChild = self:CreateSectionChild()
	end

	return SectionChild
end





addonTable.C_FrameHide:SetupFrame(RepeatableFrame)










local function AddQuestSection_UpdateTitleButtonText(Section, title, questIDs, activeQuestCount)
	local completedQuestCount = #addonTable.Quest:GetCompletedQuests(questIDs)
	local obtainedQuestCount = #addonTable.Quest:GetObtainedQuests(questIDs)

	local textColor

	if completedQuestCount >= activeQuestCount then
		textColor = COLORS.complete
	elseif obtainedQuestCount == 0 then
		textColor = COLORS.unobtained
	elseif obtainedQuestCount < activeQuestCount - completedQuestCount then
		textColor = COLORS.obtainedPartially
	else
		textColor = COLORS.obtained
	end

	local TitleButtonFontString = Section.TitleButton:GetFontString()

	TitleButtonFontString:SetTextColor(textColor:GetRGB())

	if activeQuestCount > 1 then
		TitleButtonFontString:SetText(string.format("%s [%s] (%s/%s)", title, obtainedQuestCount, completedQuestCount, activeQuestCount))
	end
end

local function AddQuestSection(repeatableType, title, questIDs, activeQuestCount)
	if not activeQuestCount then
		activeQuestCount = 1
	end

	RepeatableFrame:AddSection(repeatableType, {
		title = title,

		OnAdd = function(Section)
			AddQuestSection_UpdateTitleButtonText(Section, title, questIDs, activeQuestCount)
		end,

		eventNames = {"QUEST_ACCEPTED", "QUEST_REMOVED"},
		OnEvent = function(Section)
			AddQuestSection_UpdateTitleButtonText(Section, title, questIDs, activeQuestCount)
		end,
	})
end





RepeatableFrame:RegisterEvent("FIRST_FRAME_RENDERED")
RepeatableFrame:SetScript("OnEvent", function(self)
	-- self:AddSection("Daily", {
	-- 	title = "PvP (Random)",
	-- })

	-- self:AddSection("Daily", {
	-- 	title = "PvP (Rated)",
	-- })

	self:AddSection("Daily", {
		title = "PvP World Quests",

		OnAdd = function(Section)
			function Section:UpdateTitleButtonText()
				local pvpWorldQuests = addonTable.Quest:GetAllPvPWorldQuests()

				local pvpWorldQuestCount = #pvpWorldQuests
				local textColorName

				if pvpWorldQuestCount == 0 then
					textColorName = "green"
				else
					textColorName = "yellow"
				end

				Section.TitleButton:SetText(addonTable.Color:WrapTextInColor(
					textColorName,
					string.format("PvP World Quests (%s)", pvpWorldQuestCount)
				))
			end

			Section:UpdateTitleButtonText()
		end,

		eventNames = {"QUEST_REMOVED"},
		OnEvent = function(Section)
			Section:UpdateTitleButtonText()
		end,
	})

	self:AddSection("Daily", {
		title = "PvP World Bounty",

		OnAdd = function(Section)
			function Section:UpdateTitleButtonText()
				local assassinBountyLootTime = WorldPvPSavedVariables:GetAssassinBountyLootTimeForPlayer()

				local textColorName = "red"

				if assassinBountyLootTime then
					local nextDailyResetTime = time() + C_DateAndTime.GetSecondsUntilDailyReset()
					local secondsInDay = 86400

					if nextDailyResetTime - assassinBountyLootTime < secondsInDay then
						textColorName = "green"
					end
				end

				Section.TitleButton:SetText(addonTable.Color:WrapTextInColor(textColorName, "PvP World Bounty"))
			end

			Section:UpdateTitleButtonText()
		end,

		eventNames = {"CURRENCY_DISPLAY_UPDATE", "WORLD_CURSOR_TOOLTIP_UPDATE"},
		OnEvent = function(Section, event, arg1)
			if event == "CURRENCY_DISPLAY_UPDATE" then
				if arg1 == 1602 then
					if Section.assassinBountyFoundTime then
						if time() < Section.assassinBountyFoundTime + 30 then
							WorldPvPSavedVariables:UpdateAssassinBountyLootTimeForPlayer()

							Section:UpdateTitleButtonText()
						end
					end
				end
			elseif event == "WORLD_CURSOR_TOOLTIP_UPDATE" then
				if arg1 == 1 then
					local tooltipText = addonTable.C_Table:GetKey(GameTooltip, "processingInfo", "tooltipData", "lines", 1, "leftText")

					if tooltipText == "Alliance Bounty" or tooltipText == "Horde Bounty" then
						Section.assassinBountyFoundTime = time()
					end
				end
			end
		end,
	})

	self:AddSection("Daily", {
		title = "War Supply Crate",

		OnAdd = function(Section)
			function Section:UpdateTitleButtonText()
				local warSupplyChestLootTime = WorldPvPSavedVariables:GetWarSupplyChestLootTimeForPlayer()

				local textColorName = "red"

				if warSupplyChestLootTime then
					local nextDailyResetTime = time() + C_DateAndTime.GetSecondsUntilDailyReset()
					local secondsInDay = 86400

					if nextDailyResetTime - warSupplyChestLootTime < secondsInDay then
						textColorName = "green"
					end
				end

				Section.TitleButton:SetText(addonTable.Color:WrapTextInColor(textColorName, "War Supply Crate"))
			end

			Section:UpdateTitleButtonText()
		end,

		eventNames = {"UNIT_SPELLCAST_SENT"},
		OnEvent = function(Section, event, unit, spellName, spellGUID, spellID)
			if unit == "player" and spellID == 6247 then
				WorldPvPSavedVariables:UpdateWarSupplyChestLootTimeForPlayer()

				Section:UpdateTitleButtonText()
			end
		end,
	})


	self:AddSection("Weekly", {
		title = "Great Vault",

		OnAdd = function(Section)
			function Section:UpdateTitleButtonText()
				local text
				local textColorName

				if C_WeeklyRewards.HasAvailableRewards() then
					text = "Great Vault - Rewards Ready!"
					textColorName = "green"
				else
					local conquestWeeklyProgress = C_WeeklyRewards.GetConquestWeeklyProgress()

					text = string.format("Great Vault (%s/%s)", conquestWeeklyProgress.unlocksCompleted, conquestWeeklyProgress.maxUnlocks)

					if conquestWeeklyProgress.unlocksCompleted > 0 then
						textColorName = "green"
					elseif conquestWeeklyProgress.progress > 0 then
						textColorName = "yellow"
					else
						textColorName = "red"
					end

					-- STE(conquestWeeklyProgress)
				end

				Section.TitleButton:SetText(addonTable.Color:WrapTextInColor(textColorName, text))
			end

			Section:UpdateTitleButtonText()
		end,

		eventNames = {"WEEKLY_REWARDS_UPDATE"},
		OnEvent = function(Section)
			Section:UpdateTitleButtonText()
		end,
	})

	AddQuestSection("Weekly", "Kazra Quest", KAZRA_WEEKLY_QUEST_IDS)
	AddQuestSection("Weekly", "Malicia Quests", MALICIA_WEEKLY_QUEST_IDS, 4)
	AddQuestSection("Weekly", "Sparks of Life", SPARKS_OF_LIFE_QUEST_IDS)
	AddQuestSection("Weekly", "Therazal Quest", THERAZAL_WEEKLY_QUEST_IDS)
	AddQuestSection("Weekly", "Emerald Dream Reputation Quest", EMERALD_DREAM_REPUTATION_QUEST_ID)
	AddQuestSection("Weekly", "Zaralek Cavern Reputation Quest", ZARALEK_CAVERN_REPUTATION_QUEST_ID)


	RepeatableFrame:SetHeight(RepeatableFrame:GetHeight() + 6)
end)











SLASH_WORLD_QUEST_INFO1 = "/worldquestinfo"
SLASH_WORLD_QUEST_INFO2 = "/wq"
SlashCmdList["WORLD_QUEST_INFO"] = function()
	local completedQuestIDs = C_QuestLog.GetAllCompletedQuestIDs()

	local o = {}

	for _, completedQuestID in ipairs(completedQuestIDs) do
		local completedQuestName = C_QuestLog.GetTitleForQuestID(completedQuestID)

		if completedQuestName then
			table.insert(o, completedQuestID .. " | " .. completedQuestName)
		end
	end
end

-- if HaveQuestRewardData(worldQuestInfo.questId) then
--		GetQuestReward(worldQuestInfo.questId)
-- else
-- 	C_TaskQuest.RequestPreloadRewardData(worldQuestInfo.questId)
-- end

-- RequestPvPRewards()
