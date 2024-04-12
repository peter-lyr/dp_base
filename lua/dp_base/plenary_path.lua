-- Copyright (c) 2024 liudepei. All Rights Reserved.
-- create at 2024/04/08 10:10:27 Monday

local M = {}

local common = require 'dp_base.common'

common.merge_other_functions(M, {
  common,
})

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

function M.file_parent(file)
  return M.new_file(file):parent().filename
end

function M.getcreate_dirpath(dirs)
  dirs = M.totable(dirs)
  local dir1 = table.remove(dirs, 1)
  dir1 = M.rep(dir1)
  local dir_path = M.new_file(dir1)
  if not dir_path:exists() then
    vim.fn.mkdir(dir_path.filename)
  end
  for _, dir in ipairs(dirs) do
    dir_path = dir_path:joinpath(dir)
    if not dir_path:exists() then
      vim.fn.mkdir(dir_path.filename)
    end
  end
  return dir_path
end

function M.getcreate_dir(dirs)
  return M.getcreate_dirpath(dirs).filename
end

function M.get_filepath(dirs, file)
  local dirpath = M.getcreate_dirpath(dirs)
  return dirpath:joinpath(file)
end

function M.get_file(dirs, file)
  return M.get_filepath(dirs, file).filename
end

function M.getcreate_filepath(dirs, file)
  local file_path = M.get_filepath(dirs, file)
  if not file_path:exists() then
    file_path:touch()
  end
  return file_path
end

function M.relpath(file, start)
  if not M.is(file) then
    return
  end
  vim.g.relpath = file
  vim.g.startpath = start and start or ''
  vim.cmd [[
    python << EOF
import os
import vim
try:
  relpath = os.path.relpath(vim.eval('g:relpath'), vim.eval('g:startpath')).replace('\\', '/')
  vim.command(f'let g:relpath = "{relpath}"')
except:
  vim.command(f'let g:relpath = ""')
EOF
]]
  return vim.g.relpath
end

