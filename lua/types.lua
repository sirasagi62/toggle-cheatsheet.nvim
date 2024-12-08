---@class ToggleCheatSheet
---@field setup fun(isCSPersistant: boolean): ToggleCheatSheet setup function.
---@field conf fun(easymap: {[1]:string, [2]:string}[]): FormalFormat a function to convert easy keymap format to formal one.
---@field createCheatSheetFromSubmodeKeymap fun(smKeymap: FormalFormat): string a function formal keymap format to text for cheat sheet window.
---@field openCheatSheetWin fun(text: string): unknown a function to open cheat sheet window.
---@field closeCheatSheetWin fun() a function to close the window.
---@field toggle fun(text: string) a function to toggle the window visibility.
local ToggleCheatSheet
return ToggleCheatSheet

