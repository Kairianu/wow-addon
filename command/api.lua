local addonName, addonData = ...


local function getAddonSlashName(slashName)
	return (addonName .. '_' .. slashName):lower()
end

local function getAddonCommandName(commandName)
	return (addonName .. '_' .. commandName):upper()
end

local function registerSlashCommand(globalCommandName, slashName, slashIndex)
	local globalSlashName = globalCommandName .. slashIndex
	local slashCommand = '/' .. getAddonSlashName(slashName)

	_G[globalSlashName] = slashCommand
end


addonData.CollectionsAPI:GetCollection('command'):AddMixin('api', function()
	local CommandAPI = {}

	function CommandAPI:AddCommand(commandName, slashNames, handler)
		if handler == nil then
			if type(slashNames) == 'function' then
				handler = slashNames
				slashNames = nil
			end
		end

		local addonCommandName = getAddonCommandName(commandName)

		SlashCmdList[addonCommandName] = handler

		local globalCommandName = self:GetGlobalCommandName(commandName)
		local slashIndex = self:GetNextCommandSlashIndex(commandName)

		if type(slashNames) == 'table' then
			for _, slashName in ipairs(slashNames) do
				registerSlashCommand(globalCommandName, slashName, slashIndex)

				slashIndex = slashIndex + 1
			end
		else
			local slashName

			if slashNames == nil then
				slashName = commandName:gsub('_', '-')
			else
				slashName = slashNames
			end

			registerSlashCommand(globalCommandName, slashName, slashIndex)
		end
	end

	function CommandAPI:GetNextCommandSlashIndex(commandName)
		local globalCommandName = self:GetGlobalCommandName(commandName)
		local slashIndex = 1

		while _G[globalCommandName .. slashIndex] do
			slashIndex = slashIndex + 1
		end

		return slashIndex
	end

	function CommandAPI:GetGlobalCommandName(commandName)
		return 'SLASH_' .. getAddonCommandName(commandName)
	end


	return CommandAPI
end)
