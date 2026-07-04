local addonName, addonData = ...


local races = {
	[1] = 'Human',
	[2] = 'Orc',
	[3] = 'Dwarf',
	[4] = 'Night Elf',
	[5] = 'Undead',
	[6] = 'Tauren',
	[7] = 'Gnome',
	[8] = 'Troll',
	[9] = 'Goblin',
	[10] = 'Blood Elf',
	[11] = 'Draenei',
	[22] = 'Worgen',
	[26] = 'Pandaren (Horde)',
	[27] = 'Nightborne',
	[28] = 'Highmountain Tauren',
	[29] = 'Void Elf',
	[30] = 'Lightforged Draenei',
	[31] = 'Zandalari Troll',
	[32] = 'Kul Tiran',
	[34] = 'Dark Iron Dwarf',
	[35] = 'Vulpera',
	[36] = "Mag'har Orc",
	[37] = 'Mechagnome',
	[52] = 'Dracthyr (Alliance)',
	[70] = 'Dracthyr (Horde)',
	[84] = 'Earthen (Horde)',
	[85] = 'Earthen (Alliance)',

	[24] = 'Pandaren',
	[25] = 'Pandaren',
}


local sexes = {
	[2] = 'Male',
	[3] = 'Female',
}

local function getSexName(sexID)
	return sexes[sexID]
end

local function getSexID(sexName)
	return sexes[sexName]
end


local sortedRacesInfo = {}

for raceID, raceName in pairs(races) do
	table.insert(sortedRacesInfo, {
		raceID = raceID,
		raceName = raceName,
	})
end

table.sort(sortedRacesInfo, function(a, b)
	return a.raceName < b.raceName
end)



local playerRaceID = select(3, UnitRace('player'))
local playerSexID = UnitSex('player')



local unitModelFrames = {}




local AppearanceEventFrame = CreateFrame('frame')

AppearanceEventFrame:RegisterEvent('ADDON_LOADED')
AppearanceEventFrame:RegisterEvent('NAME_PLATE_UNIT_ADDED')

AppearanceEventFrame.selectedRaceID = playerRaceID
AppearanceEventFrame.selectedSexID = playerSexID


local function positionModelFrame(UnitModelFrame)
	local DefaultModelFrame = WardrobeCollectionFrame.SetsCollectionFrame.Model

	UnitModelFrame:SetParent(DefaultModelFrame:GetParent())
	UnitModelFrame:SetPoint('top', WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame.IconRowBackground, 'bottom')
	UnitModelFrame:SetPoint('left', DefaultModelFrame)
	UnitModelFrame:SetPoint('bottomRight', DefaultModelFrame)
end

local function createRaceDropdown()
	local RaceDropdownButton = CreateFrame('dropdownButton', nil, WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame, 'WowStyle1DropdownTemplate')

	AppearanceEventFrame.RaceDropdownButton = RaceDropdownButton

	RaceDropdownButton:SetPoint('topLeft', 6, -6)

	RaceDropdownButton:SetupMenu(function(self, menuMixin)
		local radioIsSelected = function(raceID, ...)
			if raceID == AppearanceEventFrame.selectedRaceID then
				local DefaultModelFrame = WardrobeCollectionFrame.SetsCollectionFrame.Model

				local CurrentModelFrame

				for unitModelRaceID, raceModels in pairs(unitModelFrames) do
					for unitModelSexID, UnitModelFrame in pairs(raceModels) do
						if unitModelRaceID == raceID then
							CurrentModelFrame = UnitModelFrame
						else
							UnitModelFrame:Hide()
						end
					end
				end

				if raceID == playerRaceID then
					CurrentModelFrame = DefaultModelFrame
				else
					DefaultModelFrame:Hide()
				end

				CurrentModelFrame:Show()
				CurrentModelFrame:Undress()

				local selectedSetID = WardrobeCollectionFrame.SetsCollectionFrame.selectedSetID

				if selectedSetID then
					for _, appearanceInfo in ipairs(C_TransmogSets.GetSetPrimaryAppearances(selectedSetID)) do
						local appearanceID = appearanceInfo.appearanceID

						CurrentModelFrame:TryOn(appearanceID)
					end
				end

				return true
			end

			return false
		end

		local radioSetSelected = function(raceID)
			if raceID == playerRaceID or unitModelFrames[raceID] then
				AppearanceEventFrame.selectedRaceID = raceID
			end
		end

		for _, raceInfo in pairs(sortedRacesInfo) do
			local raceID = raceInfo.raceID
			local raceName = raceInfo.raceName

			local RaceRadioButton = menuMixin:CreateRadio(raceName, radioIsSelected, radioSetSelected, raceID)

			if raceID ~= playerRaceID then
				if not unitModelFrames[unitRaceID] then
					RaceRadioButton:SetEnabled(false)
				end
			end
		end
	end)
