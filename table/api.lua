local addonName, addonData = ...


local IMPORTS = {
	value = {
		api = true,
	},
}



addonData.CollectionsAPI:GetCollection("table"):AddMixin("api", IMPORTS, function()
	local TableAPI = {}

	function TableAPI:GetItemCount(data)
		local totalCount = 0

		for _, _ in pairs(data) do
			totalCount = totalCount + 1
		end

		local ipairsCount = #data

		local pairsCount = totalCount - ipairsCount

		return totalCount, ipairsCount, pairsCount
	end

	function TableAPI:GetKey(value, ...)
		local keys = {...}

		for keyIndex = 1, #keys do
			if type(value) ~= "table" then
				return
			end

			value = value[keys[keyIndex]]
		end

		return value
	end

	function TableAPI:GetOrCreate(object, key, valueDefault)
		if object[key] == nil then
			if IMPORTS.value.api:IsCreationMethod(valueDefault) then
				object[key] = valueDefault()
			else
				object[key] = valueDefault
			end
		end

		return object[key]
	end

	function TableAPI:GetRandomItem(...)
		local tables = {...}
		local totalSize = 0

		for _, table in ipairs(tables) do
			totalSize = totalSize + #table
		end

		local randomIndex = math.floor(math.random() * totalSize + 1)

		for _, table in ipairs(tables) do
			if randomIndex <= #table then
				return table[randomIndex]
			end

			randomIndex = randomIndex - #table
		end
	end

	function TableAPI:Includes(object, item)
		for _, value in pairs(object) do
			if value == item then
				return true
			end
		end

		return false
	end

	-- TODO
	function TableAPI:Match(object1, object2, ignoreSize)
		local object1Length = 0

		for key, value in pairs(object1) do
			object1Length = object1Length + 1

			if object2[key] ~= value then
				return false
			end
		end

		if not ignoreSize then
			local object2Length = 0

			for _, _ in pairs(object2) do
				object2Length = object2Length + 1
			end

			if object1Length ~= object2Length then
				return false
			end
		end

		return true
	end

	function TableAPI:MergeInsert(...)
		local mergedTable = {}

		for _, objectData in ipairs({...}) do
			for _, value in ipairs(objectData) do
				table.insert(mergedTable, value)
			end
		end

		return mergedTable
	end

	-- TODO
	function TableAPI:RemoveValue(object, value)
		for key, keyValue in pairs(object) do
			if keyValue == value then
				if type(key) == "number" then
					table.remove(object, key)
				else
					object[key] = nil
				end

				return true
			end
		end

		return false
	end


	return TableAPI
end)
