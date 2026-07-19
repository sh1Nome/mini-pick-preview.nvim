local M = {}

-- プレビューウィンドウのID（グローバル状態）
---@type number | nil プレビューウィンドウID
M.preview_win = nil

---@type number | nil プレビューバッファID
M.preview_buf = nil

---プレビューバッファを作成する
---@return number バッファID
local function create_preview_buffer()
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
	vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
	return buf
end

---プレビューウィンドウを作成する
---右側に固定、高さはpickerと同じ、幅は自動計算
---pickerのボーダー・ハイライト・autocommand設定を継承
---@return number | nil ウィンドウID、失敗時はnil
function M.open()
	-- 既存ウィンドウをクローズ
	M.close()

	-- pickerウィンドウ（親ウィンドウ）を取得
	local picker_win = vim.api.nvim_get_current_win()

	-- ウィンドウが有効か確認
	if not vim.api.nvim_win_is_valid(picker_win) then
		return nil
	end

	local picker_win_config = vim.api.nvim_win_get_config(picker_win)

	-- pickerウィンドウが浮動ウィンドウであることを確認
	if not picker_win_config.relative or picker_win_config.relative == "" then
		return nil
	end

	-- プレビューウィンドウの左端を計算
	local col
	local width
	if picker_win_config.anchor == "NW" or picker_win_config.anchor == "SW" then
		col = picker_win_config.col + picker_win_config.width + 4
		width = vim.o.columns - col
	else
		col = vim.o.columns
		width = vim.o.columns - (picker_win_config.col + 2)
	end

	-- プレビューウィンドウの設定
	local preview_config = {
		relative = "editor",
		-- mini.pickはsingle-window設計で、focusが移るとpickerが自動停止するため
		-- プレビューウィンドウはfocus不可にする
		focusable = false,
		style = "minimal",
		border = picker_win_config.border,
		noautocmd = picker_win_config.noautocmd,
		anchor = picker_win_config.anchor,
		zindex = picker_win_config.zindex and (picker_win_config.zindex - 1),
		height = picker_win_config.height,
		row = picker_win_config.row,
		col = col,
		width = width,
	}

	-- プレビューバッファ作成
	M.preview_buf = create_preview_buffer()

	-- プレビューウィンドウ作成
	pcall(function()
		M.preview_win = vim.api.nvim_open_win(M.preview_buf, false, preview_config)
	end)

	-- ウィンドウ作成に失敗した場合はバッファを破棄する
	-- （未表示のバッファはbufhidden=wipeでは削除されないため）
	if not (M.preview_win and vim.api.nvim_win_is_valid(M.preview_win)) then
		vim.api.nvim_buf_delete(M.preview_buf, { force = true })
		M.preview_buf = nil
		return nil
	end

	-- ハイライトをpickerから継承
	pcall(function()
		vim.api.nvim_set_hl(0, "MiniPickPreviewNormal", { link = "MiniPickNormal" })
		vim.api.nvim_set_hl(0, "MiniPickPreviewBorder", { link = "MiniPickBorder" })
		vim.api.nvim_win_set_config(
			M.preview_win,
			{ winhighlight = "Normal:MiniPickPreviewNormal,FloatBorder:MiniPickPreviewBorder" }
		)
	end)

	return M.preview_win
end

---プレビューウィンドウをクローズする
---プラグインが作成したバッファはbufhidden=wipeにより自動削除される
---（source.previewが差し替えたユーザーのバッファは削除しない）
function M.close()
	if M.preview_win and vim.api.nvim_win_is_valid(M.preview_win) then
		vim.api.nvim_win_close(M.preview_win, true)
	end

	M.preview_win = nil
	M.preview_buf = nil
end

---プレビューウィンドウが表示中かどうか
---@return boolean 表示中ならtrue
function M.is_open()
	return M.preview_win ~= nil and vim.api.nvim_win_is_valid(M.preview_win)
end

---プレビューウィンドウに新しいスクラッチバッファを表示する
---source.previewはバッファに行を書き込む形式と、ウィンドウのバッファ自体を
---差し替える形式（vim.ui.selectのpreview_itemが{buf=...}を返す場合など）が
---あるため、毎回新しいバッファを表示してから呼び出し元でsync_preview_buf()する
---@return number | nil バッファID、ウィンドウ非表示時はnil
function M.reset_preview_buf()
	if not M.is_open() then
		return nil
	end
	local buf = create_preview_buffer()
	vim.api.nvim_win_set_buf(M.preview_win, buf)
	M.preview_buf = buf
	return buf
end

---プレビューウィンドウに実際に表示されているバッファに追従する
function M.sync_preview_buf()
	if M.is_open() then
		M.preview_buf = vim.api.nvim_win_get_buf(M.preview_win)
	end
end

return M
