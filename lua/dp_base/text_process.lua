-- Copyright (c) 2024 liudepei. All Rights Reserved.
-- create at 2024/04/08 11:27:34 Monday

local M = {}

local common = require 'dp_base.common'

common.merge_other_functions(M, {
  common,
})

M.NOT_BIN_EXTS = {
  'lua',
  'c', 'h',
  'txt',
  'xm', 'lst',
  'bat', 'cmd',
}

function M.concant_info(prefix, info)
  --[[ use like this:
     [ function M.find_files_in_current_project_git_modified(params, ...)
     [   if ... then return M.concant_info(..., debug.getinfo(1)['name']) end
     [   -- else do with params
     [ end
     ]]
  prefix = tostring(prefix)
  if #prefix == 0 then
    prefix = M.lua
  end
  return prefix .. ': ' .. vim.fn.join(vim.fn.split(info, '_'))
end

function M.getlua(luafile)
  local loaded = string.match(luafile, '.+lua/(.+)%.lua')
  if not loaded then
    return ''
  end
  loaded = string.gsub(loaded, '/', '.')
  return loaded
end

function M.getsource(luafile)
  return M.rep(vim.fn.trim(luafile, '@'))
end

function M.format(str_format, ...)
  return string.format(str_format, ...)
end

function M.print(str_format, ...)
  print(M.format(str_format, ...))
end

function M.set_win_md_ft(win)
  local buf = vim.api.nvim_win_get_buf(win)
  vim.api.nvim_buf_set_option(buf, 'filetype', 'markdown')
  vim.api.nvim_win_set_option(win, 'concealcursor', 'nvic')
  vim.api.nvim_win_set_option(win, 'conceallevel', 3)
end

function M.notify_info(message)
  local messages = type(message) == 'table' and message or { message, }
  local title = ''
  if #messages > 1 then
    title = table.remove(messages, 1)
  end
  require 'notify'.dismiss()
  message = vim.fn.join(messages, '\n')
  vim.notify(message, 'info', {
    title = title,
    animate = false,
    on_open = M.set_win_md_ft,
    timeout = 1000 * 8,
  })
end

function M.notify_info_append(message)
  local messages = type(message) == 'table' and message or { message, }
  local title = ''
  if #messages > 1 then
    title = table.remove(messages, 1)
  end
  message = vim.fn.join(messages, '\n')
  vim.notify(message, 'info', {
    title = title,
    animate = false,
    on_open = M.set_win_md_ft,
    timeout = 1000 * 8,
  })
end

function M.notify_error(message)
  local messages = type(message) == 'table' and message or { message, }
  local title = ''
  if #messages > 1 then
    title = table.remove(messages, 1)
  end
  require 'notify'.dismiss()
  message = vim.fn.join(messages, '\n')
  vim.notify(message, 'error', {
    title = title,
    animate = false,
    on_open = M.set_win_md_ft,
    timeout = 1000 * 8,
  })
end

function M.notify_error_append(message)
  local messages = type(message) == 'table' and message or { message, }
  local title = ''
  if #messages > 1 then
    title = table.remove(messages, 1)
  end
  message = vim.fn.join(messages, '\n')
  vim.notify(message, 'error', {
    title = title,
    animate = false,
    on_open = M.set_win_md_ft,
    timeout = 1000 * 8,
  })
end

function M.get_short(content, max)
  if not max then
    max = vim.fn.floor(vim.o.columns * 2 / 5)
  end
  if #content >= (max * 2 - 1) then
    local s1 = ''
    local s2 = ''
    for i = (max * 2 - 1), 3, -1 do
      s2 = string.sub(content, #content - i, #content)
      if vim.fn.strdisplaywidth(s2) <= max then
        break
      end
    end
    for i = (max * 2 - 1), 3, -1 do
      s1 = string.sub(content, 1, i)
      if vim.fn.strdisplaywidth(s1) <= max then
        break
      end
    end
    return s1 .. '…' .. s2
  end
  return content
end

function M.is_file_in_extensions(file, extensions)
  extensions = M.totable(extensions)
  return M.is(vim.tbl_contains(extensions, string.match(file, '%.([^.]+)$'))) and 1 or nil
end

function M.is_in_not_bin_fts(file)
  return M.is_file_in_extensions(file, M.NOT_BIN_EXTS)
end

function M.is_detected_as_bin(file)
  if M.is_in_not_bin_fts(file) then
    return nil
  end
  local info = vim.fn.system(string.format('file -b --mime-type --mime-encoding "%s"', file))
  info = string.gsub(info, '%s', '')
  local info_l = vim.fn.split(info, ';')
  if info_l[2] and string.match(info_l[2], 'binary') and info_l[1] and not string.match(info_l[1], 'empty') then
    return 1
  end
  return nil
end

function M.is_in_tbl(item, tbl)
  return M.is(vim.tbl_contains(tbl, item))
end

function M.is_in_str(item, str)
  return string.match(str, item)
end

function M.get_proj_root(file)
  if file then
    return M.rep(vim.fn['ProjectRootGet'](file))
  end
  return M.rep(vim.fn['ProjectRootGet']())
end

function M.index_of(array, value)
  for i, v in ipairs(array) do
    if v == value then
      return i
    end
  end
  return -1
end

function M.stack_item_uniq(tbl, item)
  if M.is(tbl) then
    local index = M.index_of(tbl, item)
    if index ~= -1 then
      table.remove(tbl, index)
    end
    tbl[#tbl + 1] = item
  end
end

function M.merge_tables(...)
  local result = {}
  for _, t in ipairs { ..., } do
    for _, v in ipairs(t) do
      result[#result + 1] = v
    end
  end
  return result
end

function M.merge_dict(...)
  local result = {}
  for _, d in ipairs { ..., } do
    for k, v in pairs(d) do
      result[k] = v
    end
  end
  return result
end

function M.is_buf_fts(fts, buf)
  if not buf then
    buf = vim.fn.bufnr()
  end
  if type(fts) == 'string' then
    fts = { fts, }
  end
  if M.is(vim.tbl_contains(fts, vim.api.nvim_buf_get_option(buf, 'filetype'))) then
    return 1
  end
  return nil
end

function M.get_source_dot_dir(source, ext)
  local root = vim.fn.fnamemodify(source, ':p:h')
  local tail = vim.fn.fnamemodify(source, ':p:t')
  if string.sub(tail, 1, 1) ~= '.' then
    tail = '.' .. tail
  end
  return string.format('%s\\%s.%s', root, tail, ext)
end

function M.setreg()
  local bak = vim.fn.getreg '"'
  local save_cursor = vim.fn.getpos '.'
  local line = vim.fn.trim(vim.fn.getline '.')
  vim.g.curline = line
  if string.match(line, [[%']]) then
    vim.cmd "silent norm yi'"
    vim.g.single_quote = vim.fn.getreg '"' ~= bak and vim.fn.getreg '"' or ''
    pcall(vim.fn.setpos, '.', save_cursor)
  end
  if string.match(line, [[%"]]) then
    vim.cmd 'keepjumps silent norm yi"'
    vim.g.double_quote = vim.fn.getreg '"' ~= bak and vim.fn.getreg '"' or ''
    pcall(vim.fn.setpos, '.', save_cursor)
  end
  if string.match(line, [[%`]]) then
    vim.cmd 'keepjumps silent norm yi`'
    vim.g.back_quote = vim.fn.getreg '"' ~= bak and vim.fn.getreg '"' or ''
    pcall(vim.fn.setpos, '.', save_cursor)
  end
  if string.match(line, [[%)]]) then
    vim.cmd 'keepjumps silent norm yi)'
    vim.g.parentheses = vim.fn.getreg '"' ~= bak and vim.fn.getreg '"' or ''
    pcall(vim.fn.setpos, '.', save_cursor)
  end
  if string.match(line, '%]') then
    vim.cmd 'keepjumps silent norm yi]'
    vim.g.bracket = vim.fn.getreg '"' ~= bak and vim.fn.getreg '"' or ''
    pcall(vim.fn.setpos, '.', save_cursor)
  end
  if string.match(line, [[%}]]) then
    vim.cmd 'keepjumps silent norm yi}'
    vim.g.brace = vim.fn.getreg '"' ~= bak and vim.fn.getreg '"' or ''
    pcall(vim.fn.setpos, '.', save_cursor)
  end
  if string.match(line, [[%>]]) then
    vim.cmd 'keepjumps silent norm yi>'
    vim.g.angle_bracket = vim.fn.getreg '"' ~= bak and vim.fn.getreg '"' or ''
    pcall(vim.fn.setpos, '.', save_cursor)
  end
  vim.fn.setreg('"', bak)
end

function M.get_dp_plugins()
  return vim.fn.getcompletion('Lazy update dp_', 'cmdline')
end

return M
