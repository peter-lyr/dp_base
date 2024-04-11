-- Copyright (c) 2024 liudepei. All Rights Reserved.
-- create at 2024/04/08 10:06:07 Monday

local M = {}

local common = require 'dp_base.common'

common.merge_other_functions(M, {
  common,
})

local dp_asyncrun = require 'dp_asyncrun'

function M.system_cd(file)
  local fpath = M.new_file(file)
  if fpath:is_dir() then
    return 'cd /d ' .. file
  else
    return 'cd /d ' .. fpath:parent().filename
  end
end

function M.system_run(way, str_format, ...)
  if type(str_format) == 'table' then
    str_format = vim.fn.join(str_format, ' && ')
  end
  local cmd = string.format(str_format, ...)
  if way == 'start' then
    cmd = string.format([[silent !start cmd /c "%s"]], cmd)
    vim.cmd(cmd)
  elseif way == 'start silent' then
    cmd = string.format([[silent !start /b /min cmd /c "%s"]], cmd)
    vim.cmd(cmd)
  elseif way == 'asyncrun' then
    vim.cmd 'AsyncStop'
    cmd = string.format('AsyncRun %s', cmd)
    if vim.g.asyncrun_status == 'running' then
      M.timer_temp = vim.fn.timer_start(10, function()
        if vim.g.asyncrun_status ~= 'running' then
          pcall(vim.fn.timer_stop, M.timer_temp)
          dp_asyncrun.done_default()
          vim.cmd(cmd)
        end
      end, { ['repeat'] = -1, })
    else
      vim.cmd(cmd)
      dp_asyncrun.done_default()
    end
  elseif way == 'term' then
    cmd = string.format('wincmd s|term %s', cmd)
    vim.cmd(cmd)
  else
    return
  end
end

function M.system_run_histadd(way, str_format, ...)
  M.system_run(way, str_format, ...)
  vim.fn.histadd(':', cmd)
end

function M.cmd_histadd(str_format, ...)
  vim.fn.histadd(':', M.cmd(str_format, ...))
end

return M
