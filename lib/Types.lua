local Types = {}

export type FilterCallback = (Object: Instance) -> boolean?

export type Filter = {
	-- Specials
	Not: (self: Filter) -> Filter;

	-- Callbacks
	IsA: (self: Filter, ClassName: string) -> Filter;
	Is: (self: Filter, Instance: Instance) -> Filter;

	Named: (self: Filter, Name: string) -> Filter;
	Property: (self: Filter, PropertyName: string, Value: any) -> Filter;
	Attribute: (self: Filter, AttributeName: string, Value: any) -> Filter;
	Tagged: (self: Filter, TagName: string) -> Filter;

	ChildOf: (self: Filter, Parent: Instance?) -> Filter;
	DescendantOf: (self: Filter, Ancestor: Instance?) -> Filter;

	HasChild: (self: Filter, Name: string, Recursive: boolean?) -> Filter;
	HasChildWhichIsA: (self: Filter, ClassName: string, Recursive: boolean?) -> Filter;

	Custom: (self: Filter, Callback: FilterCallback) -> Filter;
}

export type Searcher = {
	NewFilter: () -> Filter;

	FindOne: (Filter: Filter, Instances: {Instance}) -> Instance?;
	FindAll: (Filter: Filter, Instances: {Instance}) -> {Instance};

	InstanceMatches: (Filter: Filter, Instance: Instance) -> boolean;
	
	-- Events
	InstanceAdded: (Filter: Filter, Ancestor: Instance?) -> RBXScriptSignal;
}

return Types