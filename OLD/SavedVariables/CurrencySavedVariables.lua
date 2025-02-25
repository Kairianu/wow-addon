local addonName, addonTable = ...

local PersistentData = addonTable.PersistentData


local persistentDataAccessKey

local function GetPersistentData()
	if not persistentDataAccessKey then
		persistentDataAccessKey = PersistentData:CreateAccessKey("currency")
	end

	return PersistentData:GetAccessKeyData(persistentDataAccessKey)
end


local CurrencySavedVariables = CreateFrame("Frame")
addonTable.CurrencySavedVariables = CurrencySavedVariables

function CurrencySavedVariables:GetCharacterCurrencyQuantity(currencyName, characterGUID)
	local currencyData = GetPersistentData()[currencyName]

	if currencyData then
		return currencyData[characterGUID]
	end
end

function CurrencySavedVariables:SetCharacterCurrencyQuantity(currencyName, characterGUID, quantity)
	local persistentData = GetPersistentData()

	local currencyData = persistentData[currencyName]

	if not currencyData then
		currencyData = {}

		persistentData[currencyName] = currencyData
	end

	currencyData[characterGUID] = quantity
end

function CurrencySavedVariables:GetCharacterOrder(currencyName)
	local persistentData = GetPersistentData()

	local currencyData = persistentData[currencyName]

	if not currencyData then
		return
	end

	local characterOrder = {}

	for characterGUID, _ in pairs(currencyData) do
		local characterRealm = select(2, addonTable.Character:GetCharacterName(characterGUID))

		local realmTable = characterOrder[characterRealm]

		if not realmTable then
			table.insert(characterOrder, characterRealm)

			realmTable = {}

			characterOrder[characterRealm] = realmTable
		end

		table.insert(realmTable, characterGUID)
	end

	table.sort(characterOrder)

	for _, realmName in ipairs(characterOrder) do
		table.sort(characterOrder[realmName])
	end

	return characterOrder
end
