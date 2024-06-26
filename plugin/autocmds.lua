if vim.g.no_plugin ~= false then
  local function augroup(name) return vim.api.nvim_create_augroup("mynvim_" .. name, { clear = true }) end

  -- Check if we need to reload the file when it changed
  vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    group = augroup "checktime",
    callback = function()
      if vim.o.buftype ~= "nofile" then vim.cmd "checktime" end
    end,
  })

  -- Highlight on yank
  vim.api.nvim_create_autocmd("TextYankPost", {
    group = augroup "highlight_yank",
    callback = function() vim.highlight.on_yank() end,
  })

  -- resize splits if window got resized
  vim.api.nvim_create_autocmd({ "VimResized" }, {
    group = augroup "resize_splits",
    callback = function()
      local current_tab = vim.fn.tabpagenr()
      vim.cmd "tabdo wincmd ="
      vim.cmd("tabnext " .. current_tab)
    end,
  })

  -- go to last loc when opening a buffer
  vim.api.nvim_create_autocmd("BufReadPost", {
    group = augroup "last_loc",
    callback = function(event)
      local exclude = { "gitcommit" }
      local buf = event.buf
      if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].mynvim_last_loc then return end
      vim.b[buf].mynvim_last_loc = true
      local mark = vim.api.nvim_buf_get_mark(buf, '"')
      local lcount = vim.api.nvim_buf_line_count(buf)
      if mark[1] > 0 and mark[1] <= lcount then pcall(vim.api.nvim_win_set_cursor, 0, mark) end
    end,
  })

  -- make it easier to close man-files when opened inline
  vim.api.nvim_create_autocmd("FileType", {
    group = augroup "man_unlisted",
    pattern = { "man" },
    callback = function(event) vim.bo[event.buf].buflisted = false end,
  })

  -- wrap and check for spell in text filetypes
  vim.api.nvim_create_autocmd("FileType", {
    group = augroup "wrap_spell",
    pattern = { "gitcommit", "markdown" },
    callback = function()
      vim.opt_local.wrap = true
      vim.opt_local.spell = true
    end,
  })
end
