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
  local dir_path = require 'plenary.path':new(dir1)
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

return M
