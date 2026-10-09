local rng = require("ai_edu.rng")
local drbg = require("drbg")

describe("ai_edu.rng", function()
	it("draws from random's BLAKE3 DRBG, seeded by the integer as a 32-byte big-endian seed", function()
		local seed32 = string.rep("\0", 28) .. string.char(0, 0, 0x30, 0x39) -- 12345
		local reference = drbg.new(seed32)
		local r = rng.new(12345)
		for _ = 1, 20 do assert.equal(reference:uniform_number(), r()) end
	end)

	it("is reproducible per seed, distinct across seeds, and stays in [0, 1)", function()
		local a, b, c = rng.new(7), rng.new(7), rng.new(8)
		local same, differ = true, false
		for _ = 1, 200 do
			local x, y, z = a(), b(), c()
			same = same and x == y
			differ = differ or x ~= z
			assert.is_true(x >= 0 and x < 1)
		end
		assert.is_true(same)
		assert.is_true(differ)
	end)

	it("accepts a raw 32-byte secret seed for unpredictable uses", function()
		local secret = string.rep("\7", 32)
		assert.equal(drbg.new(secret):uniform_number(), rng.new(secret)())
	end)
end)
