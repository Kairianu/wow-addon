local addonName, addonData = ...


-- What does this do?
-- /console emphasizeMySpellEffects 0

C_Timer.After(2, function()
	C_CVar.SetCVar("AutoPushSpellToActionBar", 0)
	C_CVar.SetCVar("secureAbilityToggle", 0)
end)



addonData.CollectionsAPI:CreateCollection('cvar')
