local addonName, addonData = ...


local MOUNT_IDS = {
	passenger = {
		[273] = true,
		[274] = true,
		[286] = true,
		[287] = true,
		[288] = true,
		[289] = true,
		[382] = true,
		[407] = true,
		[455] = true,
	},
}

local KNOWN_MOUNT_IDS = {
	fly = {},
	ground = {},
	passenger = {
		fly = {},
		ground = {},
	},
	swim = {},
}

local KNOWN_MOUNT_IDS_POPULATED = false

local MOUNT_TYPE_IDS = {
	fly = {
		[248] = true,
		[407] = true,
		[424] = true,
		[436] = true,
	},

	rideAlong = {
		[402] = true,
		[445] = true,
	},

	swim = {
		[231] = true,
		[254] = true,
		[412] = true,
	},
}

local BANNED_MOUNT_TYPE_IDS = {
	ground = {
		[231] = true,
		[254] = true,
	},
}

local FLYING_SPELL_NAMES = {
	"Artisan Riding",
	"Expert Riding",
	"Master Riding",
}



local function GetMacroIndex(macroName)
	local accountMacroCount, characterMacroCount = GetNumMacros()

	local macroIndexesInfo = {
		{
			count = characterMacroCount,
			start = MAX_ACCOUNT_MACROS + 1,
		},
		{
			count = accountMacroCount,
			start = 1,
		},
	}

	for _, macroIndexInfo in ipairs(macroIndexesInfo) do
		local macroStartIndex = macroIndexInfo.start

		local macroEndIndex = macroStartIndex + macroIndexInfo.count - 1

		for macroIndex = macroStartIndex, macroEndIndex do
			if GetMacroInfo(macroIndex) == macroName then
				return macroIndex
			end
		end
	end
end



local IMPORTS = {
	character = {
		api = true,
	},

	container = {
		api = true,
	},

	table = {
		api = true,
	},
}


