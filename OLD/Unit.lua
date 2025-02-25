local addonName, addonData = ...

local unitMethods = {
	UnitAffectingCombat = {},
	UnitAlliedRaceInfo = {},
	UnitArmor = {},
	UnitAttackPower = {},
	UnitAttackSpeed = {},
	UnitBattlePetLevel = {},
	UnitBattlePetSpeciesID = {},
	UnitBattlePetType = {},
	UnitCanAssist = {},
	UnitCanAttack = {},
	UnitCanCooperate = {},
	UnitCanPetBattle = {},
	UnitCastingInfo = {},
	UnitChannelInfo = { description = "Channeled spell info", },
	UnitChromieTimeID = {},
	UnitClass = {},
	UnitClassBase = {},
	UnitClassification = {},
	UnitControllingVehicle = {},
	UnitCreatureFamily = {},
	UnitCreatureType = {},
	UnitDamage = {},
	UnitDetailedThreatSituation = {},
	UnitDistanceSquared = {},
	UnitEffectiveLevel = {},
	UnitExists = {},
	UnitFactionGroup = {},
	UnitFullName = {},
	UnitGetAvailableRoles = {},
	UnitGetIncomingHeals = {},
	UnitGetTotalAbsorbs = {},
	UnitGetTotalHealAbsorbs = {},
	UnitGroupRolesAssigned = {},
	UnitGroupRolesAssignedEnum = {},
	UnitGUID = {},
	UnitHasIncomingResurrection = {},
	UnitHasLFGDeserter = {},
	UnitHasLFGRandomCooldown = {},
	UnitHasMana = {},
	UnitHasRelicSlot = {},
	UnitHasVehiclePlayerFrameUI = {},
	UnitHasVehicleUI = {},
	UnitHealth = {},
	UnitHealthMax = {},
	UnitHonor = {},
	UnitHonorLevel = {},
	UnitHonorMax = {},
	UnitHPPerStamina = {},
	UnitInAnyGroup = {},
	UnitInBattleground = {},
	UnitInOtherParty = {},
	UnitInParty = {},
	UnitInPartyIsAI = {},
	UnitInPartyShard = {},
	UnitInRaid = {},
	UnitInRange = {},
	UnitInSubgroup = {},
	UnitInVehicle = {},
	UnitInVehicleControlSeat = {},
	UnitInVehicleHidesPetFrame = {},
	UnitIsAFK = {},
	UnitIsBattlePet = {},
	UnitIsBattlePetCompanion = {},
	UnitIsBossMob = {},
	UnitIsCharmed = {},
	UnitIsConnected = {},
	UnitIsControlling = {},
	UnitIsCorpse = {},
	UnitIsDead = {},
	UnitIsDeadOrGhost = {},
	UnitIsDND = {},
	UnitIsEnemy = {},
	UnitIsFeignDeath = {},
	UnitIsFriend = {},
	UnitIsGameObject = {},
	UnitIsGhost = {},
	UnitIsGroupAssistant = {},
	UnitIsGroupLeader = {},
	UnitIsInMyGuild = {},
	UnitIsInteractable = {},
	UnitIsMercenary = {},
	UnitIsOtherPlayersBattlePet = {},
	UnitIsOtherPlayersPet = {},
	UnitIsOwnerOrControllerOfUnit = {},
	UnitIsPlayer = {},
	UnitIsPossessed = {},
	UnitIsPVP = {},
	UnitIsPVPFreeForAll = {},
	UnitIsPVPSanctuary = {},
	UnitIsQuestBoss = {},
	UnitIsRaidOfficer = {},
	UnitIsSameServer = {},
	UnitIsTapDenied = {},
	UnitIsTrivial = {},
	UnitIsUnconscious = {},
	UnitIsUnit = {},
	UnitIsVisible = {},
	UnitIsWildBattlePet = {},
	UnitLeadsAnyGroup = {},
	UnitLevel = {},
	UnitName = {},
	UnitNameplateShowsWidgetsOnly = {},
	UnitNameUnmodified = {},
	UnitNumPowerBarTimers = {},
	UnitOnTaxi = {},
	UnitPartialPower = {},
	UnitPercentHealthFromGUID = {},
	UnitPhaseReason = {},
	UnitPlayerControlled = {},
	UnitPlayerOrPetInParty = {},
	UnitPlayerOrPetInRaid = {},
	UnitPosition = {},
	UnitPower = {},
	UnitPowerBarID = {},
	UnitPowerBarTimerInfo = { unknown = true, },
	UnitPowerDisplayMod = { description = "Not a unitToken method", },
	UnitPowerMax = {},
	UnitPowerType = {},
	UnitPvpClassification = { description = "Returns whether the unit is a flag/orb carrier or cart runner.", },
	UnitPVPName = {},
	UnitQuestTrivialLevelRange = {},
	UnitQuestTrivialLevelRangeScaling = {},
	UnitRace = {},
	UnitRangedAttackPower = {},
	UnitRangedDamage = {},
	UnitReaction = {},
	UnitRealmRelationship = {},
	UnitSelectionColor = {},
	UnitSelectionType = {},
	UnitSetRole = {},
	UnitSetRoleEnum = {},
	UnitSex = {},
	UnitShouldDisplayName = {},
	UnitSpellHaste = {},
	UnitStagger = {},
	UnitStat = {},
	UnitSwitchToVehicleSeat = {},
	UnitSwitchToVehicleSeat = { unknown = true, },
	UnitTargetsVehicleInRaidUI = {},
	UnitThreatPercentageOfLead = {},
	UnitThreatSituation = {},
	UnitTokenFromGUID = {},
	UnitTreatAsPlayerForDisplay = {},
	UnitTrialBankedLevels = {},
	UnitTrialXP = {},
	UnitUsingVehicle = {},
	UnitVehicleSeatCount = {},
	UnitVehicleSeatInfo = {},
	UnitVehicleSkin = {},
	UnitWatchRegistered = {},
	UnitWeaponAttackPower = {},
	UnitWidgetSet = { unknown = true, },
	UnitXP = {},
	UnitXPMax = {},
}



local Unit = {}
addonData.Unit = Unit

function Unit:ShowAllMethods()
	local unitToken

	if UnitExists("target") then
		unitToken = "target"
	else
		unitToken = "player"
	end

	local methodData = {}

	for unitMethodName, unitMethodInfo in pairs(unitMethods) do
		local pcallData = { pcall(_G[unitMethodName], unitToken) }

		local unitMethodReturnString = ""

		-- if unitMethodName == "UnitName" then
		-- 	print(#pcallData)
		-- end

		for i, value in ipairs({ unpack(pcallData, 2) }) do
			if i > 1 then
				unitMethodReturnString = unitMethodReturnString .. "  ||||  "
			end

			if not pcallData[1] then
				unitMethodReturnString = unitMethodReturnString .. "|cffff0000"
			end

			unitMethodReturnString = unitMethodReturnString .. tostring(value)
		end

		methodData[unitMethodName] = unitMethodReturnString
	end

	ShowTableEntries(methodData)
end



SLASH_SHOW_UNIT_METHODS1 = "/showunitmethods"
SlashCmdList["SHOW_UNIT_METHODS"] = function()
	Unit:ShowAllMethods()
end
