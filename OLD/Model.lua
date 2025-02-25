local addonName, addonTable = ...


local characterModelFileIDs = {
	Dracthyr = {
		Male = 4395382, -- 4207724
		Female = 4207724,

		visage = {
			Male = nil,
			Female = 4220448,
		},
	},

	EarthenDwarf = {
		Male = 5548261,
	},

	Pandaren = {
		Male = 535052,
		Female = 589715,
	},


	DarkIronDwarf = {
		Male = 1890765,
		Female = nil,
	},

	Draenei = {
		Male = 1005887,
		Female = 1022598,
	},

	Dwarf = {
		Male = 878772,
		Female = 950080,
	},

	Gnome = {
		Male = 900914,
		Female = 940356,
	},

	Human = {
		Male = 1011653,
		Female = 1000764,
	},

	KulTiran = {
		Male = 1721003,
		Female = 1886724,
	},

	LightforgedDraenei = {
		Male = 1620605,
		Female = 1593999,
	},

	Mechagnome = {
		Male = 2622502,
		Female = nil,
	},

	NightElf = {
		Male = 974343,
		Female = 921844,
	},

	VoidElf = {
		Male = 1734034,
		Female = 1733758,
	},

	Worgen = {
		Male = 307454,
		Female = 307453,
	},


	BloodElf = {
		Male = 1100087,
		Female = 1100258,
	},

	Goblin = {
		Male = 119376,
		Female = 119369,
	},

	HighmountainTauren = {
		Male = 1630218,
		Female = 1630402,
	},

	MagharOrc = {
		Male = 1968587,
		Female = nil,
	},

	Nightborne = {
		Male = 1814471,
		Female = 1810676,
	},

	Orc = {
		Male = 917116,
		Female = 949470,
	},

	Tauren = {
		Male = 968705,
		Female = 986648,
	},

	Troll = {
		Male = 1022938,
		Female = 1018060,
	},

	Scourge = {
		Male = 959310,
		Female = 997378,
	},

	Vulpera = {
		Male = 1890761,
		Female = nil,
	},

	ZandalariTroll = {
		Male = 1630447,
		Female = 1662187,
	},
}


local Model = {}
addonTable.Model = Model

function Model:GetSexName(sexID)
	if sexID == 2 then
		return "Male"
	elseif sexID == 3 then
		return "Female"
	end

	return "Other"
end



local DressUpModelFrame = CreateFrame("DressUpModel", "DressUpModelFrame", UIParent)

DressUpModelFrame.textColor = addonTable.Color:GetColor("yellow")

DressUpModelFrame:Hide()
DressUpModelFrame:SetKeepModelOnHide(true)
DressUpModelFrame:SetPoint("Left")
DressUpModelFrame:SetSize(300, 500)

DressUpModelFrame.DressButton = CreateFrame("Button", nil, DressUpModelFrame)
DressUpModelFrame.DressButton:SetPoint("TopLeft")
DressUpModelFrame.DressButton:SetText("D")
DressUpModelFrame.DressButton:GetFontString():SetFont(addonTable.Font:GetDefaultFontFamily(), 12, "Outline")
DressUpModelFrame.DressButton:GetFontString():SetTextColor(DressUpModelFrame.textColor:GetRGB())
DressUpModelFrame.DressButton:SetSize(DressUpModelFrame.DressButton:GetFontString():GetSize())
DressUpModelFrame.DressButton:SetScript("OnClick", function(self)
	if UnitGUID("target") == self:GetParent().unitGUID then
		self:GetParent():Dress()
	end
end)

DressUpModelFrame.UndressButton = CreateFrame("Button", nil, DressUpModelFrame)
DressUpModelFrame.UndressButton:SetPoint("TopLeft", DressUpModelFrame.DressButton, "BottomLeft", 0, -2)
DressUpModelFrame.UndressButton:SetText("U")
DressUpModelFrame.UndressButton:GetFontString():SetFont(addonTable.Font:GetDefaultFontFamily(), 12, "Outline")
DressUpModelFrame.UndressButton:GetFontString():SetTextColor(DressUpModelFrame.textColor:GetRGB())
DressUpModelFrame.UndressButton:SetSize(DressUpModelFrame.UndressButton:GetFontString():GetSize())
DressUpModelFrame.UndressButton:SetScript("OnClick", function(self)
	self:GetParent():Undress()
end)

