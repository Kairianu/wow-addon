local addonName, addonTable = ...

local Number = {}
addonTable.Number = Number

function Number:Convert(value, fallbackToValue)
	local numberValue = tonumber(value)

	if fallbackToValue then
		if not numberValue then
			return value
		end
	end

	return numberValue
end
