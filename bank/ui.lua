local addonName, addonData = ...


local function createMoneyButton()
	local MoneyButton = CreateFrame('button', nil, StaticPopup1, 'UIPanelButtonTemplate')

	hooksecurefunc(MoneyButton, 'SetText', function(self)
		self:FitToText()

		self:SetWidth(self:GetWidth() - 15)
	end)

	function MoneyButton:GetSeparatedMoney(money)
		local copper = money % 100
		local gold = math.floor(money / 100 / 100)
		local silver = math.floor(money / 100 % 100)

		return gold, silver, copper
	end

	function MoneyButton:SetWithdraw()
		self.transferType = 'withdraw'
	end

	function MoneyButton:SetDeposit()
		self.transferType = 'deposit'
	end

	function MoneyButton:SetMoneyEditBox(gold, silver, copper)
		StaticPopup1MoneyInputFrameCopper:SetText(copper)
		StaticPopup1MoneyInputFrameGold:SetText(gold)
		StaticPopup1MoneyInputFrameSilver:SetText(silver)
	end


	MoneyButton:SetScript('onHide', function(self)
		self:Hide()
	end)


	MoneyButton:Hide()


	return MoneyButton
end



local SelectAllMoneyButton = createMoneyButton()

SelectAllMoneyButton:SetPoint('right', StaticPopup1MoneyInputFrameGold, 'left', -15, 0)
SelectAllMoneyButton:SetText('A')

SelectAllMoneyButton:SetScript('onClick', function(self)
	local money

	if self.transferType == 'withdraw' then
		money = C_Bank.FetchDepositedMoney(Enum.BankType.Account)
	else
		money = GetMoney()
	end

	self:SetMoneyEditBox(self:GetSeparatedMoney(money))
end)


local Select5KMoneyButton = createMoneyButton()

Select5KMoneyButton:SetPoint('left', StaticPopup1MoneyInputFrameCopper, 'right', 0, 0)
Select5KMoneyButton:SetText('5k')

Select5KMoneyButton:SetScript('onClick', function(self)
	local moneyLimit = 50000000

	local accountMoney = C_Bank.FetchDepositedMoney(Enum.BankType.Account)
	local playerMoney = GetMoney()

	local accountGold, accountSilver, accountCopper = self:GetSeparatedMoney(accountMoney)
	local playerGold, playerSilver, playerCopper = self:GetSeparatedMoney(playerMoney)

	local moneyToTransfer

	if self.transferType == 'withdraw' then
		if playerMoney >= moneyLimit then
			moneyToTransfer = 0
		else
			moneyToTransfer = moneyLimit - playerMoney
		end
	else
		if playerMoney <= moneyLimit then
			moneyToTransfer = 0
		else
			moneyToTransfer = playerMoney - moneyLimit
		end
	end

	self:SetMoneyEditBox(self:GetSeparatedMoney(moneyToTransfer))
end)


local MoneyButtonsMixin = {
	moneyButtons = {
		Select5KMoneyButton,
		SelectAllMoneyButton,
	},
}

function MoneyButtonsMixin:Show(transferType)
	for _, MoneyButton in ipairs(self.moneyButtons) do
		if transferType == 'withdraw' then
			MoneyButton:SetWithdraw()
		else
			MoneyButton:SetDeposit()
		end

		MoneyButton:Show()
	end
end



BankPanel.MoneyFrame.DepositButton:HookScript('onClick', function()
	MoneyButtonsMixin:Show()
end)

BankPanel.MoneyFrame.WithdrawButton:HookScript('onClick', function()
	MoneyButtonsMixin:Show('withdraw')
end)




-- addonData.CollectionsAPI:GetCollection('bank'):AddMixin('ui', function()end)
