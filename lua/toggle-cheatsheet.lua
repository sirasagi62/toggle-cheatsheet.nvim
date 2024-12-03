local vim = vim
local M={
  cheatSheetWin = nil,
  CSText = ''
}
function M.setup(isCSPersistant)
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
  for i = 1, n, 1 do
    s = s .. c
  end
  return s
end

function M.conf(easymap)
  local formalTbl = {}
  for _,v in ipairs(easymap) do
    formalTbl[#formalTbl+1] = {map=v[1],desc=v[2]}
  end
end
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

function M.closeCheatSheetWin()
  if M.cheatSheetWin then
    vim.api.nvim_win_close(M.cheatSheetWin,true)
    M.cheatSheetWin = nil
    M.CSText = ''
  end
end
function M.toggle(text)
  if M.cheatSheetWin and M.CSText==text then
    M.closeCheatSheetWin()
  else
    M.openCheatSheetWin(text)
  end
end
function M.continueCS()
  if M.cheatSheetWin then
    M.openCheatSheetWin(M.CSText)
  end
end
return M
