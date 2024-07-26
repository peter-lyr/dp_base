-- Copyright (c) 2024 liudepei. All Rights Reserved.
-- create at 2024/04/08 09:54:46 Monday

-- [x] TODODONE: declare the function automatically

local M = {}

M.NOT_BIN_EXTS = {
  'lua',
  'c', 'h',
  'txt',
  'xm', 'lst',
  'bat', 'cmd',
}

M.yanking = nil

M.temp_maps = {}
M.exclude_chars = {}

M.chars = {
  'a', 'b', 'c', 'd', 'e',
  'f', 'g', 'h', 'i', 'j',
  'k', 'l', 'm', 'n', 'o',
  'p', 'q', 'r', 's', 't',
  'u', 'v', 'w', 'x', 'y',
  'z',
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
  'git@github.com:peter-lyr/dp_init',
  'git@github.com:peter-lyr/dp_asyncrun',
  'git@github.com:peter-lyr/sha2',
  'dbakker/vim-projectroot',
  'rcarriga/nvim-notify',
}

local dp_asyncrun = require 'dp_asyncrun'

M.ignore_dirs = {
  '.git',
}

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
  local loaded = string.match(M.rep(luafile), '.+lua\\(.+)%.lua')
  if not loaded then
    return ''
  end
  loaded = string.gsub(loaded, '\\', '.')
  return loaded
end

function M.getsource(luafile)
  return M.rep(vim.fn.trim(luafile, '@'))
end

function M.print(str_format, ...)
  print(M.format(str_format, ...))
end

function M.echo(str_format, ...)
  str_format = string.gsub(str_format, "'", '"')
  M.cmd(string.format("ec '" .. str_format .. "'", ...))
end

function M.set_win_md_ft(win)
  local buf = vim.api.nvim_win_get_buf(win)
  vim.api.nvim_buf_set_option(buf, 'filetype', 'markdown')
  vim.api.nvim_win_set_option(win, 'concealcursor', 'nvic')
  vim.api.nvim_win_set_option(win, 'conceallevel', 3)
end

function M.notify_info(message, timeout)
  local messages = type(message) == 'table' and message or { message, }
  local title = ''
  if #messages > 1 then
    title = table.remove(messages, 1)
  end
  require 'notify'.dismiss()
  message = vim.fn.join(messages, '\n')
  vim.notify(message, 'info', {
    title = title,
    animate = false,
    on_open = M.set_win_md_ft,
    timeout = timeout or (1000 * 8),
  })
end

function M.notify_info_append(message, timeout)
  local messages = type(message) == 'table' and message or { message, }
  local title = ''
  if #messages > 1 then
    title = table.remove(messages, 1)
  end
  message = vim.fn.join(messages, '\n')
  vim.notify(message, 'info', {
    title = title,
    animate = false,
    on_open = M.set_win_md_ft,
    timeout = timeout or (1000 * 8),
  })
end

function M.notify_error(message, timeout)
  local messages = type(message) == 'table' and message or { message, }
  local title = ''
  if #messages > 1 then
    title = table.remove(messages, 1)
  end
  require 'notify'.dismiss()
  message = vim.fn.join(messages, '\n')
  vim.notify(message, 'error', {
    title = title,
    animate = false,
    on_open = M.set_win_md_ft,
    timeout = timeout or (1000 * 8),
  })
end

function M.notify_error_append(message, timeout)
  local messages = type(message) == 'table' and message or { message, }
  local title = ''
  if #messages > 1 then
    title = table.remove(messages, 1)
  end
  message = vim.fn.join(messages, '\n')
  vim.notify(message, 'error', {
    title = title,
    animate = false,
    on_open = M.set_win_md_ft,
    timeout = timeout or (1000 * 8),
  })
end

