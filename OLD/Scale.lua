local addonName, addonTable = ...


local DefaultScaleFrame = CreateFrame("Frame")
DefaultScaleFrame:SetAllPoints()


local C_Scale = {}
addonTable.C_Scale = C_Scale

function C_Scale:GetAspectRatio()
	return DefaultScaleFrame:GetHeight()
end
