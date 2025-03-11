_G["Utils"] = {
	appendedFunction = function(x, y) end
}
_G["StoreItemUtil"] = {
	loadSpecsFromXML = function(x) end
}
dofile("scripts/WorkWidthRetriever.lua")

-- Define some fake test data
local workWidth1 = 42
local workWidth2 = 5
local workWidth3 = 12
local workWidth4 = 16

local tractorSpecs = {}
local fixedSpreaderSpecs = {
	workingWidth = workWidth1
}
local dynamicSprayerSpecs = {
	workingWidthConfig = {
		folding = { -- just an example, this could be other things like "variableWidth", too
			workWidth2, workWidth3, workWidth4
		}
	}
}
local vehicleTypeSwitchSpecs = {
	workingWidthConfig = {
		vehicleType = { -- another example, could be anything
			workWidth2, workWidth3
		}
	}
}

describe("Work Width Retriever", function()
	it("returns empty work width list for tractors", function()
		assert.are.same(WorkWidthRetriever.getWorkWidthsFromSpecs(tractorSpecs), {})
	end)
	it("returns single entry for fixed spreaders", function()
		assert.are.same(WorkWidthRetriever.getWorkWidthsFromSpecs(fixedSpreaderSpecs), {workWidth1})
	end)
	it("returns expected entries for dynamic sprayers", function()
		assert.are.same(WorkWidthRetriever.getWorkWidthsFromSpecs(dynamicSprayerSpecs), {workWidth2, workWidth3, workWidth4})
	end)
	it("returns expected entries for vehicle type switch specs", function()
		assert.are.same(WorkWidthRetriever.getWorkWidthsFromSpecs(vehicleTypeSwitchSpecs), {workWidth2, workWidth3})
	end)
end)