function M.get_file_dirs(file)
  if not file then
    file = vim.api.nvim_buf_get_name(0)
  end
  file = M.rep(file)
  local file_path = M.new_file(file)
  local dirs = {}
  if not file_path:is_file() then
    table.insert(dirs, 1, M.rep(file_path.filename))
  end
  for _ = 1, 24 do
    file_path = file_path:parent()
    local name = M.rep(file_path.filename)
    dirs[#dirs + 1] = name
    if not string.match(name, '/') then
      break
    end
  end
  return dirs
end

function M.get_relative_fname(fname, proj)
  fname = vim.fn.fnamemodify(fname, ':p')
  local temp_fname = M.rep(vim.deepcopy(fname))
  local temp_proj = M.rep(vim.deepcopy(proj))
  if #temp_proj > #temp_fname then
    return fname
  end
  if string.sub(temp_fname, 1, #temp_proj) == temp_proj then
    if string.sub(temp_fname, #temp_proj + 1, #temp_proj + 1) == '\\' then
      return string.sub(fname, #temp_proj + 2, #fname)
    end
  end
  return fname
end

function M.get_file_dirs_till_git(file)
  if not file then
    file = vim.api.nvim_buf_get_name(0)
  end
  file = M.rep(file)
  local file_path = M.new_file(file)
  if not file_path:is_file() then
    print('not file: ' .. file)
    return {}
  end
  local dirs = {}
  for _ = 1, 24 do
    file_path = file_path:parent()
    local name = M.rep(file_path.filename)
    table.insert(dirs, 1, name)
    if M.file_exists(M.new_file(name):joinpath '.git'.filename) then
      break
    end
  end
  return dirs
end

function M.is_file_in_filetypes(file, filetypes)
  if not file then
    file = M.buf_get_name()
  end
  filetypes = M.totable(filetypes)
  local ext = string.match(file, '%.([^.]+)$')
  if not filetypes or M.is(vim.tbl_contains(filetypes, ext)) then
    return 1
  end
  return nil
end

function M.match_string_or(str, patterns)
  patterns = M.totable(patterns)
  for _, pattern in ipairs(patterns) do
    if string.match(str, pattern) then
      return 1
    end
  end
  return nil
end

function M.scan_files_do(dir, opt, entries)
  local files = {}
  local patterns = nil
  local filetypes = nil
  if opt then
    patterns = opt['patterns']
    filetypes = opt['filetypes']
  end
  for _, entry in ipairs(entries) do
    local file = M.rep_slash(entry)
    local f = string.sub(file, #dir + 2, #file)
    if (not M.is(patterns) or M.match_string_or(f, patterns)) and
        (not M.is(filetypes) or M.is_file_in_filetypes(f, filetypes)) then
      if not M.match_string_or(f, M.ignore_dirs) then
        files[#files + 1] = file
      end
    end
  end
  return files
end

function M.scan_files_deep(dir, opt)
  if not dir then dir = vim.loop.cwd() end
  local entries = require 'plenary.scandir'.scan_dir(dir, { hidden = true, depth = 32, add_dirs = false, })
  return M.scan_files_do(dir, opt, entries)
end

function M.normpath(file)
  if not M.file_exists(file) then
    return ''
  end
  vim.g.normpath = file
  vim.cmd [[
    python << EOF
import os
import vim
normpath = os.path.normpath(vim.eval('g:normpath')).replace('\\', '/')
vim.command(f'let g:normpath = "{normpath}"')
EOF
]]
  return M.rep(vim.g.normpath)
end

function M.get_cfile(cfile)
  if not cfile then
    cfile = M.normpath(M.format('%s\\%s', vim.fn.expand '%:p:h', vim.fn.expand '<cfile>'))
    if M.is(cfile) and M.is_file(cfile) then
      return cfile
    else
      cfile = M.normpath(M.format('%s\\%s', vim.fn.expand '%:p:h', string.match(vim.fn.getline '.', '`([^`]+)`')))
      if M.is(cfile) and M.is_file(cfile) then
        return cfile
      end
    end
    cfile = M.normpath(M.format('%s\\%s', vim.loop.cwd(), vim.fn.expand '<cfile>'))
    if M.is(cfile) and M.is_file(cfile) then
      return cfile
    else
      cfile = M.normpath(M.format('%s\\%s', vim.loop.cwd(), string.match(vim.fn.getline '.', '`([^`]+)`')))
      if M.is(cfile) and M.is_file(cfile) then
        return cfile
      end
    end
    cfile = M.normpath(M.format('%s\\%s', vim.fn.expand '%:p:h', vim.fn.expand '<cfile>'))
    if M.is(cfile) and M.is_dir(cfile) then
      return cfile
    else
      cfile = M.normpath(M.format('%s\\%s', vim.fn.expand '%:p:h', string.match(vim.fn.getline '.', '`([^`]+)`')))
      if M.is(cfile) and M.is_dir(cfile) then
        return cfile
      end
    end
    cfile = M.normpath(M.format('%s\\%s', vim.loop.cwd(), vim.fn.expand '<cfile>'))
    if M.is(cfile) and M.is_dir(cfile) then
      return cfile
    else
      cfile = M.normpath(M.format('%s\\%s', vim.loop.cwd(), string.match(vim.fn.getline '.', '`([^`]+)`')))
      if M.is(cfile) and M.is_dir(cfile) then
        return cfile
      end
    end
  end
  cfile = M.normpath(M.format('%s\\%s', vim.fn.expand '%:p:h', cfile))
  if M.is(cfile) and M.is_dir(cfile) then
    return cfile
  end
  return M.normpath(M.format('%s\\%s', vim.loop.cwd(), cfile))
end

function M.jump_or_split(file)
  file = M.rep(file)
  local file_proj = M.get_proj_root(file)
  local jumped = nil
  for winnr = 1, vim.fn.winnr '$' do
    local bufnr = vim.fn.winbufnr(winnr)
    local fname = M.rep(vim.api.nvim_buf_get_name(bufnr))
    if M.file_exists(fname) then
      local proj = M.get_proj_root(fname)
      if M.is(proj) and file_proj == proj then
        vim.fn.win_gotoid(vim.fn.win_getid(winnr))
        jumped = 1
        break
      end
    end
  end
  if not jumped then
    vim.cmd 'wincmd s'
  end
  M.cmd('e %s', file)
end

function M.find_its_place_to_open(file)
  file = M.rep(file)
  local file_proj = M.get_proj_root(file)
  for winnr = 1, vim.fn.winnr '$' do
    local bufnr = vim.fn.winbufnr(winnr)
    local fname = M.rep(vim.api.nvim_buf_get_name(bufnr))
    if M.file_exists(fname) then
      local proj = M.get_proj_root(fname)
      if M.is(proj) and file_proj == proj then
        return vim.fn.win_getid(winnr)
      end
    end
  end
  return nil
end

return M
