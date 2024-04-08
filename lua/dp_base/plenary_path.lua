-- Copyright (c) 2024 liudepei. All Rights Reserved.
-- create at 2024/04/08 10:10:27 Monday

local M = {}

function M.rep(content)
  content = string.gsub(content, '/', '\\')
  return vim.fn.tolower(content)
end

function M.new_file(file)
  return require 'plenary.path':new(M.rep(file))
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

function M.file_parent(file)
  return M.new_file(file):parent().filename
end

function M.totable(var)
  if type(var) ~= 'table' then
    var = { var, }
  end
  return var
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

function M.get_filepath(dirs, file)
  local dirpath = M.getcreate_dirpath(dirs)
  return dirpath:joinpath(file)
end

function M.get_file(dirs, file)
  return M.get_filepath(dirs, file).filename
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

return M
