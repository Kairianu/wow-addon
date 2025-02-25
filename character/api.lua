local addonName, addonData = ...


local IMPORTS = {
	character = {
		persistentData = true,
	},
}


addonData.CollectionsAPI:GetCollection("character"):AddMixin("api", IMPORTS, function()
	local CharacterAPI = {}

	function CharacterAPI:GetCharacterColor(characterGUID)
		local className = self:GetClassName(characterGUID)

		if className then
			return C_ClassColor.GetClassColor(className)
		end
	end

	function CharacterAPI:GetClassName(characterGUID)
		local characterData = IMPORTS.character.persistentData:GetCharacterData(characterGUID)

		if characterData then
			return characterData.className
		end
	end

	function CharacterAPI:GetCharacterName(characterGUID)
		local characterData = IMPORTS.character.persistentData:GetCharacterData(characterGUID)

		if not characterData then
			return
		end

		local characterName = characterData.name
		local characterNameFull
		local characterRealm = characterData.realm

		if characterName and characterRealm then
			characterNameFull = characterName .. "-" .. characterRealm
		end

		return characterName, characterRealm, characterNameFull
	end

	function CharacterAPI:GetCharacterRealmName(characterGUID)
		local characterData = IMPORTS.character.persistentData:GetCharacterData(characterGUID)

		if characterData then
			return characterData.realm
		end
	end

	function CharacterAPI:GetCharacterSpecializationData(characterGUID)
		local characterData = IMPORTS.character.persistentData:GetCharacterData(characterGUID)

		if characterData then
			return characterData.specialization
		end
	end

	function CharacterAPI:ValidateCharacterGUID(characterGUID)
		if not characterGUID then
			characterGUID = UnitGUID("player")
		end

		return characterGUID
	end



	return CharacterAPI
end)
