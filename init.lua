-- Clone 'mini.nvim' manually in a way that it gets managed by 'mini.deps'
local path_package = vim.fn.stdpath('data') .. '/site/'
local mini_path = path_package .. 'pack/deps/start/mini.nvim'
if not vim.uv.fs_stat(mini_path) then
  vim.cmd('echo "Installing `mini.nvim`" | redraw')
  local clone_cmd = {
    'git', 'clone', '--filter=blob:none',
    'https://github.com/echasnovski/mini.nvim', mini_path
  }
  vim.fn.system(clone_cmd)
  vim.cmd('packadd mini.nvim | helptags ALL')
  vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

-- Set up 'mini.deps' (customize to your liking)
require('mini.deps').setup({ path = { package = path_package } })
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

-- Basic Neovim settings
vim.o.ambiwidth = 'single'
vim.o.autochdir = false
vim.o.autoindent = true
vim.o.conceallevel = 0
vim.o.encoding = 'utf-8'
vim.o.expandtab = true
vim.o.foldlevel = 1
vim.o.hlsearch = true
vim.o.ignorecase = true
vim.o.incsearch = true
vim.o.matchtime = 1
vim.o.modeline = true
vim.o.number = true
vim.o.relativenumber = false
vim.o.shiftwidth = 2
vim.o.showmatch = true
vim.o.signcolumn = 'yes'
vim.o.smartcase = true
vim.o.smartindent = true
vim.o.softtabstop = 2
vim.o.tabstop = 2
vim.o.termguicolors = true
vim.o.undodir = vim.fn.stdpath('cache') .. '/undo'
vim.o.undofile = true
vim.o.updatetime = 250
vim.o.visualbell = true
vim.o.wrap = true
vim.opt.clipboard:append { 'unnamedplus' }
vim.scriptencoding = 'utf-8'


-- Leader key
vim.g.mapleader = ' '

-- Plugin

-- 基本的な設定
now(function()
  require('mini.basics').setup({
    options = {
      extra_ui = true,
    },
    mappings = {
      option_toggle_prefix = 'm',
    },
  })
end)

-- 便利系
now(function()
  require('mini.misc').setup()
  -- ファイルを開いたときに直前のカーソル位置に戻す
  MiniMisc.setup_restore_cursor()
end)

-- アイコン
now(function()
  require('mini.icons').setup()
end)

-- ステータスライン
now(function()
  require('mini.statusline').setup()
  vim.opt.laststatus = 2
  vim.opt.cmdheight = 0
end)

-- 通知
now(function()
  require('mini.notify').setup()
  vim.notify = require('mini.notify').make_notify({})
  -- 過去のnotifyを見直す
  -- https://zenn.dev/kawarimidoll/books/6064bf6f193b51/viewer/b5a24a
  vim.api.nvim_create_user_command('NotifyHistory', function()
    MiniNotify.show_history()
  end, { desc = 'Show notify history' })
end)

-- Color Scheme
now(function()
  vim.cmd.colorscheme('miniautumn')
end)

-- completion
now(function()
  -- nvim-cmp の依存プラグイン
  add('hrsh7th/vim-vsnip')
  add('hrsh7th/cmp-nvim-lsp')
  add('hrsh7th/cmp-buffer')
  add('hrsh7th/cmp-path')
  add('hrsh7th/cmp-cmdline')
  add('hrsh7th/nvim-cmp')

  -- nvim-cmp 本体と設定
  -- Set up nvim-cmp.
  local cmp = require'cmp'

  cmp.setup({
    snippet = {
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'vsnip' },
      { name = 'buffer' },
    }),
    window = {
      -- completion = cmp.config.window.bordered(),
      -- documentation = cmp.config.window.bordered(),
    },
  })

  -- cmdline設定
  cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    }),
    matching = { disallow_symbol_nonprefix_matching = false }
  })

end)

-- オペレータ追加
-- https://zenn.dev/kawarimidoll/books/6064bf6f193b51/viewer/eacaef
later(function()
  require('mini.operators').setup({
    replace = { prefix = 'R' },
    exchange = { prefix = 'g/' },
  })

  vim.keymap.set('n', 'RR', 'R', { desc = 'Replace mode' })
end)

-- ハイライト追加
later(function()
  local hipatterns = require('mini.hipatterns')
  local hi_words = require('mini.extra').gen_highlighter.words
  hipatterns.setup({
    highlighters = {
      todo = hi_words({ 'TODO' }, 'MiniHipatternsTodo'),
      wip  = hi_words({ 'WIP' }, 'MiniHipatternsHack'),
      done = hi_words({ 'DONE' }, 'MiniHipatternsFixme'),
      sche = hi_words({ 'SCHE' }, 'MiniHipatternsNote'),
      -- Highlight hex color strings (`#rrggbb`) using that color
      hex_color = hipatterns.gen_highlighter.hex_color(),
    },
  })
end)

later(function()
  require('mini.cursorword').setup()
end)

-- ファイル操作

