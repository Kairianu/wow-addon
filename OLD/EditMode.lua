local addonName, addonTable = ...


local EditMode = {}
addonTable.EditMode = EditMode

function EditMode:GetCurrentLayoutName()
	local presetLayoutCount = addonTable.C_Table:GetItemCount(Enum.EditModePresetLayouts)

	local layoutsData = C_EditMode.GetLayouts()

	local activeLayoutIndex = layoutsData.activeLayout - presetLayoutCount

	if activeLayoutIndex < 1 then
		for presetLayoutName, presetLayoutIndex in pairs(Enum.EditModePresetLayouts) do
			if layoutsData.activeLayout == presetLayoutIndex + 1 then
				return presetLayoutName .. " (Preset)"
			end
		end
	else
		local layoutData = layoutsData.layouts[activeLayoutIndex]

		if layoutData then
			return layoutData.layoutName
		end
	end
end