end

local function createSexButtons()
	local sexButtonTextColor = {0.6, 0.6, 0.6}
	local sexButtonSelectedTextColor = {1, 0.8, 0}

	local ActiveSexButton

	local function sexButtonOnClick(self)
		if ActiveSexButton then
			ActiveSexButton.fontString:SetTextColor(unpack(sexButtonTextColor))
		end

		ActiveSexButton = self

		AppearanceEventFrame.selectedSexID = self.sexID

		self.fontString:SetTextColor(unpack(sexButtonSelectedTextColor))
	end

	local function createSexButton(sexID)
		local SexButton = CreateFrame('button', nil, WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame)

		SexButton.sexID = sexID

		SexButton.fontString = SexButton:CreateFontString()
		SexButton.fontString:SetPoint('center')
		SexButton.fontString:SetFont('fonts/FRIZQT__.ttf', 10, 'outline')
		SexButton.fontString:SetText(sexes[sexID])
		SexButton.fontString:SetTextColor(unpack(sexButtonTextColor))

		SexButton:SetSize(SexButton.fontString:GetSize())

		SexButton:SetScript('onClick', sexButtonOnClick)

		return SexButton
	end

	local MaleSexButton = createSexButton(2)
	MaleSexButton:SetPoint('bottomLeft', AppearanceEventFrame.RaceDropdownButton, 'right', 3, 0)

	local FemaleSexButton = createSexButton(3)
	FemaleSexButton:SetPoint('topLeft', MaleSexButton, 'bottomLeft')

	if playerSexID == 2 then
		MaleSexButton:Click()
	else
		FemaleSexButton:Click()
	end
end


function AppearanceEventFrame:HandleAddonLoaded(event, addonName)
	if addonName == 'Blizzard_Collections' then
		for raceID, raceModels in pairs(unitModelFrames) do
			for sexID, UnitModelFrame in pairs(raceModels) do
				positionModelFrame(UnitModelFrame)
			end
		end


		createRaceDropdown()

		createSexButtons()
	end
end

function AppearanceEventFrame:HandleNameplateAdded(event, nameplateUnit)
	if UnitAffectingCombat('player') then
		return
	end

	local unitGUID = UnitGUID(nameplateUnit)

	if not unitGUID:match('^Player%-') then
		return
	end

	if unitGUID == UnitGUID('player') then
		return
	end

	local playerRaceID = select(3, UnitRace('player'))
	local playerSexID = UnitSex('player')

	local unitRaceID = select(3, UnitRace(nameplateUnit))
	local unitSexID = UnitSex(nameplateUnit)

	if unitRaceID == playerRaceID and unitSexID == playerSexID then
		return
	end

	local raceModels = unitModelFrames[unitRaceID]

	if raceModels then
		if raceModels[unitSexID] then
			return
		end
	end

	local UnitModelFrame = CreateFrame('dressUpModel')

	UnitModelFrame:SetUnit(nameplateUnit)

	if not raceModels then
		raceModels = {}

		unitModelFrames[unitRaceID] = raceModels
	end

	raceModels[unitSexID] = UnitModelFrame

	UnitModelFrame:Hide()

	UnitModelFrame:SetScript('OnMouseDown', print)
	UnitModelFrame:SetScript('OnMouseUp', print)

	UnitModelFrame:SetScript('OnMouseWheel', print)

	if C_AddOns.IsAddOnLoaded('Blizzard_Collections') then
		positionModelFrame(UnitModelFrame)
	end
end


AppearanceEventFrame:SetScript('onEvent', function(self, event, ...)
	if event == 'ADDON_LOADED' then
		self:HandleAddonLoaded(event, ...)
	elseif event == 'NAME_PLATE_UNIT_ADDED' then
		self:HandleNameplateAdded(event, ...)
	end
end)
