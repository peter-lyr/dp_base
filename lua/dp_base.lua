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
  'dbakker/vim-projectroot',
}

local dp_asyncrun = require 'dp_asyncrun'

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

function M.notify_info(message)
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
    timeout = 1000 * 8,
  })
end

function M.notify_info_append(message)
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
    timeout = 1000 * 8,
  })
end

function M.notify_error(message)
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
    timeout = 1000 * 8,
  })
end

function M.notify_error_append(message)
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
    timeout = 1000 * 8,
  })
end

function M.get_short(content, max)
  if not max then
    max = vim.fn.floor(vim.o.columns * 2 / 5)
  end
  if #content >= (max * 2 - 1) then
    local s1 = ''
    local s2 = ''
    for i = (max * 2 - 1), 3, -1 do
      s2 = string.sub(content, #content - i, #content)
      if vim.fn.strdisplaywidth(s2) <= max then
        break
      end
    end
    for i = (max * 2 - 1), 3, -1 do
      s1 = string.sub(content, 1, i)
      if vim.fn.strdisplaywidth(s1) <= max then
        break
      end
    end
    return s1 .. '…' .. s2
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
    vim.cmd "silent norm yi'"
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
  os.sytem('pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --trusted-host mirrors.aliyun.com luadata')
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
  vim.cmd(cmd)
  return cmd
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

function M.copyright(ext, callback)
  M.aucmd({ 'BufReadPre', }, ext .. '.BufReadPre', {
    callback = function(ev)
      local file = vim.api.nvim_buf_get_name(ev.buf)
      if vim.fn.getfsize(file) == 0 then
        M.set_timeout(10, function()
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

function M.get_repos_dir()
  return M.get_dirpath { M.file_parent(Nvim), 'repos', }.filename
end

function M.get_my_dirs()
  return {
    M.rep(DataSub),
    M.rep(Depei),
    M.get_repos_dir(),
    M.rep(vim.fn.expand [[$HOME]]),
    M.rep(vim.fn.expand [[$TEMP]]),
    M.rep(vim.fn.expand [[$LOCALAPPDATA]]),
    M.rep(vim.fn.stdpath 'config'),
    M.rep(vim.fn.stdpath 'data'),
    M.rep(vim.fn.expand [[$VIMRUNTIME]]),
  }
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
  for _, val in ipairs(M.temp_maps) do
    M.set_timeout(100, function()
      M.del_map(val['mode'], val[1])
    end)
  end
  temp = {}
  for _, i in ipairs(M.temp_maps) do
    temp[i[1]] = i['desc']
  end
  M.notify_info('canceled: ' .. vim.inspect(temp))
  M.temp_maps = {}
end)

function M.temp_map(tbl)
  if not M.is(tbl) then
    return
  end
  M.temp_maps = vim.deepcopy(tbl)
  local temp = {}
  for _, i in ipairs(M.temp_maps) do
    temp[i[1]] = i['desc']
  end
  M.notify_info('ready: ' .. vim.inspect(temp))
  M.lazy_map(vim.tbl_values(tbl))
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

return M
