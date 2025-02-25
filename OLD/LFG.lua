local addonName, addonTable = ...


local CATEGORY_IDS = {
	dungeon = LE_LFG_CATEGORY_LFD,
}



local C_LFG = {}
addonTable.C_LFG = C_LFG

function C_LFG:JoinDungeon(...)
	local dungeonIDs = {...}

	local categoryID = CATEGORY_IDS.dungeon

	ClearAllLFGDungeons(categoryID)

	for i, dungeonID in ipairs(dungeonIDs) do
		SetLFGDungeon(categoryID, dungeonID)
	end

	JoinLFG(categoryID)
end
