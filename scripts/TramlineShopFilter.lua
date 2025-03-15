---This is the entry point of the mod

-- Remember the name, mainly for logging
MOD_NAME = g_currentModName

-- Create the actual object which filters the shop
local impl = TramlineShopFilterImpl.new()

-- Create the dialog and connect it to the implementation object
local dialog = TramlineShopFilterDialog.new(impl, TramlineShopFilterImpl.applyTramlineData)
dialog:register()