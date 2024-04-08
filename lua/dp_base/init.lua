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
local text_process = require 'dp_base.text_process'
local nvim_api = require 'dp_base.nvim_api'

M.merge_other_functions {
  system_cmd,
  plenary_path,
  text_process,
  nvim_api,
}

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
