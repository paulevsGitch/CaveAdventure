math.clamp = math.clamp or function (val, val_min, val_max)
	if val < val_min then return val_min end
	if val > val_max then return val_max end
	return val
end

math.lerp = math.lerp or function(val_a, val_b, delta)
	return val_a + delta * (val_b - val_a)
end