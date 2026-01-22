--------------------------------------------------
-----CVar-----------------------------------------
--------------------------------------------------

-- What does this do?
-- /console emphasizeMySpellEffects 0

C_Timer.After(2, function()
	C_CVar.SetCVar('AutoPushSpellToActionBar', 0)
	C_CVar.SetCVar('cameraDistanceMaxZoomFactor', 2.6)
	C_CVar.SetCVar('scriptErrors', 1)
	C_CVar.SetCVar('secureAbilityToggle', 0)
	C_CVar.SetCVar('worldPreloadNonCritical', 0)
end)





--------------------------------------------------
-----Bank-----------------------------------------
--------------------------------------------------

-- Enum.BankType.Character
-- Enum.BankType.Guild
-- Enum.BankType.Account

-- Enum.BagSlotFlags.DisableAutoSort
-- Enum.BagSlotFlags.ClassEquipment
-- Enum.BagSlotFlags.ClassConsumables
-- Enum.BagSlotFlags.ClassProfessionGoods
-- Enum.BagSlotFlags.ClassJunk
-- Enum.BagSlotFlags.ClassQuestItems
-- Enum.BagSlotFlags.ExcludeJunkSell
-- Enum.BagSlotFlags.ClassReagents
-- Enum.BagSlotFlags.ExpansionCurrent
-- Enum.BagSlotFlags.ExpansionLegacy

-- C_Bank.FetchNumPurchasedBankTabs(Enum.BankType.Character)
-- C_Bank.FetchPurchasedBankTabData(Enum.BankType.Character)
-- C_Bank.FetchPurchasedBankTabIDs(Enum.BankType.Character)

local function updateBankTabSettings()
	local bankType = Enum.BankType.Character

	local bankTabIDs = C_Bank.FetchPurchasedBankTabIDs(bankType)

	for bankTabIndex, bankTabID in ipairs(bankTabIDs) do
		local bankTabName = 'Bank ' .. bankTabIndex
		local bankTabIcon = ''
		local bankTabFlags = 0

		if bankTabIndex == 1 then
			bankTabName = 'Current Reagents'
			bankTabFlags = (
				Enum.BagSlotFlags.ExpansionCurrent
				+ Enum.BagSlotFlags.ClassReagents
				+ Enum.BagSlotFlags.ClassProfessionGoods
			)
		elseif bankTabIndex == 2 then
			bankTabName = 'Legacy Reagents'
			bankTabFlags = (
				Enum.BagSlotFlags.ExpansionLegacy
				+ Enum.BagSlotFlags.ClassReagents
				+ Enum.BagSlotFlags.ClassProfessionGoods
			)
		elseif bankTabIndex == 3 then
			bankTabName = 'Equipment'
			bankTabFlags = Enum.BagSlotFlags.ClassEquipment
		elseif bankTabIndex == 4 then
			bankTabName = 'Consumables'
			bankTabFlags = Enum.BagSlotFlags.ClassConsumables
		end

		C_Bank.UpdateBankTabSettings(bankType, bankTabID, bankTabName, bankTabIcon, bankTabFlags)
	end
end

local BankEventFrame = CreateFrame('frame')

BankEventFrame:RegisterEvent('BANKFRAME_OPENED')
BankEventFrame:SetScript('onEvent', function(self, event)
	if event == 'BANKFRAME_OPENED' then
		updateBankTabSettings()

		self:UnregisterEvent('BANKFRAME_OPENED')
	end
end)
