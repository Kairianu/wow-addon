local addonName, addonTable = ...


local C_Text = {}
addonTable.C_Text = C_Text

function C_Text:UpperSpaced(text)
	text = text:upper():gsub(".", " %1"):gsub("^%s+", "")

	return text
end



SLASH_TEXTCOOL1 = "/text"
SlashCmdList["TEXTCOOL"] = function(argString)
	print(UpperSpaced(argString))
end
