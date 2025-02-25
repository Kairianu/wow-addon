local addonName, addonTable = ...


local function createScrollChild(parent)
	local scrollChild = CreateFrame("Frame", nil, parent)

	parent:SetScrollChild(scrollChild)

	hooksecurefunc(parent, "SetHeight", function(self)
		self:GetScrollChild():SetHeight(self:GetHeight())
	end)

	hooksecurefunc(parent, "SetSize", function(self)
		self:GetScrollChild():SetSize(self:GetSize())
	end)

	hooksecurefunc(parent, "SetWidth", function(self)
		self:GetScrollChild():SetWidth(self:GetWidth())
	end)

	scrollChild:SetSize(parent:GetSize())

	return scrollChild
end




local ListFrameMetatable = {}

function ListFrameMetatable:GetScrollChild()
end



local List = {}
addonTable.List = List

function List:Create(name, parent)
	local listFrame = CreateFrame("ScrollFrame", name, parent)

	createScrollChild(listFrame)

	return listFrame
end






local l = List:Create()
l:Hide()
l:SetPoint("Center")
l:SetSize(200, 400)
l:SetScript("OnMouseDown", function(self)
	self:Hide()
end)
l.bg = l:CreateTexture()
l.bg:SetAllPoints()
l.bg:SetColorTexture(0, 0, 0, 0.4)
