local addonName, addonData = ...

local PoolMetatable = {}

function PoolMetatable:Acquire()
	local member = table.remove(self.members.available)

	if not member then
		if type(self.onCreate) == "function" then
			member = self.onCreate(self)
		else
			member = self.onCreate
		end
	end

	table.insert(self.members.used, member)

	if type(self.onAcquire) == "function" then
		self.onAcquire(member)
	end

	return member
end

function PoolMetatable:GetName()
	return self.name
end

function PoolMetatable:Initialize()
	self.members = {
		available = {},
		used = {},
	}
end

function PoolMetatable:Release(member)
	for usedMemberIndex, usedMember in ipairs(self.members.used) do
		if member == usedMember then
			local removedMember = table.remove(self.members.used, usedMemberIndex)

			if type(self.onRelease) == "function" then
				self.onRelease(removedMember)
			end

			table.insert(self.members.available, removedMember)

			return true
		end
	end

	return false
end



local Pool = {}
addonData.Pool = Pool

function Pool:Create(options)
	if type(options) ~= "table" then
		return
	end

	local pool = {
		data = options.data,
		name = options.name,
		onAcquire = options.onAcquire,
		onCreate = options.onCreate,
		onRelease = options.onRelease,
	}

	addonData.Metatable:AddObjectMetatable(pool, PoolMetatable)

	pool:Initialize()

	return pool
end
