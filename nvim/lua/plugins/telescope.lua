return {
  {
    -- =========================
    -- 🔍 Telescope 主插件
    -- =========================
    'nvim-telescope/telescope.nvim',

    -- 是否启用插件
    enabled = true,

    -- 启动时机：Vim 启动完成后再加载（懒加载）
    event = 'VimEnter',

    -- =========================
    -- 📦 依赖插件
    -- =========================
    dependencies = {

      -- Telescope 的基础工具库（异步 / util）
      'nvim-lua/plenary.nvim',

      -- =========================
      -- ⚡ fzf-native（性能优化）
      -- =========================
      {
        'nvim-telescope/telescope-fzf-native.nvim',

        -- 安装/更新时执行 make 编译 C 模块（提升搜索速度）
        build = 'make',

        -- 只有系统存在 make 才安装这个扩展
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },

      -- =========================
      -- 🎯 UI select 替换
      -- =========================
      {
        'nvim-telescope/telescope-ui-select.nvim',
      },

      -- =========================
      -- 🎨 文件图标（需要 Nerd Font）
      -- =========================
      {
        'nvim-tree/nvim-web-devicons',
        enabled = true,
      },
    },

    -- =========================
    -- ⚙️ Telescope 核心配置
    -- =========================
    config = function()

      -- 引入 telescope 主模块
      local telescope = require('telescope')

      -- =========================
      -- 🎛️ 基础设置
      -- =========================
      telescope.setup {
        extensions = {

          -- ui-select：把 vim.ui.select 替换成 Telescope UI
          ['ui-select'] = require('telescope.themes').get_dropdown(),
        },
      }

      -- =========================
      -- 🔌 加载扩展（安全加载）
      -- =========================
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      -- =========================
      -- 🔍 builtin API（所有搜索功能入口）
      -- =========================
      local builtin = require('telescope.builtin')

      -- =========================
      -- 📁 文件 / 搜索类快捷键
      -- =========================

      -- 查帮助文档
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, {
        desc = '[S]earch [H]elp',
      })

      -- 查 keymap
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, {
        desc = '[S]earch [K]eymaps',
      })

      -- 查文件（类似 fd / find）
      vim.keymap.set('n', '<leader>sf', builtin.find_files, {
        desc = '[S]earch [F]iles',
      })

      -- Telescope 自身功能列表
      vim.keymap.set('n', '<leader>ss', builtin.builtin, {
        desc = '[S]elect Telescope builtins',
      })

      -- 查当前单词
      vim.keymap.set({ 'n', 'v' }, '<leader>sw', builtin.grep_string, {
        desc = '[S]earch current [W]ord',
      })

      -- 全局 grep（ripgrep）
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, {
        desc = '[S]earch by Grep',
      })

      -- 诊断信息（LSP error/warning）
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, {
        desc = '[S]earch [D]iagnostics',
      })

      -- 恢复上一次搜索
      vim.keymap.set('n', '<leader>sr', builtin.resume, {
        desc = '[S]earch [R]esume',
      })

      -- 最近打开的文件
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, {
        desc = '[S]earch Recent Files',
      })

      -- 命令列表
      vim.keymap.set('n', '<leader>sc', builtin.commands, {
        desc = '[S]earch Commands',
      })

      -- buffer 列表
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, {
        desc = 'Find Buffers',
      })

      -- =========================
      -- 🧠 LSP attach 后的功能绑定
      -- =========================
      vim.api.nvim_create_autocmd('LspAttach', {

        group = vim.api.nvim_create_augroup('telescope-lsp-attach', {
          clear = true,
        }),

        callback = function(event)
          local buf = event.buf

          -- =========================
          -- 📌 LSP 导航（全部用 Telescope UI）
          -- =========================

          -- 查引用
          vim.keymap.set('n', 'grr', builtin.lsp_references, {
            buffer = buf,
            desc = '[G]oto [R]eferences',
          })

          -- 查实现
          vim.keymap.set('n', 'gri', builtin.lsp_implementations, {
            buffer = buf,
            desc = '[G]oto [I]mplementation',
          })

          -- 查定义
          vim.keymap.set('n', 'grd', builtin.lsp_definitions, {
            buffer = buf,
            desc = '[G]oto [D]efinition',
          })

          -- 当前文件符号（函数 / 变量）
          vim.keymap.set('n', 'gO', builtin.lsp_document_symbols, {
            buffer = buf,
            desc = 'Document Symbols',
          })

          -- 全项目符号搜索
          vim.keymap.set('n', 'gW', builtin.lsp_dynamic_workspace_symbols, {
            buffer = buf,
            desc = 'Workspace Symbols',
          })

          -- 类型定义
          vim.keymap.set('n', 'grt', builtin.lsp_type_definitions, {
            buffer = buf,
            desc = '[G]oto [T]ype Definition',
          })
        end,
      })

      -- =========================
      -- 🔍 当前 buffer 搜索（更像 IDE 搜索框）
      -- =========================
      vim.keymap.set('n', '<leader>/', function()
        builtin.current_buffer_fuzzy_find(
          require('telescope.themes').get_dropdown {
            winblend = 10,   -- 半透明
            previewer = false, -- 关闭预览（更快）
          }
        )
      end, {
        desc = 'Fuzzy search in current buffer',
      })

      -- =========================
      -- 🔍 只搜索已打开文件
      -- =========================
      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, {
        desc = 'Search in Open Files',
      })

      -- =========================
      -- ⚙️ 搜索 Neovim 配置文件
      -- =========================
      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files {
          cwd = vim.fn.stdpath 'config',
        }
      end, {
        desc = 'Search Neovim Config',
      })

    end,
  },
}