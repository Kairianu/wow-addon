local addonName, addonTable = ...

local PersistentData = addonTable.PersistentData


local persistentDataAccessKey

local function GetPersistentData()
	if not persistentDataAccessKey then
		persistentDataAccessKey = PersistentData:CreateAccessKey("worldpvp")
	end

	return PersistentData:GetAccessKeyData(persistentDataAccessKey)
end


local WorldPvPSavedVariables = CreateFrame("Frame")
addonTable.WorldPvPSavedVariables = WorldPvPSavedVariables

local function GetCharacterData(characterGUID)
	if not characterGUID then
		characterGUID = UnitGUID("player")
	end

	local persistentData = GetPersistentData()

	local characterData = persistentData[characterGUID]

	if not characterData then
		characterData = {}

		persistentData[characterGUID] = characterData
	end

	return characterData
end

function WorldPvPSavedVariables:GetWarSupplyChestLootTimeForPlayer()
	return GetCharacterData().warSupplyChestLootTime
end

function WorldPvPSavedVariables:UpdateWarSupplyChestLootTimeForPlayer()
	GetCharacterData().warSupplyChestLootTime = time()
end

function WorldPvPSavedVariables:GetAssassinBountyLootTimeForPlayer()
	return GetCharacterData().assassinBountyLootTime
end

function WorldPvPSavedVariables:UpdateAssassinBountyLootTimeForPlayer()
	GetCharacterData().assassinBountyLootTime = time()
end
