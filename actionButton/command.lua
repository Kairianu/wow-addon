local addonName, addonData = ...


local imports = {
	actionButton = {
		ui = true,
	},

	command = {
		api = {
			preLoad = true,
		},
	},
}

addonData.CollectionsAPI:GetCollection('actionButton'):AddMixin('command', imports, function()
	imports.command.api:AddCommand('EDIT_ACTION_BUTTONS', function()end)

	imports.command.api:AddCommand('TOGGLE_ACTION_BUTTONS', function()
		local ActionButtonTest = imports.actionButton.ui.ActionButtonTest

		if ActionButtonTest:IsShown() then
			ActionButtonTest:Hide()
		else
			ActionButtonTest:Show()
		end
	end)
end)
