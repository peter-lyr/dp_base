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

function M.stack_item_uniq(tbl, item)
  if M.is(tbl) then
    local index = M.index_of(tbl, item)
    if index ~= -1 then
      table.remove(tbl, index)
    end
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
  return string.format('%s\\%s.%s', root, tail, ext)
end

function M.setreg()
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

function M.get_functions_of_m(m)
  if not m.lua then
    print('no M.lua, please check!')
    return
  end
  print("vim.inspect(m):", vim.inspect(m))
  print("m.lua:", m.lua)
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
    pcall(M.print, "lua require('%s').%s()", m.lua, func)
  end)
end

return M