DressUpModelFrame.SheatheButton = CreateFrame("Button", nil, DressUpModelFrame)
DressUpModelFrame.SheatheButton:SetPoint("TopLeft", DressUpModelFrame.UndressButton, "BottomLeft", 0, -2)
DressUpModelFrame.SheatheButton:SetText("S")
DressUpModelFrame.SheatheButton:GetFontString():SetFont(DressUpModelFrame.UndressButton:GetFontString():GetFont())
DressUpModelFrame.SheatheButton:GetFontString():SetTextColor(DressUpModelFrame.textColor:GetRGB())
DressUpModelFrame.SheatheButton:SetSize(DressUpModelFrame.SheatheButton:GetFontString():GetSize())
DressUpModelFrame.SheatheButton:SetScript("OnClick", function(self)
	self:GetParent():SetSheathed(not self:GetParent():GetSheathed())
end)

DressUpModelFrame.UnitClass = DressUpModelFrame:CreateFontString()
DressUpModelFrame.UnitClass:SetPoint("BottomLeft")
DressUpModelFrame.UnitClass:SetFont(addonTable.Font:GetDefaultFontFamily(), 12, "Outline")
DressUpModelFrame.UnitClass:SetTextColor(DressUpModelFrame.textColor:GetRGB())

DressUpModelFrame.UnitRace = DressUpModelFrame:CreateFontString()
DressUpModelFrame.UnitRace:SetPoint("BottomLeft", DressUpModelFrame.UnitClass, "TopLeft", 0, 2)
DressUpModelFrame.UnitRace:SetFont(DressUpModelFrame.UnitClass:GetFont())
DressUpModelFrame.UnitRace:SetTextColor(DressUpModelFrame.UnitClass:GetTextColor())

DressUpModelFrame.UnitSex = DressUpModelFrame:CreateFontString()
DressUpModelFrame.UnitSex:SetPoint("BottomLeft", DressUpModelFrame.UnitRace, "TopLeft", 0, 2)
DressUpModelFrame.UnitSex:SetFont(DressUpModelFrame.UnitClass:GetFont())
DressUpModelFrame.UnitSex:SetTextColor(DressUpModelFrame.UnitClass:GetTextColor())

DressUpModelFrame.UnitName = DressUpModelFrame:CreateFontString()
DressUpModelFrame.UnitName:SetPoint("BottomLeft", DressUpModelFrame.UnitSex, "TopLeft", 0, 2)
DressUpModelFrame.UnitName:SetFont(DressUpModelFrame.UnitClass:GetFont())
DressUpModelFrame.UnitName:SetTextColor(DressUpModelFrame.UnitClass:GetTextColor())

function DressUpModelFrame:LeftButtonOnUpdate()
	local cursorX, cursorY = GetCursorPosition()

	local newX = (cursorX - self.cursorX) * 0.01

	self:SetFacing(self:GetFacing() + newX)

	self.cursorX = cursorX
	self.cursorY = cursorY
end

function DressUpModelFrame:RightButtonOnUpdate()
	local cursorX, cursorY = GetCursorPosition()
	local positionX, positionY, positionZ = self:GetPosition()

	local newX = (cursorX - self.cursorX) * 0.01
	local newY = (cursorY - self.cursorY) * 0.01

	self:SetPosition(positionX, positionY + newX, positionZ + newY)

	self.cursorX = cursorX
	self.cursorY = cursorY
end

function DressUpModelFrame:MoveOnUpdate()
	local cursorX, cursorY = GetCursorPosition()

	local effectiveScale = self:GetEffectiveScale()
	local x, y, width, height = self:GetRect()

	local effectiveHeight = height / effectiveScale
	local effectiveWidth = width / effectiveScale

	local newX = x + (cursorX - self.cursorX) / effectiveScale
	local newY = y + (cursorY - self.cursorY) / effectiveScale

	local maxX = GetScreenWidth() - width / effectiveScale

	if newX < 0 then
		newX = 0
	elseif newX > maxX then
		newX = maxX
	end

	self:ClearAllPoints()
	self:SetPoint("BottomLeft", UIParent, newX, newY)

	self.cursorX = cursorX
	self.cursorY = cursorY
end

