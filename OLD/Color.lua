local addonName, addonTable = ...

local COLORS = {}


local Color = {}
addonTable.Color = Color



local COLOR_METATABLE = {}

function COLOR_METATABLE:GetRGB()
	return self.red, self.green, self.blue
end

function COLOR_METATABLE:GetRGBA()
	return self.red, self.green, self.blue, self.alpha
end

function COLOR_METATABLE:WrapTextInColor(text)
	text = tostring(text)

	local alphaHex = Color:DecimalToHex(self.alpha)
	local blueHex = Color:DecimalToHex(self.blue)
	local greenHex = Color:DecimalToHex(self.green)
	local redHex = Color:DecimalToHex(self.red)

	return "|c" .. alphaHex .. redHex .. greenHex .. blueHex .. text .. "|r"
end




function Color:GetColor(name)
	return COLORS[name]
end

function Color:CreateColor(name, ...)
	local args = {...}

	local alpha
	local blue
	local green
	local red

	if type(args[1]) == "string" then
		alpha, red, green, blue = self:HexToDecimal(args[1])
	elseif #args <= 2 then
		red = args[1]
		green = args[1]
		blue = args[1]

		if #args == 2 then
			alpha = args[2]
		end
	else
		red, green, blue, alpha = unpack(args)
	end

	if not alpha then
		alpha = 1
	end

	local colorData = {
		alpha = alpha or 1,
		blue = blue,
		green = green,
		name = name,
		red = red,
	}

	setmetatable(colorData, {
		__index = COLOR_METATABLE,
	})

	if name then
		COLORS[name] = colorData
	end

	return colorData
end

function Color:DecimalToHex(value)
	local hex = string.format("%x", value * 255)

	if string.len(hex) < 2 then
		hex = "0" .. hex
	end

	return hex
end

function Color:HexToDecimal(value)
	local valueLength = string.len(value)
	local values = {}

	if valueLength == 1 then
		table.insert(values, value)
		table.insert(values, value)
		table.insert(values, value)
	elseif valueLength == 2 then
		table.insert(values, value)
	elseif valueLength == 3 or valueLength == 4 then
		table.insert(values, string.sub(value, 1, 1):rep(2))
		table.insert(values, string.sub(value, 2, 2):rep(2))
		table.insert(values, string.sub(value, 3, 3):rep(2))

		if valueLength == 4 then
			table.insert(values, string.sub(value, 4, 4):rep(2))
		end
	elseif valueLength == 5 or valueLength == 7 then
		table.insert(values, "0" .. string.sub(value, 1, 1))
		table.insert(values, string.sub(value, 2, 3))
		table.insert(values, string.sub(value, 4, 5))

		if valueLength == 7 then
			table.insert(values, string.sub(value, 6, 7))
		end
	elseif valueLength == 6 or valueLength == 8 then
		table.insert(values, string.sub(value, 1, 2))
		table.insert(values, string.sub(value, 3, 4))
		table.insert(values, string.sub(value, 5, 6))

		if valueLength == 8 then
			table.insert(values, string.sub(value, 7, 8))
		end
	end

	for i, value in ipairs(values) do
		values[i] = tonumber("0x" .. value) / 255
	end

	return unpack(values)
end

function Color:WrapTextInColor(colorName, text)
	local colorData = self:GetColor(colorName)

	if colorData then
		return colorData:WrapTextInColor(text)
	end

	return text
end


Color:CreateColor("blue", 0, 0.6, 1)
Color:CreateColor("bluelight", 0, 0.8, 1)
Color:CreateColor("green", 0.2, 1, 0.2)
Color:CreateColor("gray", 0.7)
Color:CreateColor("orange", 1, 0.35, 0)
Color:CreateColor("red", 1, 0, 0)
Color:CreateColor("white", 0.9)
Color:CreateColor("yellow", 1, 0.82, 0)

-- for colorName, colorData in pairs(COLORS) do
-- 	print(
-- 		Color:WrapTextInColor(
-- 			colorName,
-- 			string.format("%s - %s %s %s %s", colorName, colorData:GetRGBA())
-- 		)
-- 	)
-- end
