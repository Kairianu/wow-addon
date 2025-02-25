local addonName, addonTable = ...


local function getMetatablesKey(self, key)
	local metatables = getmetatable(self).metatables

	for _, metatable in ipairs(metatables) do
		local metatableKeyValue = metatable[key]

		if metatableKeyValue ~= nil then
			return metatableKeyValue
		end
	end

	return rawget(self, key)
end



local Metatable = {}
addonTable.Metatable = Metatable

function Metatable:GetObjectMetatablesKey()
	return "metatables"
end

function Metatable:GetObjectMetatables(object)
	local objectMetatable = getmetatable(object)

	if objectMetatable then
		local objectMetatablesKey = self:GetObjectMetatablesKey()

		return objectMetatable[objectMetatablesKey]
	end
end

function Metatable:ValidateObjectMetatable(object)
	if object ~= nil then
		local objectMetatable = getmetatable(object)
		local objectMetatableIndex

		if objectMetatable then
			objectMetatableIndex = objectMetatable.__index
		end

		if objectMetatableIndex ~= getMetatablesKey then
			local objectMetatables = {}
			local objectMetatablesKey = self:GetObjectMetatablesKey()

			if objectMetatableIndex ~= nil then
				table.insert(objectMetatables, objectMetatableIndex)
			end

			setmetatable(object, {
				__index = getMetatablesKey,
				[objectMetatablesKey] = objectMetatables,
			})
		end
	end

	return object
end

function Metatable:AddObjectMetatable(object, metatable)
	self:ValidateObjectMetatable(object)

	local objectMetatables = self:GetObjectMetatables(object)

	if objectMetatables then
		table.insert(objectMetatables, 1, metatable)
	end

	return object
end