function DressUpModelFrame:OnPlayerTargetChanged()
	if InCombatLockdown() then
		return
	end

	local unitToken = "target"

	local unitGUID = UnitGUID(unitToken)

	if unitGUID then
		self.unitGUID = unitGUID
	end

	if unitGUID then
		if unitGUID:find("^Player-") then
			local previousModelFileID = self:GetModelFileID()

			self:SetFacing(0)
			self:SetPosition(0, 0, 0)

			self:SetUnit(unitToken)

			C_Timer.After(0.25, function()
				local modelFileID = self:GetModelFileID()

				local race = select(2, UnitRace(unitToken))
				local sexName = Model:GetSexName(UnitSex(unitToken))

				if not race then
					return
				end

				local errorMessage

				if not characterModelFileIDs[race] then
					errorMessage = "Race not in table"
				elseif not characterModelFileIDs[race][sexName] then
					errorMessage = "Sex not in table"
				elseif characterModelFileIDs[race][sexName] ~= modelFileID then
					if race == "Orc" and sexName == "Male" and modelFileID == characterModelFileIDs["MagharOrc"][sexName] then
					elseif race == "Dracthyr" and modelFileID == characterModelFileIDs[race].visage[sexName] then
					else
						errorMessage = "Model File ID does not match"
					end
				end

				if errorMessage then
					DEFAULT_CHAT_FRAME:AddMessage(
						string.format("%s: %s %s %s", errorMessage, race, sexName, modelFileID or "<Missing modelFileID>")
					)
				end
			end)

			if not previousModelFileID then
				self:SetSheathed(true)
			end

			local unitName, unitRealm = UnitName(unitToken)

			local unitFullName = unitName

			if unitRealm then
				unitFullName = unitFullName .. "-" .. unitRealm
			end

			self.UnitClass:SetText(UnitClass(unitToken))
			self.UnitName:SetText(unitFullName)
			self.UnitRace:SetText(UnitRace(unitToken))
			self.UnitSex:SetText(Model:GetSexName(UnitSex(unitToken)))

			self.UnitClass:SetTextColor(C_ClassColor.GetClassColor(select(2, UnitClass(unitToken))):GetRGB())

			-- self:Show()
		end
	else
		-- self:Hide()
	end

	-- /run DressUpModelFrame:Show() DressUpModelFrame:SetModel(1011653)
	-- /run DressUpModelFrame:Show() DressUpModelFrame:SetDisplayInfo(111496, 111496)
	-- /run DressUpModelFrame:Show() DressUpModelFrame:TryOn("item:207290")
end

DressUpModelFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
DressUpModelFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
DressUpModelFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
DressUpModelFrame:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_REGEN_DISABLED" then
		self.wasShown = self:IsShown()
		self:Hide()
	elseif event == "PLAYER_REGEN_ENABLED" then
		if self.wasShown then
			-- self:Show()
		end
	elseif event == "PLAYER_TARGET_CHANGED" then
		self:OnPlayerTargetChanged()
	end
end)

DressUpModelFrame:SetScript("OnMouseDown", function(self, key)
	self.cursorX, self.cursorY = GetCursorPosition()

	if IsShiftKeyDown() then
		self:SetScript("OnUpdate", self.MoveOnUpdate)
	else
		if key == "LeftButton" then
			self:SetScript("OnUpdate", self.LeftButtonOnUpdate)
		elseif key == "MiddleButton" then
			self:SetFacing(0)
			self:SetPosition(0, 0, 0)
		elseif key == "RightButton" then
			self:SetScript("OnUpdate", self.RightButtonOnUpdate)
		end
	end
end)

DressUpModelFrame:SetScript("OnMouseUp", function(self, key)
	self:SetScript("OnUpdate", nil)
end)

DressUpModelFrame:SetScript("OnMouseWheel", function(self, delta)
	if IsShiftKeyDown() then
		self:SetScale(math.max(0.5, self:GetScale() + delta * 0.1))
	else
		local positionX, positionY, positionZ = self:GetPosition()

		self:SetPosition(positionX + (0.2 * delta), positionY, positionZ)
	end
end)


















local ModelSceneContainerFrame = CreateFrame("Frame", nil, UIParent)

