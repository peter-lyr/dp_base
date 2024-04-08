-- Copyright (c) 2024 liudepei. All Rights Reserved.
-- create at 2024/04/08 11:27:34 Monday

local M = {}

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

function M.rep(content)
  content = string.gsub(content, '/', '\\')
  return vim.fn.tolower(content)
end

function M.is(val)
  if not val or val == 0 or val == '' or val == false or val == {} then
    return nil
  end
  return 1
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

function M.totable(var)
  if type(var) ~= 'table' then
    var = { var, }
  end
  return var
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

return M
