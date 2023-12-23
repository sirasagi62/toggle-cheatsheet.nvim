local vim = vim
local M={
  cheatSheetWin = nil,
  CSText = ''
}
function M.setup()
  vim.api.nvim_create_augroup( 'TCSTabChanged', {} )
  vim.api.nvim_create_autocmd( {'TabEnter'}, {
  group = 'chdirForLazygit',
  callback = function()
    M.continueCS()
  end
})
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
  if M.cheatSheetWin then
    M.closeCheatSheetWin()
  else
    M.openCheatSheetWin(text)
  end
end
function M.continueCS()
  M.openCheatSheetWin(M.CSText)
end
return M
