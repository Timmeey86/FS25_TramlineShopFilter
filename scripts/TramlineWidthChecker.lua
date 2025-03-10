---This class is responsible for figuring out whether or not a certain work width is compatible with a tramline width
---@class TramlineWidthChecker
---@field EPSILON number @The maximum floating point imprecision we tolerate
TramlineWidthChecker = {
	EPSILON = 0.001
}

---Checks whether or not two numbers are almost equal, respecting floating point imprecision
---@param first number @The first number
---@param second number @The second number
---@return boolean @True if the numbers are almost equal
local function nearlyEqual(first, second)
	return math.abs(first - second) < TramlineWidthChecker.EPSILON
end

---Checks whether or not a number is between two other numbers, respecting floating point imprecision
---@param value number @The value
---@param lowerBound number @The lower bound
---@param upperBound number @The upper bound
---@return boolean @True if value is within [lowerBound, upperBound]
local function between(value, lowerBound, upperBound)
	return value >= lowerBound - TramlineWidthChecker.EPSILON and value <= upperBound + TramlineWidthChecker.EPSILON
end

---Calculates wether or not the given work width is compatible with the given tramline width
---@param workWidth number @The work width of an implement
---@param tramlineWidth number @The desired tramline width
---@param tolerance number @The tolerance of the resulting tramline width
---@return boolean @True if the work width is suitable for the tramline
function TramlineWidthChecker.workWidthIsCompatible(workWidth, tramlineWidth, tolerance)
	if not tonumber(workWidth) or not tonumber(tramlineWidth) or not tonumber(tolerance) or
		workWidth <= 0 or tramlineWidth <= 0 or tolerance < 0 then
		Logging.warning("Received invalid input values: %s, %s, %s", workWidth, tramlineWidth, tolerance)
		return false
	end

	local width = workWidth
	while width <= tramlineWidth + tolerance do
		if between(width, tramlineWidth - tolerance, tramlineWidth + tolerance) then
			return true
		end
		width = width + workWidth
	end

	return false
end