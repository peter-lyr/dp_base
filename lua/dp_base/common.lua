-- Copyright (c) 2024 liudepei. All Rights Reserved.
-- create at 2024/04/09 09:32:57 Tuesday

local M = {}

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

return M
