local addonName, addonData = ...


local DUMMY_DATA = {}



local IMPORTS = {
	character = {
		api = true,
	},

	table = {
		api = true,
	},

	value = {
		api = true,
	},
}


addonData.CollectionsAPI:GetCollection("character"):AddMixin("persistentData", IMPORTS, function()
	local CharacterPersistentData = {}

	function CharacterPersistentData:GetData()
		return DUMMY_DATA
	end

	function CharacterPersistentData:GetCharacterData(characterGUID)
		characterGUID = IMPORTS.character.api:ValidateCharacterGUID(characterGUID)

		return self:GetData()[characterGUID]
	end

	function CharacterPersistentData:UpdatePlayerData()
		local playerGUID = UnitGUID("player")

		local playerData = self:GetCharacterData(playerGUID)

		if not playerData then
			playerData = {}

			self:GetData()[playerGUID] = playerData
		end

		playerData.className = select(2, UnitClass("player"))
		playerData.id = playerID
		playerData.name = UnitName("player")
		playerData.realm = GetRealmName()

		self:UpdatePlayerSpecializationData()
	end

	function CharacterPersistentData:UpdatePlayerSpecializationData()
		local playerData = self:GetCharacterData()

		if not playerData then
			self:UpdatePlayerData()

			return
		end

		-- local specializationData = IMPORTS.table.api:GetOrCreate(playerData, "specialization", IMPORTS.value.api:GetCreateTableMethod())
		local specializationData = playerData.specialization

		if not specializationData then
			specializationData = {}
		end

		local classID = select(3, UnitClass("player"))
		local specializationIndex = 1

		while true do
			local specializationID = GetSpecializationInfoForClassID(classID, specializationIndex)

			if not specializationID then
				break
			end

			if type(specializationData[specializationID]) ~= "table" then
				specializationData[specializationID] = {}
			end

			specializationIndex = specializationIndex + 1
		end
	end



	return CharacterPersistentData
end)
