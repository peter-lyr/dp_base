-- Copyright (c) 2024 liudepei. All Rights Reserved.
-- create at 2024/04/08 09:54:46 Monday

-- [x] TODODONE: declare the function automatically

local M = {}

M.merge_other_functions = require 'dp_base.common'.merge_other_functions

function M.check_plugins(plugins)
  local fails = {}
  local temp = require 'lazy.core.config'.plugins
  for _, plugin in ipairs(plugins) do
    local name = plugin:match '.*/(.*)'
    if not temp[name] then
      fails[#fails + 1] = name
    end
  end
  if #fails > 0 then
    print 'Below is required:'
    for _, fail in ipairs(fails) do
      print(' ', fail)
    end
    return fails
  else
    return nil
  end
end

M.check_plugins {
  'git@github.com:peter-lyr/dp_asyncrun',
  'dbakker/vim-projectroot',
}

local _, system_cmd = pcall(require, 'dp_base.system_cmd')
local _, plenary_path = pcall(require, 'dp_base.plenary_path')
local _, text_process = pcall(require, 'dp_base.text_process')
local _, nvim_api = pcall(require, 'dp_base.nvim_api')

M.merge_other_functions(M, {
  system_cmd,
  plenary_path,
  text_process,
  nvim_api,
})

return M
