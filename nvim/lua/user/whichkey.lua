local M = {
  "folke/which-key.nvim",
  event = "VeryLazy",
   init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 250
  end,
}

function M.config()
  local mappings = {
    q = { "<cmd>confirm q<CR>", "Quit" },
    h = { "<cmd>nohlsearch<CR>", "NOHL" },
    w = { "<cmd>confirm w<CR>", "save la" },
    -- [";"] = { "<cmd>tabnew | terminal<CR>", "Term" },
    v = { "<cmd>vsplit<CR>", "Split" },
    b = { name = "Buffers" },
    d = { name = "Debug" },
    f = { name = "Find" },
    g = { name = "Git" },
    l = { name = "LSP" },
    p = { name = "Plugins" },
    t = { name = "Test" },
    o = {
      name = "Obsidian",
      n = { ":ObsidianNewNote<CR>", "New Note" },
      l = { ":ObsidianQuickSwitch<CR>", "Open File" },
      s = { ":ObsidianSearch<CR>", "Search" },
      o = { ":ObsidianBacklinks<CR>", "backlink" },
      t = { ":ObsidianTags<CR>", "Tags" },
      f = { ":ObsidianLinks<CR>", "Links" },
      c = { ":ObsidianCheck<CR>", "Checklist" },
      p = { ":ObsidianPasteImg<CR>", "Paste Image" },
      d = { ":ObsidianDailies<CR>", "Dailies" },
      x = { ":ObsidianDelete<CR>", "Delete" },
      r = { ":ObsidianRename<CR>", "Rename" },
      w = { ":ObsidianWorkspace<CR>", "Workspace" },
    },
    a = {
      name = "Tab",
      n = { "<cmd>$tabnew<cr>", "New Empty Tab" },
      N = { "<cmd>tabnew %<cr>", "New Tab" },
      o = { "<cmd>tabonly<cr>", "Only" },
      h = { "<cmd>-tabmove<cr>", "Move Left" },
      l = { "<cmd>+tabmove<cr>", "Move Right" },
    },
    T = { name = "Treesitter" },
  }

  local which_key = require "which-key"
  which_key.setup {
    plugins = {
      marks = true,
      registers = true,
      spelling = {
        enabled = true,
        suggestions = 20,
      },
      presets = {
        operators = false,
        motions = false,
        text_objects = false,
        windows = false,
        nav = false,
        z = false,
        g = false,
      },
    },
    window = {
      border = "rounded",
      position = "bottom",
      padding = { 2, 2, 2, 2 },
    },
    ignore_missing = true,
    show_help = false,
    show_keys = false,
    disable = {
      buftypes = {},
      filetypes = { "TelescopePrompt" },
    },
  }

  local opts = {
    mode = "n", -- NORMAL mode
    prefix = "<leader>",
  }

  which_key.register(mappings, opts)

  which_key.register({
  -- Assuming that 'o' is your prefix for Obsidian-related commands
  o = {
    -- Define the visual mode keybindings inside the 'o' prefix
    -- Here 'v' is an arbitrary choice for the "Outline" command
    -- You can choose another key that fits your preference and doesn't conflict with existing mappings
    o = { ":ObsidianLinkNew<CR>", "Linknews" },
  },
}, {
  mode = "v", -- VISUAL mode
  prefix = "<leader>",
})
end

return M
