local canonical = require("ai_edu.canonical")

describe("canonical.encode", function()
	it("sorts object keys so insertion order cannot change bytes", function()
		local a = { b = 1, a = { d = true, c = "x" } }
		local b = {}
		b.a = {}; b.a.c = "x"; b.a.d = true; b.b = 1
		assert.equal('{"a":{"c":"x","d":true},"b":1}', canonical.encode(a))
		assert.equal(canonical.encode(a), canonical.encode(b))
	end)

	it("encodes dense arrays in order and escapes strings", function()
		assert.equal('[1,"a\\"b\\n",false]', canonical.encode({ 1, 'a"b\n', false }))
	end)

	it("encodes empty tables as objects", function()
		assert.equal("{}", canonical.encode({}))
	end)

	it("rejects non-integer numbers, functions and mixed tables", function()
		assert.has_error(function() canonical.encode({ x = 1.5 }) end)
		assert.has_error(function() canonical.encode({ f = print }) end)
		assert.has_error(function() canonical.encode({ 1, k = 2 }) end)
	end)

	it("round-trips through decode", function()
		local v = { learner_id = "L1", payload = { skills = { "s1", "s2" }, n = 3 } }
		assert.same(v, canonical.decode(canonical.encode(v)))
	end)
end)
