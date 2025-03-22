---This class creates a dialog based on the matching XML file and handles interactions in this dialog
---@class TramlineShopFilterDialog
---@field filterFunc function @The function which will be called when the user clicks yes in the filter dialog
---@field filterFuncTarget table @The instance which owns filterFunc
---@field DIALOG_ID string @The identifier of the dialog
---@field TRAMLINE_WIDTHS table @Contains the possible tramline widths as integers
---@field TRAMLINE_WIDTH_STRINGS table @Contains the readable strings of the tramline widths, including units
---@field TOLERANCES table @Contains the possible tolerances as integers
---@field TOLERANCE_STRINGS table @Contains the readable strings of the tolerances, including units
---@field tramlineWidthSlider OptionSlider @The UI element which allows the user to select the tramline width. Defined in XML.
---@field toleranceSlider OptionSlider @The UI element which allows the user to select the tolerance for the tramline calculation. Defined in XML.
---@field allowEvenMultiplier BinaryOptionElement @The UI element which toggles between allowing only odd numbers or odd and even numbers. Defined in XML.
TramlineShopFilterDialog = {
	DIALOG_ID = "TramlineShopFilterDialog",
	TRAMLINE_WIDTHS = {},
	TRAMLINE_WIDTH_STRINGS = {},
	TOLERANCES = {},
	TOLERANCE_STRINGS = {}
}

-- One-time initialization
for i = 1, 48 do
	table.insert(TramlineShopFilterDialog.TRAMLINE_WIDTHS, i)
	-- Note: We're not using g_i18n:formatDistance since work widths are always shown in meters ingame, independent of unit settings
	table.insert(TramlineShopFilterDialog.TRAMLINE_WIDTH_STRINGS, ("%d m"):format(i))
end
for i = 0, 10 do
	table.insert(TramlineShopFilterDialog.TOLERANCES, i / 10)
	table.insert(TramlineShopFilterDialog.TOLERANCE_STRINGS, ("%.1f m"):format(i / 10))
end

-- Inherit from a yes/no dialog which is the closest base to what we want
local TramlineShopFilterDialog_mt = Class(TramlineShopFilterDialog, YesNoDialog)

---Creates a new instance
---@param callbackTarget table @The target table which shall receive callbacks. This will only receive "yes" callbacks since the "no" press will simply close the dialog
---@param filterFunc function @The callback for when the user clicks yes. This will receive the callback target, the tramline width, the tolerance and a flag which allows even multipliers if true as arguments.
---@return TramlineShopFilterDialog @The new instance
function TramlineShopFilterDialog.new(callbackTarget, filterFunc)
	local self = YesNoDialog.new(callbackTarget, TramlineShopFilterDialog_mt)
	self.filterFunc = filterFunc
	self.filterFuncTarget = callbackTarget

	-- Forward the yes/no click to this class, which will then only forward it to the callback target in the "yes" case
	self:setCallback(TramlineShopFilterDialog.onYesNo, self)

	-- Register a hotkey when the shop opens (we do this here so we can access self)
	TabbedMenuWithDetails.onOpen = Utils.overwrittenFunction(
		TabbedMenuWithDetails.onOpen,
		function(menu, superFunc, ...) self:registerHotkeyOnMenuOpen(menu, superFunc, ...) end)
		-- Reset the filter when the shop closes
		TabbedMenuWithDetails.exitMenu = Utils.prependedFunction(TabbedMenuWithDetails.exitMenu, function() self:onMenuClose() end)
	return self
end

---Registers the dialog with g_gui
function TramlineShopFilterDialog:register()
	local xmlPath = Utils.getFilename("gui/TramlineShopFilterDialog.xml", g_currentModDirectory)
	g_gui:loadGui(xmlPath, TramlineShopFilterDialog.DIALOG_ID, self)
	self.tramlineWidthSlider.textElement.textUpperCase = false
	self.tramlineWidthSlider:setTexts(TramlineShopFilterDialog.TRAMLINE_WIDTH_STRINGS)
	self.toleranceSlider.textElement.textUpperCase = false
	self.toleranceSlider:setTexts(TramlineShopFilterDialog.TOLERANCE_STRINGS)
	self.allowEvenMultiplier:setIsChecked(false) -- without Pro Seed, even numbers of lines per tramline is a mess, so default is false
end

---Reacts on yes/no presses and calls the callback function which was supplied to the constructor, in the yes case
---@param yesWasPressed boolean @True if yes was pressed, false otherwise
function TramlineShopFilterDialog:onYesNo(yesWasPressed)
	local tramlineWidth, tolerance
	if yesWasPressed then
		tramlineWidth = tonumber(TramlineShopFilterDialog.TRAMLINE_WIDTHS[self.tramlineWidthSlider.state or 1])
		tolerance = tonumber(TramlineShopFilterDialog.TOLERANCES[self.toleranceSlider.state or 1])
	else
		tramlineWidth = nil
		tolerance = nil
	end
	self.filterFunc(self.filterFuncTarget, tramlineWidth, tolerance, self.allowEvenMultiplier:getIsChecked())
end

---Displays the dialog
function TramlineShopFilterDialog:show()
	self:setDialogType(DialogElement.TYPE_QUESTION)
	g_gui:showDialog(TramlineShopFilterDialog.DIALOG_ID)
end

---Checks whether or not the filter dialog may be shown. Note that this currently requires having the shop open at the vehicle overview.
---@return boolean @True if it may be shown.
local function dialogMayBeShown()
	local shopIsOpen = g_shopMenu.isOpen
	local shopIsAtToplevel = #g_shopMenu:getStack() == 1
	local vehicleTabIsOpen = g_shopMenu.pageSelector.state == g_shopMenu.pagingElement:getPageMappingIndexByElement(g_shopMenu.pageShopVehicles)
	return shopIsOpen and shopIsAtToplevel and vehicleTabIsOpen
end

---Registers a hotkey for the dialog when the proper shop menu is being opened
---@param menu TabbedMenuWithDetails @The menu we are hooking into
---@param superFunc function @The function we are overwriting
---@param ... unknown @A list of additional parameters which are being forwarded but not processed
function TramlineShopFilterDialog:registerHotkeyOnMenuOpen(menu, superFunc, ...)
	-- Make sure we call the base game implementation which also makes sure we don't break other mods
	local ret = superFunc(menu, ...)

	if dialogMayBeShown() then

		-- Shop is open, register the hotkey now
		local success, actionEventId = g_inputBinding:registerActionEvent(InputAction.TRAMLINE_FILTER, self, TramlineShopFilterDialog.onHotkeyPressed, false, true, false, true, nil, true)
		if success then
			-- We don't want this to block anything else in the F1 menu
			g_inputBinding:setActionEventTextPriority(actionEventId, GS_PRIO_VERY_LOW)
		end
	end

	-- return the original return value
	return ret
end

---Displays the dialog when the hotkey is pressed while the shop is open
function TramlineShopFilterDialog:onHotkeyPressed()
	if dialogMayBeShown() then
		self:show()
	end
end

function TramlineShopFilterDialog:onMenuClose()
	if g_shopMenu.isOpen then
		-- Reset filters
		self.filterFunc(self.filterFuncTarget, nil, nil)
	end
end