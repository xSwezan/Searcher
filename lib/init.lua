local Types = require(script.Types)
local FilterClass = require(script.Filter)

local Searcher: Types.Searcher = {}

function Searcher.NewFilter(): Types.Filter
	local Filter: Types.Filter = FilterClass.new()

	return Filter
end

function Searcher.FindOne(Filter: Types.Filter, Instances: {Instance}): Instance?
	return Filter:__Search(Instances)
end

function Searcher.FindAll(Filter: Types.Filter, Instances: {Instance}): {Instance}
	return Filter:__Search(Instances, true)
end

function Searcher.InstanceMatches(Filter: Types.Filter, Instance: Instance): boolean
	return (Filter:__Search({Instance}) == Instance)
end

function Searcher.InstanceAdded(Filter: Types.Filter, Ancestor: Instance?): RBXScriptSignal
	Ancestor = Ancestor or game

	local Event: BindableEvent = Instance.new("BindableEvent")

	Ancestor.DescendantAdded:Connect(function(Descendant: Instance)
		if (Filter:__Search({Descendant}) == nil) then return end

		Event:Fire(Descendant)
	end)

	return Event.Event
end

return Searcher