local addonName, addonTable = ...


local Math = {}
addonTable.Math = Math

function Math:GetEulersConstant()
	return math.exp(1)
end

function Math:Random(min, max)
	return math.random() * (max - min) + min
end

function Math:Round(value)
	return math.floor(value + 0.5)
end

function Math:LimitRange(value, min, max)
	if value then
		if min and value < min then
			return min
		end

		if max and value > max then
			return max
		end
	end

	return value
end
