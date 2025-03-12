---This class creates a dialog based on the matching XML file and handles interactions in this dialog
---@class TramlineShopFilterDialog
---@field filterFunc function @The function which will be called when the user clicks yes in the filter dialog
---@field filterFuncTarget table @The instance which owns filterFunc
---@field tramlineWidth number @The tramline width in meters, as selected by the user
---@field tolerance number @The total tramline width tolerance in meters, as selected by the user
---@field DIALOG_ID string @The identifier of the dialog
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
	self:setTitle(g_i18n:getText("tsf_DialogTitle"))
	self:setText(g_i18n:getText("tsf_DialogText"))
	return self
end

---Registers the dialog with g_gui
---@param instance TramlineShopFilterDialog @The instance to register
function TramlineShopFilterDialog.register(instance)
	--local xmlPath = Utils.getFilename("gui/TramlineShopFilterDialog.xml", g_currentModDirectory)
	--g_gui:loadGui(xmlPath, TramlineShopFilterDialog.DIALOG_ID, instance)
	
	-- TEMP: Use the actual yes/no dialog for now
	g_gui:loadGui("dataS/gui/dialogs/YesNoDialog.xml", TramlineShopFilterDialog.DIALOG_ID, instance)
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
	g_gui:showDialog(TramlineShopFilterDialog.DIALOG_ID)
end