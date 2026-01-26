local M = {}

---プラグインを初期化する
function M.setup()
	-- イベントリスナー登録
	local events = require("mini-pick-preview.events")
	events.setup()
end

return M
