---This class is responsible for filtering the shop based on user settings
---@class TramlineShopFilterImpl
---@field currentTramlineWidth number|nil @The current tramline width to filter for or nil to do nothing
---@field currentTolerance number|nil @The current tolerance to filter for
TramlineShopFilterImpl = {}
TramlineShopFilterImpl_mt = Class(TramlineShopFilterImpl)

---Creates a new instance
---@return TramlineShopFilterImpl @The created instance
function TramlineShopFilterImpl.new()
	local self = setmetatable({}, TramlineShopFilterImpl_mt)
	self.currentTramlineWidth = nil
	self.currentTolerance = nil
	ShopItemsFrame.setDisplayItems = Utils.overwrittenFunction(
		ShopItemsFrame.setDisplayItems, 
		function(shopItemsFrame, superFunc, items, ...) self:filterIfNeeded(shopItemsFrame, superFunc, items, ...) end)
	return self
end

---Sets new tramline data for filtering the shop
---@param tramlineWidth number|nil @The tramline width to filter for or nil otherwise
---@param tolerance number|nil @The tolerance to use for calculations or nil otherwise
function TramlineShopFilterImpl:applyTramlineData(tramlineWidth, tolerance)
	self.currentTramlineWidth = tramlineWidth
	self.currentTolerance = tolerance
end

---Hooks into the function which processes the display items and filters items if desired
---@param shopItemsFrame ShopItemsFrame @The instance which owns the shop items frame.
---@param superFunc function @The function we are hooking into.
---@param items table @The unfiltered list of items.
---@param ... unknown @A list of additional parameters we don't care about. These are forwarded to superFunc.
function TramlineShopFilterImpl:filterIfNeeded(shopItemsFrame, superFunc, items, ...)
	local filteredItems = nil
	if items and self.currentTramlineWidth then
		filteredItems = {}
		for _, item in ipairs(items) do
			local storeItem = item.storeItem
			if not storeItem.specs then
				Logging.error("No specs for " .. storeItem.xmlFilename)
				printCallstack()
				break
			end
			-- Make sure the work widths are already retrieved (only once per item and game session)
			WorkWidthRetriever.injectWorkWidths(storeItem)
			if storeItem.FS25_TramlineWidthChecker and storeItem.FS25_TramlineWidthChecker.workWidths then
				for _, workWidth in ipairs(storeItem.FS25_TramlineWidthChecker.workWidths) do
					if TramlineWidthChecker.workWidthIsCompatible(tonumber(workWidth), self.currentTramlineWidth, self.currentTolerance or 0) then
						table.insert(filteredItems, item)
						break -- the inner loop and continue with the next item
					end
				end
			else
				Logging.warning("No work width data for " .. storeItem.xmlFilename)
			end
		end
	end
	-- Supply the list of filtered items if it was built, or the original one if not
	return superFunc(shopItemsFrame, filteredItems or items, ...)
end