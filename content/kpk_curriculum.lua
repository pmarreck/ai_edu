-- curriculum-node/1 graph for the king-and-pawn course; ids are the skill ids items score.
local function node(id, title, objective, prerequisites)
	return { schema = "curriculum-node/1", id = id, title = title, objective = objective,
		prerequisites = prerequisites, related = {}, sources = { "kpk-solver" } }
end

return {
	node("kpk.square", "The square of the pawn",
		"Decide whether a lone king catches a passed pawn, including the double step from the second rank", {}),
	node("kpk.opposition", "The opposition",
		"Take the opposition with the king instead of pushing the pawn too early", {}),
	node("kpk.key_squares", "Key squares",
		"Name a pawn's key squares and walk the king onto one to force the win", { "kpk.opposition" }),
	node("kpk.transfer", "Rook-pawn exception",
		"Apply the key-square idea to a rook pawn, where a defending king in the corner draws", { "kpk.key_squares", "kpk.square" }),
}
