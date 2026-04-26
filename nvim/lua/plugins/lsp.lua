return {
  {
    -- =========================
    -- 🧠 1. LSP 核心系统
    -- =========================

    -- LSP 配置核心（Neovim 官方标准）
    'neovim/nvim-lspconfig',
    dependencies = {
      -- =========================
      -- 📦 2. 自动安装 LSP（Mason 系统）
      -- =========================

      -- LSP / formatter / debugger 安装器
      {
        'mason-org/mason.nvim',
        opts = {}, -- 初始化 mason（默认配置）
      },

      -- Mason ↔ lspconfig 名字映射桥接
      'mason-org/mason-lspconfig.nvim',

      -- 自动安装工具（formatter / linter）
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- =========================
      -- 📊 3. LSP 状态提示 UI
      -- =========================

      {
        'j-hui/fidget.nvim',
        opts = {}, -- 显示 LSP loading / progress
      },
    },

    -- =========================
    -- ⚙️ 4. LSP attach 行为（核心逻辑）
    -- =========================
    config = function()

      -- 当 LSP 连接到某个 buffer 时触发
      vim.api.nvim_create_autocmd('LspAttach', {

        group = vim.api.nvim_create_augroup(
          'kickstart-lsp-attach',
          { clear = true }
        ),

        callback = function(event)

          -- =========================
          -- 🧩 helper：统一 keymap 封装
          -- =========================
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, {
              buffer = event.buf,
              desc = 'LSP: ' .. desc,
            })
          end

          -- =========================
          -- ✏️ 5. 基础 LSP 操作
          -- =========================

          -- 重命名（跨文件）
          map('grn', vim.lsp.buf.rename, '[R]ename')

          -- Code Action（修复 / 重构）
          map('gra', vim.lsp.buf.code_action, '[A]ction', { 'n', 'x' })

          -- 声明跳转（C / header）
          map('grD', vim.lsp.buf.declaration, '[D]eclaration')

          -- =========================
          -- 🔍 6. 代码高亮（引用追踪）
          -- =========================

          local client = vim.lsp.get_client_by_id(event.data.client_id)

          if client and client:supports_method('textDocument/documentHighlight', event.buf) then

            local highlight_group = vim.api.nvim_create_augroup(
              'lsp-highlight',
              { clear = false }
            )

            -- 光标停留 → 高亮所有引用
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_group,
              callback = vim.lsp.buf.document_highlight,
            })

            -- 光标移动 → 清除高亮
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_group,
              callback = vim.lsp.buf.clear_references,
            })

            -- LSP 断开 → 清理 highlight
            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup(
                'lsp-detach',
                { clear = true }
              ),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds {
                  group = 'lsp-highlight',
                  buffer = event2.buf,
                }
              end,
            })
          end

          -- =========================
          -- 🧠 7. Inlay Hints（类型提示）
          -- =========================

          if client and client:supports_method('textDocument/inlayHint', event.buf) then

            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(
                not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }
              )
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- =========================
      -- 🌐 8. LSP Server 配置列表
      -- =========================

      local servers = {

        -- Lua LSP（Neovim 专用）
        lua_ls = {

          on_init = function(client)

            -- ❌ 禁用格式化（交给 stylua）
            client.server_capabilities.documentFormattingProvider = false

            -- 防止重复加载 config workspace
            if client.workspace_folders then
              local path = client.workspace_folders[1].name

              if path ~= vim.fn.stdpath 'config' and
                (vim.uv.fs_stat(path .. '/.luarc.json')
                or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then
                return
              end
            end

            -- =========================
            -- 🧠 Lua runtime 环境补全
            -- =========================
            client.config.settings.Lua = vim.tbl_deep_extend('force',
              client.config.settings.Lua,
              {
                runtime = {
                  version = 'LuaJIT',
                  path = { 'lua/?.lua', 'lua/?/init.lua' },
                },

                workspace = {

                  checkThirdParty = false,

                  -- Neovim runtime API 注入
                  library = vim.tbl_extend('force',
                    vim.api.nvim_get_runtime_file('', true),
                    {
                      '${3rd}/luv/library',
                      '${3rd}/busted/library',
                    }
                  ),
                },
              }
            )
          end,

          settings = {
            Lua = {
              format = { enable = false },
            },
          },
        },
      }

      -- =========================
      -- 📦 9. 自动安装工具链
      -- =========================

      local ensure_installed = vim.tbl_keys(servers)

      vim.list_extend(ensure_installed, {})

      require('mason-tool-installer').setup {
        ensure_installed = ensure_installed,
      }

      -- =========================
      -- 🚀 10. 启动所有 LSP
      -- =========================

      for name, server in pairs(servers) do
        vim.lsp.config(name, server)
        vim.lsp.enable(name)
      end
    end,
  },

  -- =========================
  -- 🧹 11. 格式化系统
  -- =========================

  {
    'stevearc/conform.nvim',

    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },

    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },

    opts = {

      -- ❌ 格式错误不提示
      notify_on_error = false,

      -- =========================
      -- 💾 保存时格式化策略
      -- =========================
      format_on_save = function(bufnr)

        local enabled_filetypes = {
          -- lua = true,
          -- python = true,
        }

        if enabled_filetypes[vim.bo[bufnr].filetype] then
          return { timeout_ms = 500 }
        end

        return nil
      end,

      -- =========================
      -- 🧠 格式化优先级策略
      -- =========================
      default_format_opts = {
        lsp_format = 'fallback',
      },

      -- 外部 formatter 配置
      formatters_by_ft = {
        -- rust = { 'rustfmt' },
        -- js = { "prettier" },
      },
    },
  },

  -- =========================
  -- ⚡ 12. 自动补全系统
  -- =========================

  {
    'saghen/blink.cmp',

    event = 'VimEnter',
    version = '1.*',

    dependencies = {

      -- =========================
      -- ✂️ snippet 引擎
      -- =========================

      {
        'L3MON4D3/LuaSnip',
        version = '2.*',

        build = function()
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end,

        opts = {},
      },
    },

    opts = {

      -- =========================
      -- ⌨️ keymap 行为
      -- =========================
      keymap = {
        preset = 'default',
      },

      -- =========================
      -- 🎨 UI 外观
      -- =========================
      appearance = {
        nerd_font_variant = 'mono',
      },

      -- =========================
      -- 📚 completion 文档行为
      -- =========================
      completion = {
        documentation = {
          auto_show = false,
          auto_show_delay_ms = 500,
        },
      },

      -- =========================
      -- 📦 数据来源
      -- =========================
      sources = {
        default = { 'lsp', 'path', 'snippets' },
      },

      -- snippet 引擎绑定
      snippets = {
        preset = 'luasnip',
      },

      -- =========================
      -- 🔍 fuzzy 搜索
      -- =========================
      fuzzy = {
        implementation = 'lua',
      },

      -- =========================
      -- 📌 函数签名提示
      -- =========================
      signature = {
        enabled = true,
      },
    },
  },
}