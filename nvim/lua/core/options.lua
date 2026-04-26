local opts = {
  shiftwidth = 2,        -- 自动缩进宽度：2 个空格
  tabstop = 2,           -- Tab 显示为 2 个空格宽
  expandtab = true,      -- Tab 转换为空格（不用真实 Tab）
  wrap = false,          -- 不自动换行（长行横向滚动）
  termguicolors = true,  -- 开启真彩色支持（主题必须）
  number = true,         -- 显示绝对行号
  relativenumber = true, -- 显示相对行号（便于跳转）
  mouse = 'a',           -- 启用鼠标（所有模式）
  showmode = false,      -- 不显示 -- INSERT --（状态栏会替代）
  breakindent = true,    -- 换行时保持缩进对齐（提升可读性）
  undofile = true,       -- 持久化 undo（关闭文件后还能撤销）
  ignorecase = true,     -- 搜索忽略大小写
  smartcase = true,      -- 输入大写时变为严格匹配
  signcolumn = 'yes',    -- 永远显示左侧提示栏（避免 UI 抖动）
  updatetime = 250,      -- CursorHold / diagnostics 触发延迟（ms）
  timeoutlen = 300,      -- keymap 连按超时时间（比如 leader）
  splitright = true,     -- 垂直分屏默认在右侧
  splitbelow = true,     -- 水平分屏默认在下方
  list = true,           -- 显示不可见字符（tab / 空格等）
  -- listchars = {
  --   tab = '» ', -- Tab 显示为 »
  --   trail = '·', -- 行尾空格显示点
  --   nbsp = '␣' -- 不可见空格显示符号
  -- },
  inccommand = "split", -- ❗实时预览替换命令（你原来写错了 incommand）
  cursorline = true,    -- 高亮当前光标所在行
  scrolloff = 20,       -- 光标上下保留 20 行缓冲（不贴边）
  confirm = true        -- 关闭未保存文件时弹确认
}

-- Set options from table
for opt, val in pairs(opts) do
  vim.o[opt] = val
end

-- Set listchars
vim.opt.listchars = {
  tab = '» ', -- Tab 显示为 »
  trail = '·', -- 行尾空格显示点
  nbsp = '␣' -- 不可见空格显示符号
}

-- Set other options
local colorscheme = require("helpers.colorscheme")
vim.cmd.colorscheme(colorscheme)

-- Sync clipboard between OS and Neovim
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

-- Diagnostic Config & Keymaps（诊断系统配置 & 快捷行为）
-- 参考：:help vim.diagnostic.config
vim.diagnostic.config {
  update_in_insert = false,
  -- ❌ 在 insert 模式（输入时）不更新诊断信息
  -- ✔ 避免边打字边疯狂跳错误提示
  severity_sort = true,
  -- ✔ 按严重程度排序（Error > Warning > Info）
  float = {
    border = 'rounded',
    -- 🪟 浮窗使用圆角边框（更现代 UI）
    source = 'if_many',
    -- 📌 如果有多个 LSP source 才显示来源
  },
  underline = {
    severity = { min = vim.diagnostic.severity.WARN },
    -- 🔴 下划线提示最低级别：Warning 及以上才显示
    -- （Info 不会影响代码视觉）
  },
  -- ==============================
  -- 显示方式（可二选一或组合）
  -- ==============================
  virtual_text = true,
  -- 📍 行尾显示诊断信息（类似 VSCode 红字提示）
  virtual_lines = false,
  -- 📏 不使用“占用多行”的错误展示方式
  -- （开启后会在代码下方插入整行提示）
  -- ==============================
  -- 跳转行为
  -- ==============================
  -- jump = {
  --   float = true,
  --   -- 🚀 使用 `[d` / `]d` 跳转错误时
  --   -- 自动弹出浮窗显示详细信息
  -- },
}

-- TODO: wait 
-- vim.opt.jump.on_jump = {

-- }

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})
