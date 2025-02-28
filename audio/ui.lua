local addonName, addonData = ...


local eulersConstant = math.exp(1)


local function createSlider(ParentFrame)
	local Slider = CreateFrame("frame", nil, ParentFrame)

	Slider.LessButton = CreateFrame("button", nil, Slider)
	Slider.LessButton:SetPoint("left")
	Slider.LessButton.ButtonTexture = Slider.LessButton:CreateTexture()
	Slider.LessButton.ButtonTexture:SetAllPoints()
	Slider.LessButton.ButtonTexture:SetColorTexture(0.8, 0, 0)

	Slider.MoreButton = CreateFrame("button", nil, Slider)
	Slider.MoreButton:SetPoint("right")
	Slider.MoreButton.ButtonTexture = Slider.MoreButton:CreateTexture()
	Slider.MoreButton.ButtonTexture:SetAllPoints()
	Slider.MoreButton.ButtonTexture:SetColorTexture(0, 0, 0.8)

	Slider.ThumbSlider = CreateFrame("button", nil, Slider)
	Slider.ThumbSlider:SetPoint("left", Slider.LessButton, "right")
	Slider.ThumbSlider:SetPoint("right", Slider.MoreButton, "left")
	Slider.ThumbSlider:SetPoint("top")
	Slider.ThumbSlider:SetPoint("bottom")
	Slider.ThumbSlider.BackgroundTexture = Slider.ThumbSlider:CreateTexture("Background")
	Slider.ThumbSlider.BackgroundTexture:SetPoint("center")
	Slider.ThumbSlider.BackgroundTexture:SetColorTexture(0, 0, 0)

	Slider.ThumbButton = CreateFrame("button", nil, Slider.ThumbSlider)
	Slider.ThumbButton:SetPoint("center", Slider.ThumbSlider, "left")
	Slider.ThumbButton.ButtonTexture = Slider.ThumbButton:CreateTexture()
	Slider.ThumbButton.ButtonTexture:SetAllPoints()
	Slider.ThumbButton.ButtonTexture:SetColorTexture(0, 0.8, 0)

	function Slider:SetValue(value)
		value = math.min(math.max(value, 0), 1)

		self.value = value

		local thumbLeft = self.ThumbSlider:GetWidth() * value - self.ThumbButton:GetWidth()

		self.ThumbButton:SetPoint("center", Slider.ThumbSlider, "left", thumbLeft, 0)
	end

	Slider:SetScript("onSizeChanged", function(self, width, height)
		local buttonSize = height * 0.5

		self.LessButton:SetSize(buttonSize, buttonSize)
		self.MoreButton:SetSize(buttonSize, buttonSize)
		self.ThumbButton:SetSize(buttonSize, buttonSize)

		local thumbSliderVisualWidth = width - (buttonSize * 3) - 10
		local thumbSliderVisualHeight = height * 0.4

		self.ThumbSlider.BackgroundTexture:SetSize(thumbSliderVisualWidth, thumbSliderVisualHeight)
	end)

	return Slider
end


-- local AudioFrame = CreateFrame("frame", nil, UIParent)
-- AudioFrame:Hide()
-- AudioFrame:SetPoint("left")
-- AudioFrame:SetSize(200, 100)

-- AudioFrame.Background = AudioFrame:CreateTexture("background")
-- AudioFrame.Background:SetAllPoints()
-- AudioFrame.Background:SetColorTexture(0, 0, 0, 0.4)

-- AudioFrame.MasterVolumeContainer = createSlider(AudioFrame)
-- AudioFrame.MasterVolumeContainer:SetHeight(20)
-- AudioFrame.MasterVolumeContainer:SetPoint("right")
-- AudioFrame.MasterVolumeContainer:SetPoint("topLeft")
-- AudioFrame.MasterVolumeContainer:SetValue(0.5)



local SoundFrame = CreateFrame("frame", nil, UIParent)
SoundFrame:Hide()
SoundFrame:SetPoint("top", 0, -100)
SoundFrame:SetSize(1, 1)

SoundFrame.Text = SoundFrame:CreateFontString()
SoundFrame.Text:SetPoint("center")
SoundFrame.Text:SetFont("Fonts/blei00d.ttf", 30, "outline")
SoundFrame.Text:SetTextColor(1, 0.82, 0)

