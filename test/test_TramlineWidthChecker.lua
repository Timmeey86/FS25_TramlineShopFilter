_G.Logging = {
	warning = function (...) end
}

dofile("scripts/TramlineWidthChecker.lua")

describe("Tramline Width Checker", function()
	-- Note: For a 12m tramline, you could use a 4m seeder and do a normal run, a tramline run and a normal run.
	--       You could also use a 3m seeder, but that requires you to have ProSeed's half-side shutoff feature where you do:
	--       - Sow a 1.5m line
	--       - Sow a 3m line
	--       - Sow a 3m line with tramlines
	--       - Sow a 3m line
	--       - Sow a 3m line which counts as the last 1.5m for the first tramline and 1.5m for the next

	-- Tests which don't force an odd multiplier
	it("allows 12m for a 12m tramline", function()
		assert.truthy(TramlineWidthChecker.workWidthIsCompatible(12, 12, 0, false))
	end)
	it("allows 4m for a 12m tramline", function()
		assert.truthy(TramlineWidthChecker.workWidthIsCompatible(4, 12, 0, false))
	end)
	it("does not allow 24m for a 12m tramline", function()
		assert.falsy(TramlineWidthChecker.workWidthIsCompatible(24, 12, 0, false))
	end)
	it("does not crash on stupid values", function()
		assert.has_no.errors(function() TramlineWidthChecker.workWidthIsCompatible("a", -24142151, .1251234125, false) end)
	end)
	it("does not run endlessly on negative values", function()
		assert.has_no.errors(function() TramlineWidthChecker.workWidthIsCompatible(-5, 24, 0, false) end)
	end)
	it("allows 2.4m for a 12m tramline with zero tolerance", function()
		assert.truthy(TramlineWidthChecker.workWidthIsCompatible(2.4, 12, 0, false))
	end)
	it("does not allow 3.4m for a 24m tramline with zero tolerance", function()
		assert.falsy(TramlineWidthChecker.workWidthIsCompatible(3.4, 24, 0, false))
	end)
	it("allows 3.4m for a 24m tramline with a .2 meter tolerance", function()
		assert.truthy(TramlineWidthChecker.workWidthIsCompatible(3.4, 24, 0.2, false))
	end)
	it("always returns false for zero values", function()
		assert.falsy(TramlineWidthChecker.workWidthIsCompatible(0, 0, 0, false))
	end)
	it("allows 18.4m for 18m tramline width and .4 tolerance", function()
		assert.truthy(TramlineWidthChecker.workWidthIsCompatible(18.4, 18, 0.4, false))
	end)

	-- Tests which force an odd multiplier
	it("allows 12m for a 12m tramline when forcing an odd multiplier", function()
		assert.truthy(TramlineWidthChecker.workWidthIsCompatible(12, 12, 0, true))
	end)
	it("allows 4m for a 12m tramline when forcing an odd multiplier", function()
		assert.truthy(TramlineWidthChecker.workWidthIsCompatible(4, 12, 0, true))
	end)
	it("allows 2.4m for a 12m tramline when forcing an odd multiplier", function()
		assert.truthy(TramlineWidthChecker.workWidthIsCompatible(2.4, 12, 0, true))
	end)
	it("does not allow 2.4m for a 24m tramline when forcing an odd multiplier", function()
		assert.falsy(TramlineWidthChecker.workWidthIsCompatible(2.4, 24, 0, true))
	end)
	it("allows 18.4m for 18m tramline width and .4 tolerance", function()
		assert.truthy(TramlineWidthChecker.workWidthIsCompatible(18.4, 18, 0.4, true))
	end)
end)