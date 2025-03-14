---This is the entry point of the mod

-- Remember the name, mainly for logging
MOD_NAME = g_currentModName

-- Create the actual object which filters the shop
local impl = TramlineShopFilterImpl.new()

-- Create the dialog and connect it to the implementation object
local dialog = TramlineShopFilterDialog.new(impl, TramlineShopFilterImpl.applyTramlineData)
dialog:register()


-- Temp: Use a console command to filter show the dialog
Temp2 = {}
local temp2 = setmetatable({}, Class(Temp2))
function Temp2:consoleCommandShowTramlineShopFilterDialog()
	print("Showing Dialog")
	dialog:show()
end
addConsoleCommand("tsfShowDialog", "Show Tramline Shop Filter Dialog", "consoleCommandShowTramlineShopFilterDialog", temp2)

