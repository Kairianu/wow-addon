local addonName, addonData = ...


local imports = {
	command = {
		api = {
			preLoad = true,
		},
	},

	metrics = {
		ui = true,
	},
}

addonData.CollectionsAPI:GetCollection('metrics'):AddMixin('command', imports, function()
	imports.command.api:AddCommand('METRICS', function()
		imports.metrics.ui:ToggleDisplay()
	end)
end)