ModelSceneContainerFrame.defaultFont = {addonTable.Font:GetDefaultFontFamily(), 12, "Outline"}
ModelSceneContainerFrame.defaultFontSmall = {addonTable.Font:GetDefaultFontFamily(), 10, "Outline"}
ModelSceneContainerFrame.defaultSelectedTextColor = addonTable.Color:GetColor("blue")
ModelSceneContainerFrame.defaultTextColor = addonTable.Color:GetColor("yellow")

ModelSceneContainerFrame:Hide()
ModelSceneContainerFrame:SetPoint("Top", 0, -10)
ModelSceneContainerFrame:SetSize(360, 600)

ModelSceneContainerFrame.Background = ModelSceneContainerFrame:CreateTexture("Background")
ModelSceneContainerFrame.Background:SetAllPoints()
ModelSceneContainerFrame.Background:SetColorTexture(0, 0, 0, 0.2)

ModelSceneContainerFrame.TopBarFrame = CreateFrame("Frame", nil, ModelSceneContainerFrame)
ModelSceneContainerFrame.TopBarFrame:SetPoint("Right")
ModelSceneContainerFrame.TopBarFrame:SetPoint("TopLeft")
ModelSceneContainerFrame.TopBarFrame:SetHeight(ModelSceneContainerFrame.defaultFont[2] + 2)

ModelSceneContainerFrame.TopBarFrame.MoveOnUpdate = function(self)
	local MoveFrame = ModelSceneContainerFrame

	local cursorX, cursorY = GetCursorPosition()

	local effectiveScale = MoveFrame:GetEffectiveScale()
	local x, y, width, height = MoveFrame:GetRect()

	local newX = x + (cursorX - self.cursorX) / effectiveScale
	local newY = y + (cursorY - self.cursorY) / effectiveScale

	MoveFrame:ClearAllPoints()
	MoveFrame:SetPoint("BottomLeft", newX, newY)

	self.cursorX = cursorX
	self.cursorY = cursorY
end

ModelSceneContainerFrame.TopBarFrame:SetScript("OnMouseDown", function(self)
	self.cursorX, self.cursorY = GetCursorPosition()

	self:SetScript("OnUpdate", self.MoveOnUpdate)
end)

ModelSceneContainerFrame.TopBarFrame:SetScript("OnMouseUp", function(self)
	self:SetScript("OnUpdate", nil)
end)

ModelSceneContainerFrame.Title = ModelSceneContainerFrame.TopBarFrame:CreateFontString()
ModelSceneContainerFrame.Title:SetFont(unpack(ModelSceneContainerFrame.defaultFont))
ModelSceneContainerFrame.Title:SetPoint("Center")
ModelSceneContainerFrame.Title:SetText("Model")
ModelSceneContainerFrame.Title:SetTextColor(ModelSceneContainerFrame.defaultTextColor:GetRGB())

ModelSceneContainerFrame.HideButton = addonTable.Button:CreateButton({
	font = ModelSceneContainerFrame.defaultFont,
	parent = ModelSceneContainerFrame.TopBarFrame,
	text = "x",
	textColor = ModelSceneContainerFrame.defaultTextColor,
})
ModelSceneContainerFrame.HideButton:ResizeToText()
ModelSceneContainerFrame.HideButton:SetPoint("Bottom")
ModelSceneContainerFrame.HideButton:SetPoint("TopRight")

ModelSceneContainerFrame.HideButton:SetScript("OnClick", function()
	ModelSceneContainerFrame:Hide()
end)


local ModelSceneContainerShowButton = addonTable.Button:CreateButton({
	font = ModelSceneContainerFrame.defaultFont,
	parent = UIParent,
	text = "Show Model",
	textColor = ModelSceneContainerFrame.defaultTextColor,
})
ModelSceneContainerShowButton:ResizeToText()
ModelSceneContainerShowButton:SetPoint("TopLeft")

if ModelSceneContainerFrame:IsShown() then
	ModelSceneContainerShowButton:Hide()
else
	ModelSceneContainerShowButton:Show()
end

ModelSceneContainerShowButton:SetScript("OnClick", function(self)
	ModelSceneContainerFrame:Show()
	self:Hide()
end)

addonTable.C_FrameHide:SetupFrame(ModelSceneContainerShowButton)

ModelSceneContainerFrame:SetScript("OnHide", function()
	ModelSceneContainerShowButton:Show()
end)


