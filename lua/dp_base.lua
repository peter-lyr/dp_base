local M = {}

local dp_asyncrun = require 'dp_asyncrun'

function M.histadd_cmd_later()
  M.histadd_cmd_en = 1
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
    M.histadd_cmd_en = nil
    return
  end
  if M.histadd_cmd_en then
    vim.fn.histadd(':', cmd)
  end
  M.histadd_cmd_en = nil
end

return M
