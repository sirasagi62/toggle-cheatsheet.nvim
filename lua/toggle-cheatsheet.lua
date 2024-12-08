local vim = vim

---@class ToggleCheatSheet
local M={
  cheatSheetWin = nil,
  CSText = ''
}

---Initializer of ToggleCheatSheet. It is strongly recommended that you specify **true** for this function unless you have a specific reason not to.
---@param isCSPersistant boolean Variable that determines whether the toggle cheat sheet remains visible when switching tabs.
---@return ToggleCheatSheet
function M.setup(isCSPersistant)
  isCSPersistant = isCSPersistant==false and false or true
  if isCSPersistant then
    vim.api.nvim_create_augroup( 'TCSTabChanged', {} )
    vim.api.nvim_create_autocmd( {'TabEnter'}, {
      group = 'TCSTabChanged',
      callback = function()
        M.continueCS()
      end
    })
  end
  return M
end

function M.countLinesAndColumns(text)
    local lineCount = -1
    local maxColumnCount = 0

    for line in text:gmatch("[^\n]*\n?") do
        lineCount = lineCount + 1

        local currentColumnCount = vim.fn.strdisplaywidth(line:gsub('\n',''))
        if currentColumnCount > maxColumnCount then
            maxColumnCount = currentColumnCount
        end
    end

    return lineCount, maxColumnCount
end

function M.repeatCharacter(c,n)
  local s = ""
  for _ = 1, n, 1 do
    s = s .. c
  end
  return s
end

---@alias FormalFormat {map:string,desc:string}[]

---Convert a tuple-based "easy" keymap configurations description to "formal" format.
---Both of "easy" format and "formal" format is compartible with "sirasagi62/nvim-submode" keymap format.
---@param easymap {[1]:string, [2]:string}[] "Easy" keymap format
---@return FormalFormat "Formal" keymap format
function M.conf(easymap)
  local formalTbl = {}
  for _,v in ipairs(easymap) do
    formalTbl[#formalTbl+1] = {map=v[1],desc=v[2]}
  end
  return formalTbl
end

---Convert a keymap list described in FormalFormat to text that should be drawn in a cheat sheet window.
---The type of smKeymap is compartible with "sirasagi62/nvim-submode" keymap format.
---@param smKeymap FormalFormat
---@return string
function M.createCheatSheetFromSubmodeKeymap(smKeymap)
  -- Calculate maxmimum keymap width
  local maximumKeymapWidth = 0
  local tbl = {}
  for _,v in ipairs(smKeymap) do
    local map = v["map"]
    local currentKeymapWidth = vim.fn.strdisplaywidth(map)
    tbl[#tbl+1] = {map=map,map_width=currentKeymapWidth,desc=v["desc"]}
    maximumKeymapWidth = currentKeymapWidth > maximumKeymapWidth and currentKeymapWidth or maximumKeymapWidth
  end

  -- Generate Cheat Sheet Text
  local tcsText = ""
  for _,v in ipairs(tbl) do
    local desc =v.desc or "<No Description>"
    tcsText = tcsText .. v.map .. M.repeatCharacter(" ",maximumKeymapWidth - v.map_width) .. " : " .. desc .. "\n"
  end
  return tcsText
end

---Function to open cheat sheet window.
---If a cheat sheet is already opened, the function override the window by implicitly closing the old one.
---@param text string
---@return unknown
function M.openCheatSheetWin(text)
  M.closeCheatSheetWin()
  local api=vim.api
  local row,col = M.countLinesAndColumns(text)
  local buf = api.nvim_create_buf(false,true)
  local lines={}
  for line in text:gmatch('[^\n]*\n?') do
    lines[#lines+1] = line:gsub('\n','')
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)
  local win=api.nvim_open_win(buf, false,
    {
      relative='editor',
      height=row,
      width=col+2,
      row=api.nvim_get_option('lines')-5,
      col=api.nvim_get_option('columns')-5,
      anchor='SE',
      focusable = false,
      border='rounded'
    }
  )
  vim.api.nvim_win_set_option(win, 'number',  false)
  api.nvim_win_set_option(win, 'relativenumber', false)
  api.nvim_win_set_option(win, 'wrap',  false)
  api.nvim_win_set_option(win, 'cursorline',  false)
  M.cheatSheetWin = win
  M.CSText = text
  return win
end

---A function to close an opening window managed by the plugin.
function M.closeCheatSheetWin()
  if M.cheatSheetWin then
    vim.api.nvim_win_close(M.cheatSheetWin,true)
    M.cheatSheetWin = nil
    M.CSText = ''
  end
end

---A function to toggle cheat sheet window.
---If a different window is already opened, the function will override the window by the given new one.
---@param text string
function M.toggle(text)
  if M.cheatSheetWin and M.CSText==text then
    M.closeCheatSheetWin()
  else
    M.openCheatSheetWin(text)
  end
end

-- An internal function to keep opening window across changing tabs.
function M.continueCS()
  if M.cheatSheetWin then
    M.openCheatSheetWin(M.CSText)
  end
end
return M