function M.get_short(content, max, sep)
  if not sep then
    sep = '…'
  end
  if not max then
    max = vim.fn.floor(vim.o.columns * 2 / 5)
  end
  if #content > (max * 2 + 1) then
    local s1 = ''
    local s2 = ''
    for i = (max * 2 - 1), 0, -1 do
      s2 = string.sub(content, #content - i, #content)
      if vim.fn.strdisplaywidth(s2) <= max then
        break
      end
    end
    for i = (max * 2 - 1), 0, -1 do
      s1 = string.sub(content, 1, i)
      if vim.fn.strdisplaywidth(s1) <= max then
        break
      end
    end
    return s1 .. sep .. s2
  end
  return content
end

function M.is_file_in_extensions(file, extensions)
  extensions = M.totable(extensions)
  return M.is(vim.tbl_contains(extensions, string.match(file, '%.([^.]+)$'))) and 1 or nil
end

function M.is_in_not_bin_fts(file)
  return M.is_file_in_extensions(file, M.NOT_BIN_EXTS)
end

function M.is_detected_as_bin(file)
  if M.is_in_not_bin_fts(file) then
    return nil
  end
  local info = vim.fn.system(string.format('file -b --mime-type --mime-encoding "%s"', file))
  info = string.gsub(info, '%s', '')
  local info_l = vim.fn.split(info, ';')
  if info_l[2] and string.match(info_l[2], 'binary') and info_l[1] and not string.match(info_l[1], 'empty') then
    return 1
  end
  return nil
end

function M.is_in_tbl(item, tbl)
  return M.is(vim.tbl_contains(tbl, item))
end

function M.is_in_str(item, str)
  return string.match(str, item)
end

function M.index_of(array, value)
  for i, v in ipairs(array) do
    if v == value then
      return i
    end
  end
  return -1
end

function M.pop_item(tbl, item)
  if M.is(tbl) then
    local index = M.index_of(tbl, item)
    if index ~= -1 then
      table.remove(tbl, index)
    end
  end
end

function M.stack_item(tbl, item, len)
  local res = {}
  if M.is(tbl) and tbl[#tbl] == item then
    return res
  end
  if #tbl >= len then
    for _ = 1, #tbl - len + 1 do
      res[#res + 1] = table.remove(tbl, 1)
    end
  end
  tbl[#tbl + 1] = item
  return res
end

function M.stack_item_uniq(tbl, item)
  if M.is(tbl) then
    M.pop_item(tbl, item)
    tbl[#tbl + 1] = item
  end
end

function M.merge_tables(...)
  local result = {}
  for _, t in ipairs { ..., } do
    for _, v in ipairs(t) do
      result[#result + 1] = v
    end
  end
  return result
end

function M.merge_dict(...)
  local result = {}
  for _, d in ipairs { ..., } do
    for k, v in pairs(d) do
      result[k] = v
    end
  end
  return result
end

function M.is_buf_fts(fts, buf)
  if not buf then
    buf = vim.fn.bufnr()
  end
  if type(fts) == 'string' then
    fts = { fts, }
  end
  if M.is(vim.tbl_contains(fts, vim.api.nvim_buf_get_option(buf, 'filetype'))) then
    return 1
  end
  return nil
end

function M.get_source_dot_dir(source, ext)
  local root = vim.fn.fnamemodify(source, ':p:h')
  local tail = vim.fn.fnamemodify(source, ':p:t')
  if string.sub(tail, 1, 1) ~= '.' then
    tail = '.' .. tail
  end
  if ext then
    ext = '.' .. ext
  else
    ext = ''
  end
  return string.format('%s\\%s%s', root, tail, ext)
end

function M.setreg()
  M.yanking = 1
  local bak = vim.fn.getreg '"'
  local save_cursor = vim.fn.getpos '.'
  local line = vim.fn.trim(vim.fn.getline '.')
  vim.g.curline = line
  if string.match(line, [[%']]) then
    vim.cmd "keepjumps silent norm yi'"
    vim.g.single_quote = vim.fn.getreg '"' ~= bak and vim.fn.getreg '"' or ''
    pcall(vim.fn.setpos, '.', save_cursor)
  end
  if string.match(line, [[%"]]) then
    vim.cmd 'keepjumps silent norm yi"'
    vim.g.double_quote = vim.fn.getreg '"' ~= bak and vim.fn.getreg '"' or ''
    pcall(vim.fn.setpos, '.', save_cursor)
  end
  if string.match(line, [[%`]]) then
    vim.cmd 'keepjumps silent norm yi`'
    vim.g.back_quote = vim.fn.getreg '"' ~= bak and vim.fn.getreg '"' or ''
    pcall(vim.fn.setpos, '.', save_cursor)
  end
  if string.match(line, [[%)]]) then
    vim.cmd 'keepjumps silent norm yi)'
    vim.g.parentheses = vim.fn.getreg '"' ~= bak and vim.fn.getreg '"' or ''
    pcall(vim.fn.setpos, '.', save_cursor)
  end
  if string.match(line, '%]') then
    vim.cmd 'keepjumps silent norm yi]'
    vim.g.bracket = vim.fn.getreg '"' ~= bak and vim.fn.getreg '"' or ''
    pcall(vim.fn.setpos, '.', save_cursor)
  end
  if string.match(line, [[%}]]) then
    vim.cmd 'keepjumps silent norm yi}'
    vim.g.brace = vim.fn.getreg '"' ~= bak and vim.fn.getreg '"' or ''
    pcall(vim.fn.setpos, '.', save_cursor)
  end
  if string.match(line, [[%>]]) then
    vim.cmd 'keepjumps silent norm yi>'
    vim.g.angle_bracket = vim.fn.getreg '"' ~= bak and vim.fn.getreg '"' or ''
    pcall(vim.fn.setpos, '.', save_cursor)
  end
  vim.fn.setreg('"', bak)
  M.yanking = nil
end

if not DataLazyPlugins then
  DataLazyPlugins = vim.fn.stdpath 'data' .. '\\lazy\\plugins'
  print('DataLazyPlugins not found, set it: ' .. DataLazyPlugins .. '(maybe wrong, please check)')
end

function M.get_dp_plugins()
  local dirs = {}
  for _, dir in ipairs(vim.fn.getcompletion('Lazy update dp_', 'cmdline')) do
    dirs[#dirs + 1] = DataLazyPlugins .. '\\' .. dir
  end
  return dirs
end

function M.findall(patt, str)
  vim.g.patt = patt
  vim.g.str = str
  vim.g.res = {}
  vim.cmd [[
    python << EOF
import re
import vim
try:
  import luadata
except:
  import os
  os.system('pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --trusted-host mirrors.aliyun.com luadata')
  import luadata
patt = vim.eval('g:patt')
string = vim.eval('g:str')
res = re.findall(patt, string)
if res:
  new_res = eval(str(res).replace('(', '[').replace(')', ']'))
  new_res = luadata.serialize(new_res, encoding='utf-8', indent=' ', indent_level=0)
  vim.command(f"""lua vim.g.res = {new_res}""")
EOF
  ]]
  return vim.g.res
end

function M.new_file(file)
  return require 'plenary.path':new(M.rep(file))
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

function M.rep_slash(content)
  content = string.gsub(content, '\\', '/')
  return vim.fn.tolower(content)
end

function M.set_timeout(timeout, callback)
  return vim.fn.timer_start(timeout, function()
    callback()
  end, { ['repeat'] = 1, })
end

function M.set_timeout_2(timeout, times, callback)
  return vim.fn.timer_start(timeout, function()
    callback()
  end, { ['repeat'] = times, })
end

function M.set_interval(interval, callback)
  return vim.fn.timer_start(interval, function()
    callback()
  end, { ['repeat'] = -1, })
end

function M.set_interval_vim_g(name, interval, callback)
  if vim.g[name] then
    M.clear_interval(vim.g[name])
  end
  vim.g[name] = vim.fn.timer_start(interval, function()
    callback()
  end, { ['repeat'] = -1, })
end

function M.clear_interval(timer)
  pcall(vim.fn.timer_stop, timer)
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

function M.copyright(extension, callback)
  M.aucmd({ 'BufReadPre', }, extension .. '.BufReadPre', {
    callback = function(ev)
      local file = vim.api.nvim_buf_get_name(ev.buf)
      local ext = string.match(file, '%.([^.]+)$')
      if vim.fn.getfsize(file) == 0 then
        M.set_timeout(10, function()
          if ext == 'norg' then
            vim.cmd 'Neorg inject-metadata'
          else
            vim.cmd 'norm ggdG'
            vim.fn.setline(1, {
              string.format('Copyright (c) %s %s. All Rights Reserved.', vim.fn.strftime '%Y', 'liudepei'),
              vim.fn.strftime 'create at %Y/%m/%d %H:%M:%S %A',
            })
            vim.cmd 'norm gcip'
            if ext == string.match(file, '%.([^.]+)$') then
              if callback then
                callback()
              else
                vim.cmd 'norm Go'
                vim.cmd 'norm S'
              end
            end
          end
        end)
      end
    end,
  })
end

function M.del_map(mode, lhs)
  pcall(vim.keymap.del, mode, lhs)
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

function M.ui_sel(items, opts, callback)
  if type(opts) == 'string' then
    opts = { prompt = opts, }
  end
  if items and #items > 0 then
    vim.ui.select(items, opts, callback)
  end
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
  if not file then
    file = M.buf_get_name()
  end
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

function M.touch(file)
  local file_path = M.new_file(file)
  if not file_path:exists() then
    file_path:touch()
  end
end

function M.mkdir(dir)
  local dir_path = M.new_file(dir)
  if not dir_path:exists() then
    dir_path:mkdir()
  end
end

function M.getcreate_file(dirs, file)
  return M.getcreate_filepath(dirs, file).filename
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
    M.stack_item_uniq(dirs, name)
    if not string.match(name, '\\') then
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

function M.get_file_git_root(file)
  return M.get_file_dirs_till_git(file)[1]
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
    local file = M.rep(entry)
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

function M.scan_files(dir, opt)
  if not dir then dir = vim.loop.cwd() end
  local entries = require 'plenary.scandir'.scan_dir(dir, { hidden = true, depth = 1, add_dirs = false, })
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

function M.uniq_sort(tbl)
  local temp = {}
  for _, i in ipairs(tbl) do
    M.stack_item_uniq(temp, i)
  end
  table.sort(temp)
  return temp
end

function M.expand_cfile()
  local cfile = vim.split(vim.fn.expand '<cfile>', '=')
  return cfile[#cfile]
end

function M.get_cfile(cfile)
  local temp
  if not cfile then
    temp = M.normpath(M.format('%s\\%s', vim.fn.expand '%:p:h', M.expand_cfile()))
    if M.is(temp) and M.is_file(temp) then
      return temp
    else
      temp = M.normpath(M.format('%s\\%s', vim.fn.expand '%:p:h', string.match(vim.fn.getline '.', '`([^`]+)`')))
      if M.is(temp) and M.is_file(temp) then
        return temp
      end
    end
    temp = M.normpath(M.format('%s\\%s', vim.loop.cwd(), M.expand_cfile))
    if M.is(temp) and M.is_file(temp) then
      return temp
    else
      temp = M.normpath(M.format('%s\\%s', vim.loop.cwd(), string.match(vim.fn.getline '.', '`([^`]+)`')))
      if M.is(temp) and M.is_file(temp) then
        return temp
      end
    end
    temp = M.normpath(M.format('%s\\%s', vim.fn.expand '%:p:h', M.expand_cfile()))
    if M.is(temp) and M.is_dir(temp) then
      return temp
    else
      temp = M.normpath(M.format('%s\\%s', vim.fn.expand '%:p:h', string.match(vim.fn.getline '.', '`([^`]+)`')))
      if M.is(temp) and M.is_dir(temp) then
        return temp
      end
    end
    temp = M.normpath(M.format('%s\\%s', vim.loop.cwd(), M.expand_cfile))
    if M.is(temp) and M.is_dir(temp) then
      return temp
    else
      temp = M.normpath(M.format('%s\\%s', vim.loop.cwd(), string.match(vim.fn.getline '.', '`([^`]+)`')))
      if M.is(temp) and M.is_dir(temp) then
        return temp
      end
    end
  end
  local tt = string.match(vim.fn.getline '.', '`([^:]+:[^`]+)`')
  if tt then
    local repo, relpath = unpack(vim.split(tt, ':'))
    for _, path in ipairs(M.get_path_dir()) do
      if M.is_dir(path .. '/' .. repo) then
        return path .. '/' .. repo .. '/' .. relpath
      end
    end
  end
  local norg_path = string.match(vim.fn.getline '.', '{:([^:]+):}%[[^%]]+%]')
  if norg_path then
    temp = M.normpath(M.format('%s\\%s', vim.fn.expand '%:p:h', norg_path))
    if M.is(temp) and M.is_file(temp) then
      return temp
    end
    temp = M.normpath(M.format('%s\\%s', vim.loop.cwd(), norg_path))
    if M.is(temp) and M.is_file(temp) then
      return temp
    end
  end
  norg_path = string.match(vim.fn.getline '.', '{/ ([^}]+)}')
  if norg_path then
    temp = M.normpath(M.format('%s\\%s', vim.fn.expand '%:p:h', norg_path))
    if M.is(temp) and M.is_file(temp) then
      return temp
    end
    temp = M.normpath(M.format('%s\\%s', vim.loop.cwd(), norg_path))
    if M.is(temp) and M.is_file(temp) then
      return temp
    end
  end
  temp = M.normpath(M.format('%s\\%s', vim.fn.expand '%:p:h', cfile))
  if M.is(temp) and M.is_dir(temp) then
    return temp
  end
  return M.normpath(M.format('%s\\%s', vim.loop.cwd(), cfile))
end

function M.jump_or_split(file)
  file = M.rep(file)
  local file_proj = M.get_proj_root(file)
  local jumped = nil
  for winnr = vim.fn.winnr '$', 1, -1 do
    local bufnr = vim.fn.winbufnr(winnr)
    local fname = M.rep(vim.api.nvim_buf_get_name(bufnr))
    if M.file_exists(fname) then
      if file == fname then
        vim.fn.win_gotoid(vim.fn.win_getid(winnr))
        jumped = 1
        break
      end
    end
  end
  if not jumped then
    for winnr = vim.fn.winnr '$', 1, -1 do
      local bufnr = vim.fn.winbufnr(winnr)
      local fname = M.rep(vim.api.nvim_buf_get_name(bufnr))
      if M.file_exists(fname) then
        local proj = M.get_proj_root(fname)
        if not M.is(file_proj) or M.is(proj) and file_proj == proj then
          vim.fn.win_gotoid(vim.fn.win_getid(winnr))
          jumped = 1
          break
        end
      end
    end
  end
  if not jumped then
    vim.cmd 'wincmd s'
  end
  M.cmd('e %s', file)
end

function M.wingoto_file_or_open(file)
  local winnr = vim.fn.bufwinnr(vim.fn.bufnr(file))
  if winnr ~= -1 then
    vim.fn.win_gotoid(vim.fn.win_getid(winnr))
    return 1
  end
  vim.cmd 'wincmd s'
  M.cmd('e %s', file)
  return nil
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

function M.get_fname_short(fname)
  local temp__ = vim.fn.tolower(vim.fn.fnamemodify(fname, ':t'))
  if #temp__ >= 17 then
    local s1 = ''
    local s2 = ''
    for i = 17, 3, -1 do
      s2 = string.sub(temp__, #temp__ - i, #temp__)
      if vim.fn.strdisplaywidth(s2) <= 8 then
        break
      end
    end
    for i = 17, 3, -1 do
      s1 = string.sub(temp__, 1, i)
      if vim.fn.strdisplaywidth(s1) <= 8 then
        break
      end
    end
    return s1 .. '…' .. s2
  end
  return temp__
end

function M.get_only_name(file)
  file = M.rep(file)
  local only_name = vim.fn.trim(file, '\\')
  if string.match(only_name, '\\') then
    only_name = string.match(only_name, '.+%\\(.+)$')
  end
  return only_name
end

function M.delete_file(file)
  M.system_run('start silent', 'git rm "%s"', file)
  M.system_run('start silent', 'del /f /q "%s"', file)
end

function M.delete_folder(folder)
  M.system_run('start silent', 'rd /s /q "%s"', folder)
end

function M.sel_run(m)
  if not m.lua then
    print 'no M.lua, please check!'
    return
  end
  local functions = {}
  for k, v in pairs(m) do
    if type(v) == 'function' and string.sub(k, 1, 1) ~= '_' then
      functions[#functions + 1] = k
    end
  end
  table.sort(functions)
  M.ui_sel(functions, 'test', function(func)
    if not func then
      return
    end
    pcall(M.cmd, "lua require('%s').%s()", m.lua, func)
  end)
end

function M.system_open_file(str_format, ...)
  M.system_run_histadd('start', str_format, ...)
end

function M.system_open_file_silent(str_format, ...)
  M.system_run_histadd('start silent', str_format, ...)
end

function M.get_head_dir()
  local fname = M.rep(M.buf_get_name())
  if M.is(fname) and M.file_exists(fname) then
    return M.file_parent(fname)
  end
  return vim.loop.cwd()
end

M.source = M.getsource(debug.getinfo(1)['source'])
M.dot_dir = M.get_source_dot_dir(M.source)
M.lua = M.getlua(M.source)
M.copy2clip_exe = M.get_file(M.dot_dir, 'copy2clip.exe')
M.scan_git_repos_py = M.get_file(M.dot_dir, 'scan_git_repos.py')

function M.is_sure(str_format, ...)
  local prompt = string.format(str_format, ...)
  local res = vim.fn.input(string.format('%s ? [Y/n]: ', prompt), 'y')
  if vim.tbl_contains({ 'y', 'Y', 'yes', 'Yes', 'YES', }, res) == false then
    return nil
  end
  return 1
end

function M.get_fname_tail(file)
  file = M.rep(file)
  local fpath = M.new_file(file)
  if fpath:is_file() then
    file = fpath:_split()
    return file[#file]
  elseif fpath:is_dir() then
    file = fpath:_split()
    if #file[#file] > 0 then
      return file[#file]
    else
      return file[#file - 1]
    end
  end
  return ''
end

function M.get_dirpath(dirs)
  dirs = M.totable(dirs)
  local dir1 = table.remove(dirs, 1)
  dir1 = M.rep(dir1)
  local dir_path = M.new_file(dir1)
  for _, dir in ipairs(dirs) do
    if not dir_path:exists() then
      vim.fn.mkdir(dir_path.filename)
    end
    dir_path = dir_path:joinpath(dir)
  end
  return dir_path
end

function M.get_dir(dirs)
  return M.get_dirpath(dirs).filename
end

function M.get_dirs_equal(dname, root_dir, opt)
  if not root_dir then
    root_dir = M.get_proj_root()
  end
  local default_opt = { hidden = false, depth = 32, add_dirs = true, }
  opt = vim.tbl_deep_extend('force', default_opt, opt or {})
  local entries = require 'plenary.scandir'.scan_dir(root_dir, opt)
  local dirs = {}
  for _, entry in ipairs(entries) do
    entry = M.rep(entry)
    if require 'plenary.path':new(entry):is_dir() then
      local name = M.get_only_name(entry)
      if name == dname then
        dirs[#dirs + 1] = entry
      end
    end
  end
  return dirs
end

function M.get_repos_dir()
  return M.get_dirpath { Depei, 'repos', }.filename
end

function M.get_path_dir()
  return M.uniq_sort {
    M.rep(DepeiRepos),
    M.rep(DepeiTemp),
    M.rep(Depei),
    M.rep(Home),
    M.rep(DataSub),
  }
end

function M.get_my_dirs()
  return M.uniq_sort {
    M.rep(DataSub),
    M.rep(DepeiTemp),
    M.rep(Depei),
    M.rep(DepeiRepos),
    M.rep(vim.fn.expand [[$HOME]]),
    M.rep(vim.fn.expand [[$TEMP]]),
    M.rep(vim.fn.expand [[$LOCALAPPDATA]]),
    M.rep(vim.fn.stdpath 'config'),
    M.rep(vim.fn.stdpath 'data'),
    M.rep(vim.fn.expand [[$VIMRUNTIME]]),
  }
end

function M.get_drivers()
  local drivers = {}
  for i = 1, 26 do
    local driver = vim.fn.nr2char(64 + i) .. ':\\'
    if M.is(vim.fn.isdirectory(driver)) then
      drivers[#drivers + 1] = driver
    end
  end
  return M.uniq_sort(drivers)
end

function M.get_SHGetFolderPath(name)
  local exe_name = 'SHGetFolderPath'
  M.get_source_dot_dir(M.source)
  local SHGetFolderPath_without_ext = M.get_file(M.dot_dir, exe_name)
  local SHGetFolderPath_exe = SHGetFolderPath_without_ext .. '.exe'
  if not M.is(vim.fn.filereadable(SHGetFolderPath_exe)) then
    M.system_run('start silent', '%s && gcc %s.c -Wall -s -ffunction-sections -fdata-sections -Wl,--gc-sections -O2 -o %s.exe', M.system_cd(SHGetFolderPath_without_ext), exe_name, exe_name)
    M.notify_info 'exe creating, try again later...'
    return {}
  end
  local f = io.popen(SHGetFolderPath_exe .. ' ' .. (name and name or ''))
  if f then
    local dirs = {}
    for dir in string.gmatch(f:read '*a', '([%S ]+)') do
      dir = M.rep(dir)
      if not M.is_in_tbl(dir, dirs) then
        dirs[#dirs + 1] = dir
      end
    end
    f:close()
    table.sort(dirs)
    return dirs
  end
  return {}
end

function M.read_table_from_file(file)
  if not file then
    return {}
  end
  file = M.new_file(file)
  if not file:exists() then
    return {}
  end
  local res = file:read()
  if #res > 0 then
    res = loadstring('return ' .. res)()
    if res then
      return res
    end
  end
  return {}
end

function M.write_table_to_file(file, tbl)
  M.new_file(file):write(vim.inspect(tbl), 'w')
end

function M.scan_dirs(dir, pattern)
  if not dir then
    dir = vim.loop.cwd()
  end
  local entries = require 'plenary.scandir'.scan_dir(dir, { hidden = false, depth = 64, add_dirs = true, })
  local dirs = {}
  for _, entry in ipairs(entries) do
    if M.is(M.new_file(entry):is_dir()) and (not pattern or string.match(entry, pattern)) then
      dirs[#dirs + 1] = entry
    end
  end
  return dirs
end

function M.get_dirs_named_with_till_git(name)
  local git_root = M.get_file_git_root()
  local dirs = M.scan_dirs(git_root)
  table.insert(dirs, 1, git_root)
  local new_dirs = {}
  for _, dir in ipairs(dirs) do
    if M.is(M.new_file(dir):joinpath(name):is_dir()) then
      new_dirs[#new_dirs + 1] = dir
    end
  end
  return new_dirs
end

function M.win_max_height()
  local cur_winnr = vim.fn.winnr()
  local cur_wininfo = vim.fn.getwininfo(vim.fn.win_getid())[1]
  local cur_start_col = cur_wininfo['wincol']
  local cur_end_col = cur_start_col + cur_wininfo['width']
  local winids = {}
  local winids_dict = {}
  for winnr = 1, vim.fn.winnr '$' do
    local wininfo = vim.fn.getwininfo(vim.fn.win_getid(winnr))[1]
    local start_col = wininfo['wincol']
    local end_col = start_col + wininfo['width']
    if start_col > cur_end_col or end_col < cur_start_col then
    else
      local winid = vim.fn.win_getid(winnr)
      if winnr ~= cur_winnr and vim.api.nvim_win_get_option(winid, 'winfixheight') == true then
        winids[#winids + 1] = winid
        winids_dict[winid] = wininfo['height']
      end
    end
  end
  vim.cmd 'wincmd _'
  for _, winid in ipairs(winids) do
    vim.api.nvim_win_set_height(winid, winids_dict[winid] + (#vim.o.winbar > 0 and 1 or 0))
  end
end

function M.win_max_width()
  local cur_winnr = vim.fn.winnr()
  local winids = {}
  local winids_dict = {}
  for winnr = 1, vim.fn.winnr '$' do
    local wininfo = vim.fn.getwininfo(vim.fn.win_getid(winnr))[1]
    local winid = vim.fn.win_getid(winnr)
    if winnr ~= cur_winnr and vim.api.nvim_win_get_option(winid, 'winfixwidth') == true then
      winids[#winids + 1] = winid
      winids_dict[winid] = wininfo['width']
    end
  end
  vim.cmd 'wincmd |'
  for _, winid in ipairs(winids) do
    vim.api.nvim_win_set_width(winid, winids_dict[winid])
  end
end

function M.win_max_width_height()
  M.win_max_width()
  M.win_max_height()
end

function M.b(m, desc)
  local temp = vim.fn.join(vim.fn.split(desc, '_'))
  if m.lua then
    return m.lua .. ': ' .. temp
  end
  return temp
end

function M.l(var, val)
  if not var then
    var = val
  end
end

function M.is_tbl_equal(tbl1, tbl2)
  if #tbl1 ~= #tbl2 then
    return nil
  end
  table.sort(tbl1)
  table.sort(tbl2)
  for i = 1, #tbl1 do
    if tbl1[i] ~= tbl2[i] then
      return nil
    end
  end
  return 1
end

function M.get_path_dirs()
  local temp = vim.split(vim.fn.getenv 'path', ';')
  local dirs = {}
  for _, i in ipairs(temp) do
    M.stack_item_uniq(dirs, i)
  end
  return dirs
end

vim.on_key(function(c)
  if M.yanking then
    return
  end
  if #M.temp_maps == 0 then
    return
  end
  local temp = {}
  for i in string.gmatch(c, '.') do
    temp[#temp + 1] = string.byte(i, 1)
  end
  if #temp ~= 1 then
    return
  end
  for _, val in ipairs(M.temp_maps) do
    if temp[1] == vim.fn.char2nr(val[1]) then
      return
    end
  end
  if not M.is_in_tbl(c, M.chars) then
    return
  end
  if M.is_in_tbl(c, M.exclude_chars) then
    return
  end
  for _, val in ipairs(M.temp_maps) do
    M.set_timeout(100, function()
      M.del_map(val['mode'], val[1])
    end)
  end
  temp = { 'canceled:' .. c, }
  for _, i in ipairs(M.temp_maps) do
    temp[#temp + 1] = string.format('[%s] %s', i[1], i['desc'])
  end
  -- M.notify_info(temp, 1000 * 60 * 60 * 24)
  M.temp_maps = {}
end)

function M.temp_map(tbl, exclude_chars)
  if not M.is(tbl) then
    return
  end
  M.temp_maps = vim.deepcopy(tbl)
  M.exclude_chars = vim.deepcopy(M.totable(exclude_chars))
  local temp = { 'ready:', }
  for _, i in ipairs(M.temp_maps) do
    temp[#temp + 1] = string.format('[%s] %s', i[1], i['desc'])
  end
  -- M.notify_info(temp, 1000 * 60 * 60 * 24)
  M.lazy_map(vim.tbl_values(tbl))
  return temp
end

--[[
   [ vim.on_key(function(c)
   [   local temp = {}
   [   for i in string.gmatch(c, '.') do
   [     temp[#temp + 1] = string.byte(i, 1)
   [   end
   [   if #temp > 1 or #temp == 0 then
   [     return
   [   end
   [   vim.fn.writefile({ vim.inspect(temp), c }, 'C:\\c.txt', 'a')
   [ end)
   [
   [ function M.hh()
   [   require 'dp_tabline'.b_prev_buf()
   [ end
   [
   [ function M.ll()
   [   require 'dp_tabline'.b_next_buf()
   [ end
   [
   [ function M.test()
   [   M.temp_map {
   [     { 'l', function() M.ll() end, mode = { 'n', 'v', }, silent = true, desc = 'nvim.treesitter: go_to_context', },
   [     { 'h', function() M.hh() end, mode = { 'n', 'v', }, silent = true, desc = 'nvim.treesitter: go_to_context', },
   [   }
   [ end
   [
   [ M.lazy_map {
   [   { '<c-f11>', function() M.test() end, mode = { 'n', 'v', }, silent = true, desc = 'test', },
   [ }
   ]]

function M.get_all_git_repos(force)
  local all_git_repos_txt = M.getcreate_file(DataSub, 'all_git_repos.txt')
  local repos = vim.fn.readfile(all_git_repos_txt)
  if #repos == 0 or force then
    M.system_run('start', 'chcp 65001 && python "%s" "%s"', M.scan_git_repos_py, all_git_repos_txt)
    M.notify_info 'scan_git_repos, try again later.'
    return nil
  end
  return repos
end

function M.getcreate_temp_dirpath(dirs)
  dirs = M.totable(dirs)
  table.insert(dirs, 1, DepeiTemp)
  return M.getcreate_dirpath(dirs)
end

function M.getcreate_temp_dir(dirs)
  return M.getcreate_temp_dirpath(dirs).filename
end

function M.getcreate_temp_file(dirs, file)
  return M.get_file(M.getcreate_temp_dir(dirs), file)
end

function M.count_char(str, char)
  local count = 0
  for i = 1, #str do
    if str:sub(i, i) == char then
      count = count + 1
    end
  end
  return count
end

function M.get_hash(file)
  return require 'sha2'.sha256(require 'plenary.path':new(file):_read())
end

function M.jump_or_edit(file)
  file = M.rep(file)
  local file_proj = M.get_proj_root(file)
  for winnr = vim.fn.winnr '$', 1, -1 do
    local bufnr = vim.fn.winbufnr(winnr)
    local fname = M.rep(vim.api.nvim_buf_get_name(bufnr))
    if M.file_exists(fname) then
      if file == fname then
        vim.fn.win_gotoid(vim.fn.win_getid(winnr))
        M.cmd('e %s', file)
        return
      end
    end
  end
  for winnr = vim.fn.winnr '$', 1, -1 do
    local bufnr = vim.fn.winbufnr(winnr)
    local fname = M.rep(vim.api.nvim_buf_get_name(bufnr))
    if M.file_exists(fname) then
      local proj = M.get_proj_root(fname)
      if not M.is(file_proj) or M.is(proj) and file_proj == proj then
        vim.fn.win_gotoid(vim.fn.win_getid(winnr))
        M.cmd('e %s', file)
        return
      end
    end
  end
  M.cmd('e %s', file)
end

local function callback_rhs(lhs, mode)
  for _, v in ipairs(vim.api.nvim_get_keymap(mode)) do
    if vim.fn.tolower(v.lhs) == vim.fn.tolower(lhs) then
      local callback = nil
      local rhs = nil
      if v.callback then
        callback = v.callback
      elseif v.rhs then
        rhs = v.rhs
      end
      return { callback, rhs, v.desc, }
    end
  end
  return nil
end

local function old_callback(rhs)
  if rhs[1] then
    return function()
      rhs[1]()
    end
  elseif rhs[2] then
    return function()
      local r = string.gsub(rhs[2], '<Cmd>', ':')
      r = string.gsub(r, '\\', '')
      r = string.gsub(r, '<', '\\<')
      r = string.gsub(r, '^:', ':\\<C-u>')
      vim.cmd(string.format([[call feedkeys("%s")]], r))
    end
  else
    return function() end
  end
end

function M.map_add(lhs, mode, new, desc)
  local rhs = callback_rhs(lhs, mode)
  if rhs and M.is_in_str(desc, rhs[3]) then
    return
  end
  local old = old_callback(rhs)
  vim.keymap.set({ mode, }, lhs, function()
    old()
    new()
  end, { desc = (rhs and rhs[3] and #rhs[3] > 0) and rhs[3] .. ' & ' .. desc or desc, })
end

-- M.map_add('qq', 'n', function()
--   print('test')
-- end, 'test')

function M.cmd_escape(text)
  -- text = string.gsub(text, '%^', '^^')
  text = string.gsub(text, '>', '^>')
  text = string.gsub(text, '<', '^<')
  text = string.gsub(text, '&', '^&')
  text = string.gsub(text, '|', '^|')
  return text
end

M.aescrypt_exe = M.get_file(M.dot_dir, 'aescrypt.exe')

M._7z_exe = M.get_file(M.dot_dir, '7z.exe')

-- [x] TODODONE: https://sourceforge.net/projects/sevenzip/加解密套个解压缩
--
-- 先压缩再加密,格式为7z
-- 先解密再解压
-- 密码不区分大小写
--
-- [ ] TODO: xxxx.yy -> xxxx_yy.bin -> xxxx.yy
-- [x] TODODONE: xxxx_yy.bin --encrypt--> not working

function M.encrypt_do(ifile, ofile, pass)
  vim.g.encrypted = nil
  vim.g.ifile = ifile
  vim.cmd [[
    python << EOF
import vim
ifile = vim.eval('g:ifile')
with open(ifile, 'rb') as f:
  l = f.readlines()[0]
if l[:3] == b'AES' and b'aescrypt 3.10' in l and b'CREATED_BY' in l:
  vim.command('let g:encrypted = 1')
EOF
]]
  if vim.g.encrypted then
    M.notify_info_append 'already encrypted!'
    return
  end
  vim.fn.system(string.format('%s a %s.7z %s', M._7z_exe, ifile, ifile))
  vim.fn.system(string.format('%s -e -p %s -o %s %s.7z', M.aescrypt_exe, pass, ofile, ifile))
  if M.file_exists(ofile) then
    M.cmd('Bdelete %s', ifile)
    M.system_run('start silent', [[del /s /q %s]], M.rep(ifile))
    require 'nvim-tree.api'.tree.reload()
    M.jump_or_edit(ofile)
  end
  M.system_run('start silent', [[del /s /q %s.7z]], M.rep(ifile))
end

function M.encrypt(ifile, ofile, pass)
  if not ifile then
    ifile = M.buf_get_name()
  end
  if not M.is_file(ifile) then
    return
  end
  if not ofile then
    ofile = vim.fn.fnamemodify(ifile, ':p') .. '.bin'
  end
  if not M.is(pass) then
    pass = vim.fn.fnamemodify(ifile, ':p:t')
  end
  pass = vim.fn.tolower(pass)
  M.encrypt_do(ifile, ofile, pass)
end

function M.encrypt_secret(ifile, ofile)
  if not ifile then
    ifile = M.buf_get_name()
  end
  if not ofile then
    ofile = vim.fn.fnamemodify(ifile, ':p') .. '.bin'
  end
  local pass = vim.fn.inputsecret '> '
  if not M.is(pass) then
    pass = vim.fn.fnamemodify(ifile, ':p:t')
  end
  pass = vim.fn.tolower(pass)
  M.encrypt_do(ifile, ofile, pass)
end

function M.decrypt_do(ifile, ofile, pass)
  vim.fn.system(string.format('%s -d -p %s -o %s.7z %s', M.aescrypt_exe, pass, ofile, ifile))
  vim.fn.system(string.format('%s && %s e %s.7z', M.system_cd(ofile), M._7z_exe, ofile))
  if M.file_exists(ofile) then
    M.cmd('Bdelete %s', ifile)
    M.jump_or_edit(ofile)
    M.system_run('start silent', [[del /s /q %s]], M.rep(ifile))
    require 'nvim-tree.api'.tree.reload()
  else
    M.notify_error_append 'maybe password is incorrect'
  end
  M.system_run('start silent', [[del /s /q %s.7z]], M.rep(ofile))
end

function M.decrypt(ifile, ofile, pass)
  if not ifile then
    ifile = M.buf_get_name()
  end
  if not M.is_file(ifile) then
    return
  end
  if not ofile then
    ofile = vim.fn.fnamemodify(ifile, ':p:r')
  end
  if not M.is(pass) then
    pass = vim.fn.fnamemodify(ifile, ':p:t:r')
  end
  pass = vim.fn.tolower(pass)
  M.decrypt_do(ifile, ofile, pass)
end

function M.decrypt_secret(ifile, ofile)
  if not ifile then
    ifile = M.buf_get_name()
  end
  if not ofile then
    ofile = vim.fn.fnamemodify(ifile, ':p:r')
  end
  local pass = vim.fn.inputsecret '> '
  if not M.is(pass) then
    pass = vim.fn.fnamemodify(ifile, ':p:t:r')
  end
  pass = vim.fn.tolower(pass)
  M.decrypt_do(ifile, ofile, pass)
end

function M.get_telescope_cur_root()
  return M.read_table_from_file(TelecopeCurRootTxt)
end

function M.get_telescope_cur_roots()
  return M.read_table_from_file(TelecopeCurRootsTxt)
end

function M.get_rel_path()
  local cfile = M.expand_cfile()
  local line = ''
  if M.is_file(cfile) then
    line = M.relpath(cfile, vim.fn.fnamemodify(M.buf_get_name(), ':p:h'))
  else
    line = M.relpath(cfile, M.buf_get_name())
  end
  vim.fn.append('.', line)
end

function M.filter_exclude(tbl, patterns)
  return vim.tbl_filter(function(str)
    if M.match_string_or(str, patterns) then
      return false
    end
    return true
  end, tbl)
end

function M.get_programs_files()
  local all_programs = M.get_SHGetFolderPath 'all_programs'
  if M.is(all_programs) then
    local files = {}
    for _, programs in ipairs(all_programs) do
      local a = M.scan_files_deep(programs, { filetypes = { 'lnk', }, })
      a = M.filter_exclude(a, { '卸载', 'uninst', 'Uninst', })
      files = M.merge_tables(files, a)
    end
    return files
  end
  return {}
end

function M.get_path_files()
  local files = {}
  for programs in string.gmatch(vim.fn.system 'echo %path%', '([^;]+);') do
    local a = M.scan_files_deep(programs, { filetypes = { 'lnk', }, })
    a = M.filter_exclude(a, { '卸载', 'uninst', 'Uninst', })
    files = M.merge_tables(files, a)
  end
  return files
end

function M.get_running_executables()
  local exes = {}
  for exe in string.gmatch(vim.fn.system 'tasklist', '([^\n]+.exe)') do
    exe = vim.fn.tolower(exe)
    if not M.is_in_tbl(exe, exes) then
      exes[#exes + 1] = exe
    end
  end
  return exes
end

function M.get_startup_files()
  local all_startup = M.get_SHGetFolderPath 'all_startup'
  if M.is(all_startup) then
    local files = {}
    for _, start_up in ipairs(all_startup) do
      local a = M.scan_files_deep(start_up, { filetypes = { 'lnk', }, })
      files = M.merge_tables(files, a)
    end
    return files
  end
  return {}
end

function M.get_paragraph(lnr)
  local paragraph = {}
  if not lnr then
    lnr = '.'
  end
  local linenr = vim.fn.line(lnr)
  local lines = 0
  for i = linenr, 1, -1 do
    local line = vim.fn.getline(i)
    if #line > 0 then
      lines = lines + 1
      table.insert(paragraph, 1, line)
    else
      M.markdowntable_line = i + 1
      break
    end
  end
  for i = linenr + 1, vim.fn.line '$' do
    local line = vim.fn.getline(i)
    if #line > 0 then
      table.insert(paragraph, line)
      lines = lines + 1
    else
      break
    end
  end
  return paragraph
end

function M.not_allow_in_file_name(text)
  return string.match(vim.fn.fnamemodify(text, ':t:r'), '[~\\/:%*%?"<>|]')
end

function M.find_dir_till_git(cur_filetypes, search_files, cur_file)
  if not cur_file then
    cur_file = M.buf_get_name()
  end
  if not M.is_file_in_filetypes(cur_file, cur_filetypes) then
    return
  end
  for _, dir in ipairs(M.get_file_dirs_till_git(cur_file)) do
    for _, file in ipairs(search_files) do
      file = M.get_file(dir, file)
      if M.file_exists(file) then
        return dir
      end
    end
  end
end

function M.get_char_index_of_arr(byte_index, arr)
  vim.g.arr = arr
  vim.g.byte_index = byte_index
  vim.g.char_index = 0
  vim.cmd [[
    python << EOF
byte_index = int(vim.eval('g:byte_index'))
arr = vim.eval('g:arr')
cnt = 0
for i in range(1, len(arr) + 1):
  s = arr[i-1]
  cnt += len(s.encode('utf-8'))
  if cnt >= byte_index:
    vim.command(f'let g:char_index = {i}')
    break
EOF
  ]]
  return vim.g.char_index
end

function M.string_split_char_to_table(str)
  vim.g.str = str
  vim.g.arr = {}
  vim.cmd [[
    python << EOF
str = vim.eval('g:str')
vim.command(f'let g:arr = {list(str)}')
EOF
  ]]
  return vim.g.arr
  -- NOTE: 以下两种方式是按字符去分割，不是我想要的
  --
  -- return vim.split(str, '')
  -- local arr = {}
  -- for s in string.gmatch(str, '.') do
  --   arr[#arr+1] = s
  -- end
  -- return arr
end

function M.get_text_in_bracket(text)
  return string.match(text, '%[([^%]]+)%]')
end

function M.delele_patt_under_dir(patt, dir)
  vim.g.patt = patt
  vim.g.dir = dir
  vim.cmd [[
  python << EOF
import os
import vim
import shutil
import re
dir = vim.eval('g:dir')
if os.path.isdir(dir):
  patt = re.compile(vim.eval('g:patt'))
  F = []
  for f in os.listdir(dir):
    if re.findall(patt, f):
      F.append(os.path.join(dir, f))
  for f in F:
    if os.path.isdir(f):
      shutil.rmtree(f)
    else:
      try:
        os.remove(f)
      except Exception as e:
        pass
EOF
  ]]
end

function M.system_cd(file)
  local fpath = M.new_file(file)
  if fpath:is_dir() then
    return 'cd /d ' .. file
  else
    return 'cd /d ' .. fpath:parent().filename
  end
end

function M.write_lines_to_file(lines, file)
  M.new_file(file):write(vim.fn.join(lines, '\n'), 'w')
end

M.done_default = dp_asyncrun.done_default
M.done_append_default = dp_asyncrun.done_append_default
M.done_replace_default = dp_asyncrun.done_replace_default

function M.system_run(way, str_format, ...)
  if type(str_format) == 'table' then
    str_format = vim.fn.join(str_format, ' && ')
  end
  local cmd = string.format(str_format, ...)
  if way == 'start' then
    M.cmd([[silent !start cmd /c "%s"]], cmd)
  elseif way == 'start silent' then
    M.cmd([[silent !start /b /min cmd /c "%s"]], cmd)
  elseif way == 'asyncrun' then
    vim.cmd 'AsyncStop'
    cmd = string.format('AsyncRun %s', cmd)
    if vim.g.asyncrun_status == 'running' then
      M.timer_temp = vim.fn.timer_start(10, function()
        if vim.g.asyncrun_status ~= 'running' then
          pcall(vim.fn.timer_stop, M.timer_temp)
          M.done_default()
          vim.cmd(cmd)
        end
      end, { ['repeat'] = -1, })
    else
      vim.cmd(cmd)
      M.done_default()
    end
  elseif way == 'term' then
    cmd = string.format('wincmd s|term %s', cmd)
    vim.cmd(cmd)
  else
    return
  end
  return cmd
end

function M.system_run_histadd(way, str_format, ...)
  local cmd = M.system_run(way, str_format, ...)
  if cmd then
    vim.fn.histadd(':', cmd)
  end
end

function M.cmd_histadd(str_format, ...)
  local cmd = M.cmd(str_format, ...)
  if cmd then
    vim.fn.histadd(':', cmd)
  end
end

function M.format(str_format, ...)
  return string.format(str_format, ...)
end

function M.get_proj_root(file)
  if file then
    return M.rep(vim.fn['ProjectRootGet'](file))
  end
  return M.rep(vim.fn['ProjectRootGet']())
end

function M.cmd(str_format, ...)
  local cmd = string.format(str_format, ...)
  local _sta, _ = pcall(vim.cmd, cmd)
  if _sta then
    return cmd
  end
  return nil
end

function M.powershell_run(cmd)
  vim.g.powershell_run_cmd = cmd
  vim.g.powershell_run_out = nil
  vim.cmd [[
  python << EOF
import vim
import subprocess
cmd = vim.eval('g:powershell_run_cmd')
process = subprocess.Popen(["powershell", cmd],stdout=subprocess.PIPE, stderr = subprocess.PIPE)
out = process.communicate()
res = []
for o in out:
  o = o.replace(b'\r', b'')
  try:
    o = o.decode('utf-8')
  except:
    try:
      o = o.decode('gbk')
    except:
      o = '-error-'
  res.append(o.split('\n'))
vim.command(f"""let g:powershell_run_out = {res}""")
EOF
]]
  return vim.g.powershell_run_out
end

return M