SoundFrame.OnUpdateElapsed = 0
SoundFrame.OnUpdateTimeout = 3
SoundFrame.OnUpdateFadeElapsed = 0
SoundFrame.OnUpdateFadeTimeout = 0.8
function SoundFrame:OnUpdate(elapsed)
	self.OnUpdateElapsed = self.OnUpdateElapsed + elapsed

	if self.OnUpdateElapsed < self.OnUpdateTimeout then
		return
	end

	self.OnUpdateFadeElapsed = self.OnUpdateFadeElapsed + elapsed

	local alpha = 1 - (self.OnUpdateFadeElapsed / self.OnUpdateFadeTimeout)

	if alpha < 0 then
		alpha = 0
	elseif alpha > 1 then
		alpha = 1
	end

	self:SetAlpha(alpha)

	if alpha == 0 then
		self:Hide()
		self:SetScript("OnUpdate", nil)
		self.OnUpdateElapsed = 0
		self.OnUpdateFadeElapsed = 0
	end
end

function SoundFrame:ResetOnUpdate()
	self.OnUpdateElapsed = 0
	self.OnUpdateFadeElapsed = 0
	self:SetAlpha(1)
end

function SoundFrame:SetText(text)
	self.Text:SetText("Volume: " .. text)

	self:SetSize(self.Text:GetSize())
end

SoundFrame:RegisterEvent("CVAR_UPDATE")
SoundFrame:SetScript("OnEvent", function(self, event, arg1, arg2)
	if event == "CVAR_UPDATE" then
		if arg1 == "Sound_MasterVolume" then
			self:ResetOnUpdate()

			local masterVolumeModifiedValue = math.exp(math.log(arg2) / eulersConstant)

			-- TODO: [import] use own math rounding method
			local masterVolumeVisualValue = math.floor((masterVolumeModifiedValue * 1000) + 0.5) / 10

			if masterVolumeVisualValue % 1 == 0 then
				masterVolumeVisualValue = masterVolumeVisualValue .. ".0"
			end

			self:SetText(masterVolumeVisualValue .. "%")
			self:Show()

			self:SetScript("OnUpdate", self.OnUpdate)
		end
	end
end)



local VolumeFrame = CreateFrame("frame")

VolumeFrame.masterVolumeCVarName = "Sound_MasterVolume"
VolumeFrame.volumeDownKey = "F5"
VolumeFrame.volumeOffset = 0.05
VolumeFrame.volumeUpKey = "F6"

function VolumeFrame:OffsetMasterVolume(volumeDown)
	local masterVolumeValue = tonumber(C_CVar.GetCVar(self.masterVolumeCVarName))

	local masterVolumeVisualValue = math.exp(math.log(masterVolumeValue) / eulersConstant)

	local delta = volumeDown and -1 or 1

	local offset = self.volumeOffset * delta

	local masterVolumeNewValue = masterVolumeVisualValue + offset

	if masterVolumeNewValue < 0 then
		masterVolumeNewValue = 0
	elseif masterVolumeNewValue > 1 then
		masterVolumeNewValue = 1
	end

	local masterVolumeConvertedValue = math.pow(masterVolumeNewValue, eulersConstant)

	C_CVar.SetCVar(self.masterVolumeCVarName, masterVolumeConvertedValue)
end

function VolumeFrame:SetMasterVolumeFromPressedKey()
	local masterVolumePressedKey = self:GetMasterVolumePressedKey()

	if not masterVolumePressedKey then
		return
	end

	local volumeDown

	if masterVolumePressedKey == self.volumeDownKey then
		volumeDown = true
	end

	self:OffsetMasterVolume(volumeDown)
end

function VolumeFrame:OnUpdate(elapsed)
	self.keyElapsed = self.keyElapsed + elapsed

	if self.keyInitialTimeout and self.keyElapsed < self.keyInitialTimeout then
		return
	end

	self.keyInitialTimeout = nil

	if self.keyElapsed < self.keyTimeout then
		return
	end

	if not self:GetMasterVolumePressedKey() then
		self:StopVolumeUpdate()

		return
	end

	self.keyElapsed = 0

	self:SetMasterVolumeFromPressedKey()
end

function VolumeFrame:StartVolumeUpdate()
	self.keyElapsed = 0
	self.keyInitialTimeout = 0.3
	self.keyTimeout = 0.08

	self:SetMasterVolumeFromPressedKey()

	self:SetScript("OnUpdate", self.OnUpdate)
end

function VolumeFrame:StopVolumeUpdate()
	self:SetScript("OnUpdate", nil)
end

function VolumeFrame:GetMasterVolumePressedKey()
	if IsKeyDown(self.volumeDownKey) then
		return self.volumeDownKey
	end

	if IsKeyDown(self.volumeUpKey) then
		return self.volumeUpKey
	end
end

VolumeFrame:SetPropagateKeyboardInput(true)
VolumeFrame:SetScript("onKeyDown", function(self, key)
	if self:GetMasterVolumePressedKey() then
		self:StartVolumeUpdate()
	end
end)



-- addonData.CollectionsAPI:GetCollection("audio"):AddMixin("ui", function()end)
