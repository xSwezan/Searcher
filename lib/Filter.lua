local CollectionService = game:GetService("CollectionService")
local Types = require(script.Parent.Types)

local Filter: Types.Filter = {}
Filter.__index = Filter

function Filter.new()
	local self = setmetatable({}, Filter)

	self.Callbacks = {}
	self.InvertedCallbacks = {}

	return self
end

function Filter:__Search(Instances: {Instance}, FindAll: boolean?): Instance | {Instance}
	local Objects: {Instance} = {}

	for _, Object: Instance in Instances do
		local MatchesAll = true

		for Index: number, Callback: Types.FilterCallback in ipairs(self.Callbacks) do
			local CanContinue: boolean = Callback(Object)
			if (if (self:__IsInverted(Index)) then not CanContinue else CanContinue) then continue end

			MatchesAll = false
			break
		end

		if not (MatchesAll) then continue end

		table.insert(Objects, Object)

		if not (FindAll) then break end
	end

	return if (FindAll) then Objects else Objects[1]
end

-- Private Methods

function Filter:__NewCallback(Callback: Types.FilterCallback): Types.Filter
	table.insert(self.Callbacks, Callback)

	return self
end

function Filter:__IsInverted(Index: number): boolean
	return (self.InvertedCallbacks[Index] == true)
end

function Filter:__NewEvent(Name: string, Bind: () -> nil)
	assert(type(Name) == "string")

	local Event: BindableEvent = self:__GetEvent(Name) or Instance.new("BindableEvent")
	Event.Name = Name
	Event.Event:Connect(Bind)

	self.Events[Name] = Event
end

function Filter:__GetEvent(Name: string): BindableEvent?
	assert(type(Name) == "string")

	return self.Events[Name]
end

function Filter:__FireEvent(Name: string, ...)
	assert(type(Name) == "string")

	local Event: BindableEvent = self:__GetEvent(Name)
	Event:Fire(...)
end

-- Special Callbacks

function Filter:Not(): Types.Filter
	self.InvertedCallbacks[#self.Callbacks + 1] = true

	return self
end

-- Callbacks

function Filter:IsA(ClassName: string): Types.Filter
	assert(type(ClassName) == "string")

	return self:__NewCallback(function(Object: Instance)
		return Object:IsA(ClassName)
	end)
end

function Filter:Is(Instance: Instance): Types.Filter
	return self:__NewCallback(function(Object: Instance)
		return (Object == Instance)
	end)
end

function Filter:Named(Name: string): Types.Filter
	assert(type(Name) == "string")

	return self:__NewCallback(function(Object: Instance)
		return (Object.Name == Name)
	end)
end

function Filter:NameContains(Pattern: string): Types.Filter
	assert(type(Pattern) == "string")

	return self:__NewCallback(function(Object: Instance)
		return string.find(Object.Name, Pattern)
	end)
end

function Filter:Property(PropertyName: string, Value: any): Types.Filter
	assert(type(PropertyName) == "string")

	return self:__NewCallback(function(Object: Instance)
		return (Object[PropertyName] == Value)
	end)
end

function Filter:Attribute(AttributeName: string, Value: any): Types.Filter
	assert(type(AttributeName) == "string")

	return self:__NewCallback(function(Object: Instance)
		return (Object:GetAttribute(AttributeName) == Value)
	end)
end

function Filter:Tagged(TagName: string): Types.Filter
	assert(type(TagName) == "string")

	return self:__NewCallback(function(Object: Instance)
		return CollectionService:HasTag(Object, TagName)
	end)
end

function Filter:ChildOf(Parent: Instance?): Types.Filter
	return self:__NewCallback(function(Object: Instance)
		return (Object.Parent == Parent)
	end)
end

function Filter:DescendantOf(Ancestor: Instance?): Types.Filter
	return self:__NewCallback(function(Object: Instance)
		return Object:IsDescendantOf(Ancestor)
	end)
end

function Filter:HasChild(Name: string, Recursive: boolean?): Types.Filter
	assert(type(Name) == "string")

	return self:__NewCallback(function(Object: Instance)
		return (Object:FindFirstChild(Name, Recursive) ~= nil)
	end)
end

function Filter:HasChildWhichIsA(ClassName: string, Recursive: boolean?): Types.Filter
	assert(type(ClassName) == "string")

	return self:__NewCallback(function(Object: Instance)
		return (Object:FindFirstChildWhichIsA(ClassName, Recursive) ~= nil)
	end)
end

function Filter:Custom(Callback: Types.FilterCallback): Types.Filter
	assert(type(Callback) == "function")

	return self:__NewCallback(Callback)
end

return Filter