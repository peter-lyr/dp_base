-- Copyright (c) 2024 liudepei. All Rights Reserved.
-- create at 2024/04/08 09:54:46 Monday

-- [x] TODODONE: declare the function automatically

local M = {}

function M.merge_other_functions(luas)
  for _, lua in ipairs(luas) do
    for func, callback in pairs(lua) do
      if type(callback) == 'function' then
        M[func] = callback
      end
    end
  end
end

local system_cmd = require 'dp_base.system_cmd'
local plenary_path = require 'dp_base.plenary_path'

M.merge_other_functions {
  system_cmd,
  plenary_path,
}

function M.lazy_map(tbls)
  for _, tbl in ipairs(tbls) do
    local opt = {}
    for k, v in pairs(tbl) do
      if type(k) == 'string' and k ~= 'mode' then
        opt[k] = v
      end
    end
    local lhs = tbl[1]
    if type(lhs) == 'table' then
      for _, l in ipairs(lhs) do
        vim.keymap.set(tbl['mode'], l, tbl[2], opt)
      end
    else
      vim.keymap.set(tbl['mode'], lhs, tbl[2], opt)
    end
  end
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

function M.check_plugins(plugins)
  local fails = {}
  local temp = require 'lazy.core.config'.plugins
  for _, plugin in ipairs(plugins) do
    local name = plugin:match '.*/(.*)'
    if not temp[name] then
      fails[#fails + 1] = name
    end
  end
  return fails
end

return M
