local addonName, addonData = ...


local imports = {
	command = {
		api = true,
	}
}


addonData.CollectionsAPI:GetCollection('development'):AddMixin('ui', imports, function()
	local DevelopmentUI = CreateFrame('frame')

	DevelopmentUI:Hide()
	DevelopmentUI:SetPoint('topleft', 5, -5)
	DevelopmentUI:SetSize(200, 300)

		DevelopmentUI.Background = DevelopmentUI:CreateTexture()
		DevelopmentUI.Background:SetAllPoints()
		DevelopmentUI.Background:SetColorTexture(0, 0, 0, 0.3)

	DevelopmentUI.Input = CreateFrame('EditBox', nil, DevelopmentUI)
	DevelopmentUI.Input:SetAutoFocus(false)
	DevelopmentUI.Input:SetFont('fonts/blei00d.ttf', 10, '')
	DevelopmentUI.Input:SetHeight(10)
	DevelopmentUI.Input:SetPoint('right')
	DevelopmentUI.Input:SetPoint('topleft')

	DevelopmentUI.Input.OnEnterPressed = function(self)
		local dataKey = self:GetText()

		if dataKey == '' then
			return
		end

		local data = _G

		if dataKey ~= '_G' then
			local dataKeys = self:GetText():gmatch('[^.]+')

			for key in dataKeys do
				if type(data) ~= 'table' then
					break
				end

				data = data[key]
			end
		end

		self:GetParent():SetData(dataKey, data)
	end

	DevelopmentUI.Input:SetScript('OnEnterPressed', DevelopmentUI.Input.OnEnterPressed)

	DevelopmentUI.Input:SetScript('OnEscapePressed', function(self)
		self:ClearFocus()
	end)

		DevelopmentUI.Input.background = DevelopmentUI.Input:CreateTexture()
		DevelopmentUI.Input.background:SetAllPoints()
		DevelopmentUI.Input.background:SetColorTexture(0, 0, 0, 0.5)

	DevelopmentUI.ScrollFrame = CreateFrame('ScrollFrame', nil, DevelopmentUI)
	DevelopmentUI.ScrollFrame:SetPoint('topleft', DevelopmentUI.Input, 'bottomleft')
	DevelopmentUI.ScrollFrame:SetPoint('bottomright')

	DevelopmentUI.ScrollFrame.ScrollStep = 10

	DevelopmentUI.ScrollFrame:SetScript('OnMouseWheel', function(self, delta)
		local scrollOffset = self.ScrollStep

		if delta == 1 then
			scrollOffset = scrollOffset * -1
		end

		local newVerticalScroll = self:GetVerticalScroll() + scrollOffset

		local maxVerticalScroll = self:GetScrollChild():GetHeight() - self:GetHeight() + 10

		newVerticalScroll = math.max(-10, newVerticalScroll)
		newVerticalScroll = math.min(maxVerticalScroll, newVerticalScroll)

		self:SetVerticalScroll(newVerticalScroll)
	end)

		DevelopmentUI.ScrollFrame.ScrollChild = CreateFrame('Frame', nil, DevelopmentUI.ScrollFrame)
		DevelopmentUI.ScrollFrame.ScrollChild:SetPoint('topleft')
		DevelopmentUI.ScrollFrame.ScrollChild:SetWidth(DevelopmentUI.ScrollFrame:GetWidth())

	DevelopmentUI.ScrollFrame:SetScrollChild(DevelopmentUI.ScrollFrame.ScrollChild)


	DevelopmentUI.textLineFrames = {}
	DevelopmentUI.textLineFrameIndex = 1

	function DevelopmentUI:AddTextLine(text, entryInfo)
		local TextLineFrame = self.textLineFrames[self.textLineFrameIndex]

		if not TextLineFrame then
			TextLineFrame = CreateFrame('Button', nil, self.ScrollFrame.ScrollChild)

			self.textLineFrames[self.textLineFrameIndex] = TextLineFrame

			TextLineFrame:SetHeight(10)
			TextLineFrame:SetPoint('left')
			TextLineFrame:SetPoint('right')

			TextLineFrame:SetText('-')
			TextLineFrame:GetFontString():SetAllPoints()
			TextLineFrame:GetFontString():SetFont('fonts/blei00d.ttf', 10)
			TextLineFrame:GetFontString():SetJustifyH('left')
			TextLineFrame:SetText('')

			if self.textLineFrameIndex > 1 then
				TextLineFrame:SetPoint('top', self.textLineFrames[self.textLineFrameIndex - 1], 'bottom')
			else
				TextLineFrame:SetPoint('top')
			end

			TextLineFrame:SetScript('OnClick', function(self)
				local fullKey = DevelopmentUI.dataKey .. '.' .. self.entryInfo.key

				if self.entryInfo.keyValueType == 'function' then
					local functionMessage = fullKey .. '() => '

					local functionReturnValues = {self.entryInfo.keyValue()}

					for functionReturnValueIndex, functionReturnValue in ipairs(functionReturnValues) do
						if functionReturnValueIndex > 1 then
							functionMessage = functionMessage .. ', '
						end

						functionMessage = functionMessage .. tostring(functionReturnValue)
					end

					DEFAULT_CHAT_FRAME:AddMessage(functionMessage)

					return
				end

				DevelopmentUI.Input:SetText(fullKey)

				DevelopmentUI.Input:OnEnterPressed()
			end)
		end

		TextLineFrame.entryInfo = entryInfo
		TextLineFrame:SetText(tostring(text))
		TextLineFrame:Show()

		DevelopmentUI.ScrollFrame.ScrollChild:SetHeight(TextLineFrame:GetHeight() * self.textLineFrameIndex)

		self.textLineFrameIndex = self.textLineFrameIndex + 1
	end

	function DevelopmentUI:ClearTextLines()
		for _, TextLineFrame in ipairs(self.textLineFrames) do
			TextLineFrame:Hide()
			TextLineFrame:SetText('')
		end

		self.ScrollFrame:SetVerticalScroll(0)

		self.textLineFrameIndex = 1
	end

	function DevelopmentUI:SetData(dataKey, dataValue)
		self:ClearTextLines()

		self.dataKey = dataKey
		self.dataValue = dataValue

		if type(dataValue) ~= 'table' then
			self:AddTextLine(dataValue)

			return
		end

		local textEntries = {}

		for key, keyValue in pairs(dataValue) do
			table.insert(textEntries, {
				key = key,
				keyValue = keyValue,
				keyValueType = type(keyValue),
			})
		end

		table.sort(textEntries, function(a, b)
			return tostring(a.key) < tostring(b.key)
		end)

		for _, entryInfo in ipairs(textEntries) do
			local hexColor

			if entryInfo.keyValueType == 'function' then
				hexColor = '82f080'
			elseif entryInfo.keyValueType == 'userdata' then
				hexColor = '82F010'
			elseif entryInfo.keyValueType == 'table' then
				hexColor = '81c0f0'
			else
				hexColor = 'ffffff'
			end

			self:AddTextLine('|cff' .. hexColor .. entryInfo.key .. '|r', entryInfo)
		end
	end



	imports.command.api:AddCommand('DEVELOPMENT_FRAME', function()
		if DevelopmentUI:IsShown() then
			DevelopmentUI:Hide()
		else
			DevelopmentUI:Show()
		end
	end)

	_G[addonName .. '_DevelopmentUI_SetData'] = function(...)
		DevelopmentUI:SetData(...)
		DevelopmentUI:Show()
	end



	return developmentUI
end)
