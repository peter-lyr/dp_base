local M = {}

local common = require 'dp_base.common'

common.merge_other_functions(M, {
  common,
})

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

return M
