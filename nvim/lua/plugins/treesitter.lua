return {
  {
    -- mini.nvim
    'nvim-mini/mini.nvim',
    config = function()
      require('mini.ai').setup {
        -- 避免和<D-z>Neovim>=0.12 的 treesitter incremental selection 冲突
        mappings = {
          -- aa：跳到下一个 around object
          around_next = 'aa',
          -- ii：跳到下一个 inside object
          inside_next = 'ii',
        },
        -- 向上下扫描 500 行寻找结构（提高识别范围）
        n_lines = 500,
      }

      require('mini.surround').setup()
      local statusline = require 'mini.statusline'
      statusline.setup {
        use_icons = true
      }
      statusline.section_location = function()
        -- 显示：行号:列号
        return '%2l:%-2v'
      end
      -- https://github.com/nvim-mini/mini.nvim
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      highlight = { enable = true },
      indent = { enable = true },
      ensure_installed = {
        "bash",
        "c",
        "diff",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "regex",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
        "toml"
      },
    },

    config = function(_, opts)
      require("nvim-treesitter.config").setup(opts)
    end,

  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = "VeryLazy",
    opts = {
      move = {
        enable = true,
        set_jumps = true,
        goto_next_start = {
          ["]f"] = "@function.outer",
          ["]c"] = "@class.outer",
          ["]a"] = "@parameter.inner",
        },
        goto_previous_start = {
          ["[f"] = "@function.outer",
          ["[c"] = "@class.outer",
          ["[a"] = "@parameter.inner",
        },
      },
    },

    config = function(_, opts)
      require("nvim-treesitter-textobjects").setup(opts)
    end,

  },

  {
    "windwp/nvim-ts-autotag",
    event = "VeryLazy",
    opts = {},
  },
}
