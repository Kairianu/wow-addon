local addonName, addonData = ...


-- local name, texture, count, qualityID, usable, level, levelType, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, bidderFullName, owner, ownerFullName, saleStatus, itemID, hasAllInfo = C_AuctionHouse.GetReplicateItemInfo(replicateItemIndex)


addonData.CollectionsAPI:CreateCollection("auction")
