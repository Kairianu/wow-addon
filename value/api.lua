local addonName, addonData = ...


local function CreateTable()
	return {}
end



local creationMethods = {
	CreateTable,
}



addonData.CollectionsAPI:GetCollection("value"):AddMixin("api", function()
	local ValueAPI = {}

	function ValueAPI:GetCreateTableMethod()
		return CreateTable
	end

	function ValueAPI:IsCreationMethod(value)
		for _, creationMethod in ipairs(creationMethods) do
			if value == creationMethod then
				return true
			end
		end

		return false
	end


	return ValueAPI
end)