local ModelSceneFrame = CreateFrame("ModelScene", "ModelSceneFrame", ModelSceneContainerFrame)

ModelSceneFrame.actors = {}

ModelSceneFrame:SetPoint("BottomRight")
ModelSceneFrame:SetPoint("Left")
ModelSceneFrame:SetPoint("Top", ModelSceneContainerFrame.TopBarFrame, "Bottom")

function ModelSceneFrame:HideActors()
	local actorIndex = 1

	while true do
		local Actor = self:GetActorAtIndex(actorIndex)

		if not Actor then
			break
		end

		Actor:Hide()

		actorIndex = actorIndex + 1
	end
end

function ModelSceneFrame:IsTargetPlayableCharacter(unitToken)
	local unitGUID = UnitGUID(unitToken)

	if unitGUID then
		return not not unitGUID:find("^Player-")
	end
end

function ModelSceneFrame:SavePlayerActor()
	local unitToken = "player"

	local unitRace = select(2, UnitRace(unitToken))
	local unitSex = Model:GetSexName(UnitSex(unitToken))

	if self.actors[unitRace] then
		if self.actors[unitRace][unitSex] then
			return
		end
	end

	local Actor = self:CreateActor()
	Actor:Hide()
	Actor:SetModelByUnit(unitToken)

	self:SetActorDefaultPosition(Actor)

	if not self.actors[unitRace] then
		self.actors[unitRace] = {}
	end

	self.actors[unitRace][unitSex] = Actor

	return Actor
end

function ModelSceneFrame:SaveTargetActor()
	local unitToken = "target"

	if not self:IsTargetPlayableCharacter(unitToken) then
		return
	end

	local playerUnitToken = "player"

	local playerRace = select(2, UnitRace(playerUnitToken))
	local playerSex = Model:GetSexName(UnitSex(playerUnitToken))
	local unitRace = select(2, UnitRace(unitToken))
	local unitSex = Model:GetSexName(UnitSex(unitToken))

	if playerRace == unitRace and playerSex == unitSex then
		return
	end

	if self.actors[unitRace] then
		if self.actors[unitRace][unitSex] then
			return
		end
	end

	local Actor = self:CreateActor()
	Actor:Hide()
	Actor:SetModelByUnit(unitToken)

	self:SetActorDefaultPosition(Actor)

	if not self.actors[unitRace] then
		self.actors[unitRace] = {}
	end

	self.actors[unitRace][unitSex] = Actor

	return Actor
end

function ModelSceneFrame:SetActorDefaultPosition(Actor)
	Actor:SetPosition(5, 0, -1.25)
	Actor:SetRoll(0)
	Actor:SetYaw(math.pi)
end

function ModelSceneFrame:SetCurrentActor(race, sex)
	if not race then
		if not self.activeRace then
			self.activeRace = select(2, UnitRace("player"))
		end

		race = self.activeRace
	end

	if not sex then
		if not self.activeSex then
			self.activeSex = Model:GetSexName(UnitSex("player"))
		end

		sex = self.activeSex
	end

	local Actor

	if race == "default" then
		Actor = self.actors.default
	else
		local raceData = self.actors[race]

		if raceData then
			Actor = raceData[sex]

			self.activeRace = race
			self.activeSex = sex
		end
	end

	if not Actor then
		return
	end

	self.currentActor = Actor

	self:HideActors()

	Actor:Show()
end

function ModelSceneFrame:SetModelByTarget()
	local unitToken = "target"

	if not self:IsTargetPlayableCharacter(unitToken) then
		return
	end

	self:HideActors()

	self.currentActor = self.actors.default

	local previousSheathe = self.currentActor:GetSheathed()

	self.currentActor:SetModelByUnit(unitToken)
	self.currentActor:SetSheathed(previousSheathe)
	self.currentActor:Show()
end



ModelSceneFrame.UndressButton = addonTable.Button:CreateButton({
	font = ModelSceneContainerFrame.defaultFont,
	parent = ModelSceneFrame,
	text = "U",
	textColor = ModelSceneContainerFrame.defaultTextColor,
})
ModelSceneFrame.UndressButton:SetPoint("TopLeft")
ModelSceneFrame.UndressButton:ResizeToText()

