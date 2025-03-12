---This is the entry point of the mod

-- Remember the name, mainly for logging
MOD_NAME = g_currentModName

-- temp code
Temp = {}
local Temp_mt = Class(Temp)
function Temp:tempFunc(tramlineWidth, tolerance)
	printf("Width: %s, Tolerance: %s", tramlineWidth, tolerance)
end
local temp = setmetatable({}, Temp_mt)
-----------------

local dialog = TramlineShopFilterDialog.new(temp, Temp.tempFunc)
dialog:register()

Temp2 = {}
local temp2 = setmetatable({}, Class(Temp2))
function Temp2:consoleCommandShowTramlineShopFilterDialog()
	print("Showing Dialog")
	dialog:show()
end
addConsoleCommand("tsfShowDialog", "Show Tramline Shop Filter Dialog", "consoleCommandShowTramlineShopFilterDialog", temp2)
