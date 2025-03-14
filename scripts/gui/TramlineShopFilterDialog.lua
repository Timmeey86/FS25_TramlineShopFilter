---This class creates a dialog based on the matching XML file and handles interactions in this dialog
---@class TramlineShopFilterDialog
---@field filterFunc function @The function which will be called when the user clicks yes in the filter dialog
---@field filterFuncTarget table @The instance which owns filterFunc
---@field tramlineWidth number @The tramline width in meters, as selected by the user
---@field tolerance number @The total tramline width tolerance in meters, as selected by the user
---@field DIALOG_ID string @The identifier of the dialog
---@field tramlineWidthSlider OptionSlider @The UI element which allows the user to select the tramline width. Defined in XML.
---@field toleranceLabel Text @The label which describes the tolerance setting. Defined in XML.
---@field toleranceSlider OptionSlider @The UI element which allows the user to select the tolerance for the tramline calculation. Defined in XML.
TramlineShopFilterDialog = {
	DIALOG_ID = "TramlineShopFilterDialog"
}
-- Inherit from a yes/no dialog which is the closest base to what we want
local TramlineShopFilterDialog_mt = Class(TramlineShopFilterDialog, YesNoDialog)

---Creates a new instance
---@param callbackTarget table @The target table which shall receive callbacks. This will only receive "yes" callbacks since the "no" press will simply close the dialog
---@param filterFunc function @The callback for when the user clicks yes. This will receive the callback target, the tramline width and the tolerance as arguments.
---@return TramlineShopFilterDialog @The new instance
function TramlineShopFilterDialog.new(callbackTarget, filterFunc)
	local self = YesNoDialog.new(callbackTarget, TramlineShopFilterDialog_mt)
	self.filterFunc = filterFunc
	self.filterFuncTarget = callbackTarget

	-- Forward the yes/no click to this class, which will then only forward it to the callback target in the "yes" case
	self:setCallback(TramlineShopFilterDialog.onYesNo, self)
	return self
end

---Registers the dialog with g_gui
---@param instance TramlineShopFilterDialog @The instance to register
function TramlineShopFilterDialog.register(instance)
	local xmlPath = Utils.getFilename("gui/TramlineShopFilterDialog.xml", g_currentModDirectory)
	g_gui:loadGui(xmlPath, TramlineShopFilterDialog.DIALOG_ID, instance)
end

---Reacts on yes/no presses
---@param yesWasPressed boolean @True if yes was pressed, false otherwise
function TramlineShopFilterDialog:onYesNo(yesWasPressed)
	if yesWasPressed then
		self.filterFunc(self.filterFuncTarget, self.tramlineWidth, self.tolerance)
	end
end

---Displays the dialog
function TramlineShopFilterDialog:show()
	-- Temp:
	self.tramlineWidthSlider:setTexts({"1","2","3","4","5","6", "8", "10", "12", "18", "24", "48"})
	self.tramlineWidthSlider:setState(10)
	self.toleranceSlider:setTexts({"0.0", "0.1", "0.2", "0.3", "0.4", "0.5", "0.6", "0.7", "0.8", "0.9", "1.0"})
	self.toleranceSlider:setState(1)
	---------


	self:setDialogType(DialogElement.TYPE_QUESTION)
	g_gui:showDialog(TramlineShopFilterDialog.DIALOG_ID)
end