-- Copyright (c) 2024 liudepei. All Rights Reserved.
-- create at 2024/04/09 09:32:57 Tuesday

local M = {}

function M.format(str_format, ...)
  return string.format(str_format, ...)
end

function M.get_proj_root(file)
  if file then
    return M.rep(vim.fn['ProjectRootGet'](file))
  end
  return M.rep(vim.fn['ProjectRootGet']())
end

function M.cmd(str_format, ...)
  local cmd = string.format(str_format, ...)
  vim.cmd(cmd)
  return cmd
end

function M.new_file(file)
  return require 'plenary.path':new(M.rep(file))
end

function M.merge_other_functions(m, luas)
  if not luas then
    return
  end
  for _, lua in ipairs(luas) do
    for func, callback in pairs(lua) do
      if type(callback) == 'function' then
        m[func] = callback
      end
    end
  end
end

function M.is(val)
  if not val or val == 0 or val == '' or val == false or val == {} then
    return nil
  end
  return 1
end

function M.buf_get_name(bufnr)
  if bufnr then
    return vim.api.nvim_buf_get_name(bufnr)
  end
  return vim.api.nvim_buf_get_name(0)
end

function M.totable(var)
  if type(var) ~= 'table' then
    var = { var, }
  end
  return var
end

function M.rep(content)
  content = string.gsub(content, '/', '\\')
  return vim.fn.tolower(content)
end

function M.set_timeout(timeout, callback)
  return vim.fn.timer_start(timeout, function()
    callback()
  end, { ['repeat'] = 1, })
end

function M.set_interval(interval, callback)
  return vim.fn.timer_start(interval, function()
    callback()
  end, { ['repeat'] = -1, })
end

function M.clear_interval(timer)
  pcall(vim.fn.timer_stop, timer)
end

function M.aucmd(event, desc, opts)
  opts = vim.tbl_deep_extend(
    'force',
    opts,
    {
      group = vim.api.nvim_create_augroup(desc, {}),
      desc = desc,
    })
  return vim.api.nvim_create_autocmd(event, opts)
end

return M
