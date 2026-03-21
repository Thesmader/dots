return {
  {
    "ibhagwan/fzf-lua",
    cmd = "FzfLua",
    keys = {
      { "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Grep" },
      { "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>FzfLua help_tags<cr>", desc = "Help tags" },
      { "<leader>fr", "<cmd>FzfLua oldfiles<cr>", desc = "Recent files" },
      { "<leader>fw", "<cmd>FzfLua grep_cword<cr>", desc = "Grep word" },
      { "<leader>fd", "<cmd>FzfLua diagnostics_document<cr>", desc = "Diagnostics" },
      { "<leader>fs", "<cmd>FzfLua lsp_document_symbols<cr>", desc = "Symbols (document)" },
      { "<leader>fS", "<cmd>FzfLua lsp_workspace_symbols<cr>", desc = "Symbols (workspace)" },
      { "<leader>f/", "<cmd>FzfLua grep_curbuf<cr>", desc = "Grep current buffer" },
      { "<leader>/", "<cmd>FzfLua live_grep<cr>", desc = "Grep (root)" },
      { "<leader><space>", "<cmd>FzfLua files<cr>", desc = "Find files (root)" },
    },
    opts = {
      "ivy",
      fzf_opts = { ["--cycle"] = true },
      defaults = {
        formatter = "path.filename_first",
      },
    },
  },

  {
    "folke/snacks.nvim",
    opts = {
      explorer = {
        replace_netrw = true,
      },
      picker = {
        sources = {
          explorer = {
            layout = { layout = { position = "right" } },
          },
        },
      },
    },
    keys = {
      { "<leader>e", function() Snacks.explorer() end, desc = "File explorer" },
      { "<leader>fp", function() Snacks.picker.files() end, desc = "Find files (snacks)" },
    },
  },
}
