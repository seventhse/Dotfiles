-- See current buffers at the top of the editor
return {
  {
    'akinsho/bufferline.nvim',
    version = "*",
    dependencies = 'nvim-tree/nvim-web-devicons',
    lazy = false,
    opts = {
      options = {
        mode = "buffers", -- 关键：VSCode式 tabs
        diagnostics = "nvim_lsp",
        show_buffer_close_icons = true,
        show_close_icon = false,
      },
    },
    keys = {
      { "<D-L>",      "<CMD>BufferLineCycleNext<CR>",   desc = "Next Buffer" },
      { "<D-H>",      "<CMD>BufferLineCyclePrev<CR>",   desc = "Prev Buffer" },
      { "<leader>w", "<cmd>bnext | bd#<cr>", desc = "Close buffer & switch" },
      -- { "<leader>w", "<cmd>BufferLineCycleNext<cr> | bd #", desc = "Close buffer & switch" },
      -- { "<leader>w",  "<cmd>bd<cr>",                    desc = "Delete buffer" },
      { "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", desc = "Close others" },
      { "<leader>br", "<cmd>BufferLineCloseRight<cr>",  desc = "Close right" },
      { "<leader>bl", "<cmd>BufferLineCloseLeft<cr>",   desc = "Close left" }
    }
  }
}
