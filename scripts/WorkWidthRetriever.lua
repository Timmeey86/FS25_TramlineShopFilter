---This class is responsible for retrieving the work width of an implement from its XML file
---@class WorkWidthRetriever
WorkWidthRetriever = {
}

---Retrieves the supported working widths of a store item based on its already loaded spec
---@param specs table @The specs which mus be loaded already
---@return table @A list which is empty if the store item has no working width, has one entry in case of a fixed working width or several entries in case of a variable working width.
function WorkWidthRetriever.getWorkWidthsFromSpecs(specs)
	local workWidths = {}
	local workWidth = specs.workingWidth -- may be nil

	if workWidth then
		-- Fixed working width
		table.insert(workWidths, workWidth)
	else
		-- Either no working width or a variable one
		local workingWidthConfig = specs.workingWidthConfig
		if workingWidthConfig then
			-- Variable working width
			for _, workingWidthTable in pairs(workingWidthConfig) do
				for _, workWidthEntry in ipairs(workingWidthTable) do
					table.insert(workWidths, workWidthEntry)
				end
			end
		-- else: No working width
		end
	end
	return workWidths
end

---Injects the working widths after loading the store item specs from XML
---@param storeItem table @The store item
function WorkWidthRetriever.injectWorkWidths(storeItem)
	if not storeItem.FS25_TramlineWidthChecker then
		storeItem.FS25_TramlineWidthChecker = {}
		storeItem.FS25_TramlineWidthChecker.workWidths = WorkWidthRetriever.getWorkWidthsFromSpecs(storeItem.specs)
	end
end
StoreItemUtil.loadSpecsFromXML = Utils.appendedFunction(StoreItemUtil.loadSpecsFromXML, WorkWidthRetriever.injectWorkWidths)