addonData.CollectionsAPI:GetCollection("mount"):AddMixin("api", IMPORTS, function()
	local MountAPI = {}

	function MountAPI:GetMountMacroName()
		return string.format('Mount (%s)', addonName)
	end

	function MountAPI:GetSwimmingMountMacroName()
		return string.format('Swimming Mount (%s)', addonName)
	end

	function MountAPI:CanMountFly(mountID)
		local mountTypeID = select(5, C_MountJournal.GetMountInfoExtraByID(mountID))

		if MOUNT_TYPE_IDS.fly[mountTypeID] then
			return true
		end

		return false
	end

	function MountAPI:IsViableGroundMount(mountID)
		local mountTypeID = select(5, C_MountJournal.GetMountInfoExtraByID(mountID))

		if BANNED_MOUNT_TYPE_IDS.ground[mountTypeID] then
			return false
		end

		return true
	end

	function MountAPI:IsViableSwimmingMount(mountID)
		local mountTypeID = select(5, C_MountJournal.GetMountInfoExtraByID(mountID))

		if MOUNT_TYPE_IDS.swim[mountTypeID] then
			return true
		end

		return false
	end

	function MountAPI:IsPassengerMount(mountID)
		if MOUNT_IDS.passenger[mountID] then
			return true
		end

		if IsSpellKnown(447959) then
			local mountTypeID = select(5, C_MountJournal.GetMountInfoExtraByID(mountID))

			if MOUNT_TYPE_IDS.rideAlong[mountTypeID] then
				return true
			end
		end

		return false
	end

	function MountAPI:CanPlayerFly()
		if not IsFlyableArea() then
			return false
		end

		for _, flyingSpellName in ipairs(FLYING_SPELL_NAMES) do
			if C_Spell.GetSpellInfo(flyingSpellName) then
				return true
			end
		end

		return false
	end

	function MountAPI:GetAllMountTypeIDs()
		local mountTypeIDs = {}

		for _, mountID in ipairs(C_MountJournal.GetMountIDs()) do
			local mountTypeID = select(5, C_MountJournal.GetMountInfoExtraByID(mountID))

			local specificMountTypeIDs = mountTypeIDs[mountTypeID]

			if not specificMountTypeIDs then
				specificMountTypeIDs = {}
				mountTypeIDs[mountTypeID] = specificMountTypeIDs
			else
				local mountName = C_MountJournal.GetMountInfoByID(mountID)

				table.insert(specificMountTypeIDs, mountName)
			end
		end

		return mountTypeIDs
	end

	function MountAPI:GetBestMountInfo()
		if not KNOWN_MOUNT_IDS_POPULATED then
			self:PopulateMountIDs()
		end

		local mountIDOrName
		local mountMacroBody

		local unitClass = UnitClass('player')

		-- if unitClass == 'Druid' then
		-- 	mountMacroBody = '#showtooltip\n/cast [outdoors] Travel Form(Shapeshift); Cat Form(Shapeshift)'
		if UnitInOtherParty('player') then
			mountIDOrName = self:GetBestPassengerMountID()
		elseif self:CanPlayerFly() then
			-- if addonTable.Container:IsItemOnPlayer(37011) then -- addonTable.Calendar:IsEventActive("Hallow's End")
			-- 	mountIDOrName = 'Magic Broom'
			-- end

			mountIDOrName = self:GetMountID(Enum.MountType.Flying) or self:GetRandomFlyingMountID()
		elseif IsSwimming() then
			mountIDOrName = self:GetRandomSwimmingMountID()
		end

		if not mountMacroBody then
			if not mountIDOrName then
				mountIDOrName = self:GetMountID(Enum.MountType.Ground) or self:GetRandomGroundMountID()
			end

			if not mountIDOrName then
				mountIDOrName = self:GetRandomFlyingMountID() or self:GetRandomGroundMountID()
			end
		end

		return mountIDOrName, mountMacroBody
	end

	function MountAPI:GetBestPassengerMountID()
		for _, mountID in ipairs(KNOWN_MOUNT_IDS.passenger) do
			if C_MountJournal.GetMountUsabilityByID(mountID, false) then
				return mountID
			end
		end
	end

	function MountAPI:GetMountID(mountTypeID)
		local characterSpecializationVariables = IMPORTS.character.api:GetCharacterSpecializationData()

		if (not characterSpecializationVariables) or (not characterSpecializationVariables.mounts) then
			return
		end

		return characterSpecializationVariables.mounts[mountTypeID]
	end

	function MountAPI:GetRandomFlyingMountID()
		return IMPORTS.table.api:GetRandomItem(KNOWN_MOUNT_IDS.fly)
	end

	function MountAPI:GetRandomGroundMountID()
		return IMPORTS.table.api:GetRandomItem(KNOWN_MOUNT_IDS.ground)
	end

	function MountAPI:GetRandomSwimmingMountID()
		return IMPORTS.table.api:GetRandomItem(KNOWN_MOUNT_IDS.swim)
	end

	function MountAPI:PopulateMountIDs()
		for _, mountID in ipairs(C_MountJournal.GetMountIDs()) do
			if C_MountJournal.GetMountUsabilityByID(mountID, false) then
				local canMountFly = self:CanMountFly(mountID)

				if canMountFly then
					table.insert(KNOWN_MOUNT_IDS.fly, mountID)
				elseif self:IsViableGroundMount(mountID) then
					table.insert(KNOWN_MOUNT_IDS.ground, mountID)
				end

				if self:IsPassengerMount(mountID) then
					if canMountFly then
						table.insert(KNOWN_MOUNT_IDS.passenger.fly, mountID)
					else
						table.insert(KNOWN_MOUNT_IDS.passenger.ground, mountID)
					end
				end

				if self:IsViableSwimmingMount(mountID) then
					table.insert(KNOWN_MOUNT_IDS.swim, mountID)
				end
			end
		end

		KNOWN_MOUNT_IDS_POPULATED = true
	end

	function MountAPI:SetMount(mountTypeID, mountID)
		local characterSpecializationVariables = IMPORTS.character.api:GetCharacterSpecializationData()

		if not characterSpecializationVariables then
			return
		end

		if not characterSpecializationVariables.mounts then
			characterSpecializationVariables.mounts = {}
		end

		characterSpecializationVariables.mounts[mountTypeID] = mountID

		self:UpdateMountMacro()
	end

	function MountAPI:UpdateMountMacro()
		if UnitAffectingCombat("player") then
			return
		end

		local mountIDOrName, mountMacroBody = self:GetBestMountInfo()

		if not mountMacroBody then
			local mountName

			if type(mountIDOrName) == 'number' then
				mountName = C_MountJournal.GetMountInfoByID(mountIDOrName)
			else
				mountName = mountIDOrName
			end

			if mountName then
				mountMacroBody = string.format(
					'#showtooltip %s\n/dismount [mounted]\n/cast [nomounted] %s',
					mountName,
					mountName
				)
			end
		end

		if not mountMacroBody then
			return
		end

		local macroName = self:GetMountMacroName()

		local macroIndex = GetMacroIndex(macroName)

		if macroIndex then
			EditMacro(macroIndex, nil, nil, mountMacroBody)
		else
			CreateMacro(macroName, "INV_Misc_QuestionMark", mountMacroBody)
		end
	end

	function MountAPI:UpdateSwimmingMountMacro()
		if not IsSwimming() then
			return
		end

		if UnitAffectingCombat('player') then
			return
		end

		local mountIDOrName = self:GetRandomSwimmingMountID()

		if not mountIDOrName then
			return
		end

		local mountName

		if type(mountIDOrName) == 'number' then
			mountName = C_MountJournal.GetMountInfoByID(mountIDOrName)
		else
			mountName = mountIDOrName
		end

		local mountMacroBody = string.format(
			'#showtooltip %s\n/dismount [mounted]\n/cast [nomounted] %s',
			mountName,
			mountName
		)

		local macroName = self:GetSwimmingMountMacroName()

		local macroIndex = GetMacroIndex(macroName)

		if macroIndex then
			EditMacro(macroIndex, nil, nil, mountMacroBody)
		else
			CreateMacro(macroName, 'INV_Misc_QuestionMark', mountMacroBody)
		end
	end


	return MountAPI
end)
