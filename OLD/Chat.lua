local addonName, addonTable = ...



local ChatFrame = CreateFrame("ScrollFrame", nil, UIParent)

ChatFrame.chatLines = {}
ChatFrame.filters = {
	"|c" .. ("."):rep(8) .. "|Htrade:.-|h|r",
	"|c" .. ("."):rep(8) .. "|HclubFinder:.-|h|r",
	"%f[%a]LF%f[%A]",
	"%f[%a]LFW%f[%A]",
	"%f[%a]WTB%f[%A]",
}

hooksecurefunc(ChatFrame, "SetSize", function(self)
	self:GetScrollChild():SetSize(self:GetSize())
end)

ChatFrame:SetScrollChild(CreateFrame("Frame", nil, ChatFrame))

ChatFrame:Hide()
ChatFrame:SetMovable(true)
ChatFrame:SetPoint("Left")
ChatFrame:SetSize(450, 200)


function ChatFrame:AddChatLine(text)
	if text == self.previousText then
		return
	end

	self.previousText = text

	-- if not text:find("Ahnikoh") then
	-- 	return
	-- end

	for _, filter in ipairs(self.filters) do
		if text:find(filter) then
			return
		end
	end

	local scrollToBottom = string.format("%.1f", self:GetVerticalScroll()) == string.format("%.1f", self:GetVerticalScrollRange())

	local ChatLine = self:GetScrollChild():CreateFontString()

	ChatLine:SetFont(addonTable.Font:GetDefaultFont())
	ChatLine:SetJustifyH("Left")
	ChatLine:SetText(text)
	ChatLine:SetTextColor(1, 0.75, 0.75)

	ChatLine:SetPoint("Left")
	ChatLine:SetPoint("Right")

	local previousChatLine = self.chatLines[#self.chatLines]

	if previousChatLine then
		ChatLine:SetPoint("Top", previousChatLine, "Bottom", 0, -3)
	else
		ChatLine:SetPoint("Top")
	end

	table.insert(self.chatLines, ChatLine)

	if scrollToBottom then
		C_Timer.After(0, function()
			self:SetVerticalScroll(self:GetVerticalScrollRange())
		end)
	end
end


ChatFrame:SetScript("OnMouseDown", function(self)
	self.onMouseDownX, self.onMouseDownY = GetCursorPosition()

	self:StartMoving()
end)

ChatFrame:SetScript("OnMouseUp", function(self)
	local x, y = GetCursorPosition()

	if x == self.onMouseDownX and y == self.onMouseDownY then
		self:Hide()
	end

	self:StopMovingOrSizing()
end)

ChatFrame:SetScript("OnMouseWheel", function(self, delta)
	local newScroll = self:GetVerticalScroll() + 8 * -delta

	if newScroll < 0 then
		newScroll = 0
	elseif newScroll > self:GetVerticalScrollRange() then
		newScroll = self:GetVerticalScrollRange()
	end

	self:SetVerticalScroll(newScroll)
end)


local function ChatFrame_OnAddMessage(message)
	-- if not ChatFrame:IsShown() then
	-- 	return
	-- end

	ChatFrame:AddChatLine(message)
end

ChatFrame:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE")
-- ChatFrame:RegisterEvent("CHAT_MSG_SAY")
ChatFrame:RegisterEvent("FIRST_FRAME_RENDERED")
ChatFrame:SetScript("OnEvent", function(self, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
	if event == "CHAT_MSG_CHANNEL_NOTICE" then
		if arg1 == "YOU_CHANGED" then
			if arg9 == "Trade - City" then
				self:Show()
			end
		end
	elseif event == "CHAT_MSG_SAY" then
		self:AddChatLine(arg1)
	elseif event == "FIRST_FRAME_RENDERED" then
		hooksecurefunc(DEFAULT_CHAT_FRAME, "AddMessage", function(_, message)
			ChatFrame_OnAddMessage(message)
		end)
	end
end)




local ChatFrameShowButton = addonTable.Button:CreateButton({
	parent = UIParent,
	text = "Show Chat",
	font = {
		addonTable.Font:GetDefaultFont(),
		addonTable.Font:GetDefaultFontSize(),
		"OUTLINE",
	},
})
ChatFrameShowButton:ResizeToText()
ChatFrameShowButton:SetPoint("TopLeft", 0, -15)

if ChatFrame:IsShown() then
	ChatFrameShowButton:Hide()
else
	ChatFrameShowButton:Show()
end

ChatFrameShowButton:SetScript("OnClick", function(self)
	ChatFrame:Show()

	self:Hide()
end)

addonTable.C_FrameHide:SetupFrame(ChatFrameShowButton)

ChatFrame:SetScript("OnHide", function()
	ChatFrameShowButton:Show()
end)

ChatFrame:SetScript("OnShow", function(self)
	ChatFrameShowButton:Hide()

	C_Timer.After(0, function()
		self:SetVerticalScroll(self:GetVerticalScrollRange())
	end)
end)
