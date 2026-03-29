local minidoc = require("mini.doc")

if _G.MiniDoc == nil then
	minidoc.setup()
end

MiniDoc.generate({ "lua/mini-pick-preview/init.lua" }, "doc/mini-pick-preview.txt")