now(function()
  require('mini.files').setup()

  vim.api.nvim_create_user_command(
    'Files',
    function()
      MiniFiles.open()
    end,
    { desc = 'Open file exproler' }
  )
  vim.keymap.set('n', '<leader>e', '<cmd>lua MiniFiles.open()<cr>', { desc = 'Open file explorer' })
end)

later(function()
  require('mini.pick').setup()

  vim.ui.select = MiniPick.ui_select
  vim.keymap.set('n', '<space>f', function()
    MiniPick.builtin.files({ tool = 'git' })
  end, { desc = 'mini.pick.files' })

  vim.keymap.set('n', '<space>b', function()
    local wipeout_cur = function()
      vim.api.nvim_buf_delete(MiniPick.get_picker_matches().current.bufnr, {})
    end
    local buffer_mappings = { wipeout = { char = '<c-d>', func = wipeout_cur } }
    MiniPick.builtin.buffers({ include_current = false }, { mappings = buffer_mappings })
  end, { desc = 'mini.pick.buffers' })

  require('mini.visits').setup()
  vim.keymap.set('n', '<space>h', function()
    require('mini.extra').pickers.visit_paths()
  end, { desc = 'mini.extra.visit_paths' })

end)

-- バッファ操作

later(function()
  require('mini.tabline').setup()
end)

-- メモ

-- Obsidian.nvim
now(function()
  add('obsidian-nvim/obsidian.nvim')
  local vault_path = "~/Dropbox/Note"
  require("obsidian").setup {
    legacy_commands = false,
    ui = {
      enable = false
    },
    attachments = {
      img_folder = "assets", -- This is the default
      img_text_func = function(client, path)
        path = client:vault_relative_path(path) or path
        return string.format("![%s](%s)", path.name, path)
      end,
    },
    workspaces = {
      {
        name = "memo",
        path = vault_path,
      },
    },
    completion = {
      nvim_cmp = true,
      min_chars = 2,
    },
    preferred_link_style = "markdown",
    daily_notes = {
      folder = "",
      date_format = "%Y-%m",
      template = nil
    },
    picker = {
      -- Set your preferred picker. Can be one of 'telescope.nvim', 'fzf-lua', 'mini.pick' or 'snacks.pick'.
      name = "mini.pick",
      -- Optional, configure key mappings for the picker. These are the defaults.
      -- Not all pickers support all mappings.
      note_mappings = {
        -- Create a new note from your query.
        new = "<C-x>",
        -- Insert a link to the selected note.
        insert_link = "<C-l>",
      },
      tag_mappings = {
        -- Add tag(s) to current note.
        tag_note = "<C-x>",
        -- Insert a tag at the current location.
        insert_tag = "<C-l>",
      },
    },
    ---@return string
    note_id_func = function()
      -- Generate a unique ID YYYYMMDDHHMMSS format
      return tostring(os.date("%Y%m%d%H%M%S"))
    end,
    ---@return table
    note_frontmatter_func = function(note)
      if note.title then
        note:add_alias(note.title)
      end
      local created_time = os.date("%Y-%m-%d %H:%M") -- ISO 8601 format
      local updated_time = created_time              -- Initially, created and updated times are the same
      -- Initialize the frontmatter table
      local out = {
        id = note.id,
        title = note.title,
        aliases = note.aliases,
        description = note.title,
        tags = note.tags,
        created = created_time,
        updated = updated_time
      }

      if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
        for k, v in pairs(note.metadata) do
          out[k] = v
        end
        if note.metadata.created then out.created = note.metadata.created end
        if note.metadata.updated then out.updated = note.metadata.updated end
      end

      return out
    end,

    ---@param url string
    follow_url_func = function(url)
      vim.fn.jobstart({ "open", url }) -- Mac OS
      -- vim.fn.jobstart({"xdg-open", url})  -- linux
    end,
  }

  -- Key map
  vim.api.nvim_create_autocmd("User", {
    pattern = "ObsidianNoteEnter",
    callback = function(ev)
      vim.keymap.set("n", "<leader>ch", "<cmd>Obsidian toggle_checkbox<cr>", {
        buffer = ev.buf,
        desc = "Toggle checkbox",
      })
    end,
  })

end)

-- treesitter

later(function()
  add({
    source = 'https://github.com/nvim-treesitter/nvim-treesitter',
    hooks = {
      post_checkout = function()
        vim.cmd.TSUpdate()
      end
    },
  })
  ---@diagnostic disable-next-line: missing-fields
  require('nvim-treesitter.configs').setup({
    -- auto-install parsers
    ensure_installed = { 'lua', 'vim', 'markdown' },
    highlight = { enable = true },
  })
end)
-- Key map
vim.api.nvim_set_keymap('n', ':', ';', { noremap = true })
vim.api.nvim_set_keymap('n', ';', ':', { noremap = true })
vim.api.nvim_set_keymap('v', ':', ';', { noremap = true })
vim.api.nvim_set_keymap('v', ';', ':', { noremap = true })

vim.api.nvim_set_keymap('n', '<C-w>t', ':tabnew<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Esc><Esc>', ':nohl<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>tc', ':<C-u>tabclose<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 's', '', { noremap = true })
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<cr>', { desc = 'Clear search highlights' })


-- Terminal mappings
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

