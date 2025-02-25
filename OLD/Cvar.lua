SLASH_PRINT_CVAR1 = "/consolevariableprint"
SlashCmdList["PRINT_CVAR"] = function(cvarKey)
	DEFAULT_CHAT_FRAME:AddMessage(tostring(C_CVar.GetCVar(cvarKey)))
end


C_CVar.SetCVar("AutoPushSpellToActionBar", 0)


-- /console emphasizeMySpellEffects 0
