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

function M.cmd(str_format, ...)
  local cmd = string.format(str_format, ...)
  vim.cmd(cmd)
  return cmd
end

function M.cmd_histadd(str_format, ...)
  vim.fn.histadd(':', M.cmd(str_format, ...))
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

function M.new_file(file)
  return require 'plenary.path':new(file)
end

function M.file_exists(file)
  file = vim.fn.trim(file)
  if #file == 0 then
    return nil
  end
  local fpath = M.new_file(file)
  if fpath:exists() then
    return fpath
  end
  return nil
end

function M.is_file(file)
  local fpath = M.file_exists(file)
  if fpath and fpath:is_file() then
    return 1
  end
  return nil
end

function M.is_dir(file)
  local fpath = M.file_exists(file)
  if fpath and fpath:is_dir() then
    return 1
  end
  return nil
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
    local name = plugin:match(".*/(.*)")
    if not temp[name] then
      fails[#fails + 1] = name
    end
  end
  return fails
end

return M
