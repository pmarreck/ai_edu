-- Seeded random streams backed by random's BLAKE3 DRBG (flake input, lib/drbg.lua): identical
-- on every platform for a given seed, and unpredictable to anyone without the seed. Integer
-- seeds give reproducible content; pass a secret 32-byte string where unpredictability matters.
local drbg = require("drbg")

local rng = {}

local SEED_BYTES = 32

-- Encode a non-negative integer seed as random's canonical 32-byte big-endian seed.
local function seed_bytes(seed)
	if type(seed) == "string" then
		assert(#seed == SEED_BYTES, "string seeds must be 32 bytes")
		return seed
	end
	assert(seed >= 0 and seed == math.floor(seed) and seed < 2 ^ 53, "integer seeds must be safe non-negative integers")
	local bytes, n = {}, seed
	for i = SEED_BYTES, 1, -1 do
		bytes[i] = string.char(n % 256)
		n = math.floor(n / 256)
	end
	return table.concat(bytes)
end

-- Returns a function giving uniform floats in [0, 1) (exactly k / 2^32).
function rng.new(seed)
	local stream = drbg.new(seed_bytes(seed))
	return function() return stream:uniform_number() end
end

return rng
