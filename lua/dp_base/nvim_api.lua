-- Copyright (c) 2024 liudepei. All Rights Reserved.
-- create at 2024/04/08 11:29:55 Monday

local M = {}

local common = require 'dp_base.common'

common.merge_other_functions(M, {
  common,
})

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

return M
