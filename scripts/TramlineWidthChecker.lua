---This class is responsible for figuring out whether or not a certain work width is compatible with a tramline width
---@class TramlineWidthChecker
---@field EPSILON number @The maximum floating point imprecision we tolerate
TramlineWidthChecker = {
	EPSILON = 0.001
}

---Checks whether or not a number is between two other numbers, respecting floating point imprecision
---@param value number @The value
---@param lowerBound number @The lower bound
---@param upperBound number @The upper bound
---@return boolean @True if value is within [lowerBound, upperBound]
local function between(value, lowerBound, upperBound)
	return value >= lowerBound - TramlineWidthChecker.EPSILON and value <= upperBound + TramlineWidthChecker.EPSILON
end

---Checks whether or not a factor is an odd factor of a number, respecting floating point imprecision
---@param factor number @The potential factor of the number (should be smaller than the number)
---@param number number @The number
---@return boolean @True the first argument is an odd factor of the second argument
local function isOddFactor(factor, number)
	return math.abs((factor / number) % 2 - 1) < TramlineWidthChecker.EPSILON
end

---Calculates wether or not the given work width is compatible with the given tramline width
---@param workWidth number @The work width of an implement
---@param tramlineWidth number @The desired tramline width
---@param tolerance number @The tolerance of the resulting tramline width
---@param forceOddMultiplier boolean @True if an odd work width multiplier is forced. For an even multiplier, you need the to have the "half-side shutoff" feature
---@return boolean @True if the work width is suitable for the tramline
function TramlineWidthChecker.workWidthIsCompatible(workWidth, tramlineWidth, tolerance, forceOddMultiplier)
	if not tonumber(workWidth) or not tonumber(tramlineWidth) or not tonumber(tolerance) or
		tonumber(workWidth) <= 0 or tonumber(tramlineWidth) <= 0 or tonumber(tolerance) < 0 or forceOddMultiplier == nil then
		Logging.warning("Received invalid input values: %s, %s, %s, %s", workWidth, tramlineWidth, tolerance, forceOddMultiplier)
		return false
	end

	local width = workWidth
	while width <= tramlineWidth + tolerance + TramlineWidthChecker.EPSILON do
		if between(width, tramlineWidth - tolerance, tramlineWidth + tolerance) then
			-- force an odd multiplier if desired, otherwise return true either way
			return not forceOddMultiplier or isOddFactor(tramlineWidth, workWidth - tolerance) or isOddFactor(tramlineWidth, workWidth + tolerance)
		end
		width = width + workWidth
	end
	return false
end