ModelSceneFrame.UndressButton:SetScript("OnClick", function()
	local currentActor = ModelSceneFrame.currentActor

	if not currentActor then
		return
	end

	currentActor:Undress()
end)

ModelSceneFrame.SheatheButton = addonTable.Button:CreateButton({
	font = ModelSceneContainerFrame.defaultFont,
	parent = ModelSceneFrame,
	text = "S",
	textColor = ModelSceneContainerFrame.defaultTextColor,
})
ModelSceneFrame.SheatheButton:SetPoint("TopLeft", ModelSceneFrame.UndressButton, "BottomLeft")
ModelSceneFrame.SheatheButton:ResizeToText()

ModelSceneFrame.SheatheButton:SetScript("OnClick", function()
	local currentActor = ModelSceneFrame.currentActor

	if not currentActor then
		return
	end

	currentActor:SetSheathed(not currentActor:GetSheathed())
end)

ModelSceneFrame.ModelTypeDropdownMenu = addonTable.DropdownMenu:CreateDropdownMenu({
	font = ModelSceneContainerFrame.defaultFontSmall,
	name = "ModelTypeDropdownMenu",
	parent = ModelSceneFrame,
	text = "Race",

	OnSelectionChange = function(value)
		ModelSceneFrame:SetCurrentActor(value)
	end,
})
ModelSceneFrame.ModelTypeDropdownMenu:SetPoint("TopRight")
ModelSceneFrame.ModelTypeDropdownMenu:ResizeToText()

local sortedRaceSex = {}

for race, _ in pairs(characterModelFileIDs) do
	table.insert(sortedRaceSex, race)
end

table.sort(sortedRaceSex)

for _, race in ipairs(sortedRaceSex) do
	ModelSceneFrame.ModelTypeDropdownMenu:AddSelection(race)
end


local function MaleFemaleButtonOnClick(self)
	ModelSceneFrame:SetCurrentActor(nil, self.sex)

	self:GetTextFontString():SetTextColor(ModelSceneContainerFrame.defaultSelectedTextColor:GetRGB())

	local activeButton

	if self == ModelSceneFrame.FemaleButton then
		activeButton = ModelSceneFrame.MaleButton
	else
		activeButton = ModelSceneFrame.FemaleButton
	end

	activeButton:GetTextFontString():SetTextColor(ModelSceneContainerFrame.defaultTextColor:GetRGB())
end

ModelSceneFrame.FemaleButton = addonTable.Button:CreateButton({
	font = ModelSceneContainerFrame.defaultFontSmall,
	parent = ModelSceneFrame,
	text = "F",
})
ModelSceneFrame.FemaleButton.sex = "Female"
ModelSceneFrame.FemaleButton:ResizeToText()
ModelSceneFrame.FemaleButton:SetPoint("Right", ModelSceneFrame.ModelTypeDropdownMenu, "Left", -5, 0)
ModelSceneFrame.FemaleButton:SetScript("OnClick", MaleFemaleButtonOnClick)

ModelSceneFrame.MaleButton = addonTable.Button:CreateButton({
	font = ModelSceneContainerFrame.defaultFontSmall,
	parent = ModelSceneFrame,
	text = "M",
})
ModelSceneFrame.MaleButton.sex = "Male"
ModelSceneFrame.MaleButton:ResizeToText()
ModelSceneFrame.MaleButton:SetPoint("Right", ModelSceneFrame.FemaleButton, "Left")
ModelSceneFrame.MaleButton:SetScript("OnClick", MaleFemaleButtonOnClick)

if UnitSex("player") == 2 then
	ModelSceneFrame.MaleButton:Click()
else
	ModelSceneFrame.FemaleButton:Click()
end


ModelSceneFrame.actors.default = ModelSceneFrame:CreateActor()
ModelSceneFrame:SetActorDefaultPosition(ModelSceneFrame.actors.default)


ModelSceneFrame:RegisterEvent("FIRST_FRAME_RENDERED")
ModelSceneFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
ModelSceneFrame:SetScript("OnEvent", function(self, event)
	if event == "FIRST_FRAME_RENDERED" then
		self:SavePlayerActor()
		self:SetCurrentActor()
	elseif event == "PLAYER_TARGET_CHANGED" then
		self:SetModelByTarget()
		self:SaveTargetActor()
	end
end)
