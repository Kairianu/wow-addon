local addonName, addonTable = ...


local fontFamilies = {
	"Fonts/FRIZQT__.TTF",
}


local Font = {}
addonTable.Font = Font

function Font:GetDefaultFont()
	return self:GetDefaultFontFamily(), self:GetDefaultFontSize()
end

function Font:GetDefaultFontFamily()
	return "Fonts/blei00d.ttf"
end

function Font:GetDefaultFontSize()
	return 15
end

function Font:GetFontSize(modifier)
	local defaultFontSize = self:GetDefaultFontSize()

	if type(modifier) ~= "number" then
		return defaultFontSize
	end

	return defaultFontSize * modifier
end
