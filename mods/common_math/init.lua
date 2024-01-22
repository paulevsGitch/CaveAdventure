math.clamp = math.clamp or function (val, val_min, val_max)
	if val < val_min then return val_min end
	if val > val_max then return val_max end
	return val
end

math.lerp = math.lerp or function(val_a, val_b, delta)
	return val_a + delta * (val_b - val_a)
end

-- 0 = y+, 1 = z+, 2 = z-, 3 = x+, 4 = x-, 5 = y-

local FACEDIR_AXIS = {
	vector.new(0, 1, 0),
	vector.new(0, 0, 1),
	vector.new(0, 0, -1),
	vector.new(1, 0, 0),
	vector.new(-1, 0, 0),
	vector.new(0, -1, 0)
}

local ZERO = vector.zero()

math.facedir_axis = function (param2)
	return FACEDIR_AXIS[bit.rshift(param2, 2) + 1] or ZERO
end