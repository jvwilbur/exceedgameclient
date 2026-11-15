extends "res://scenes/game/status_gem_badge.gd"
# "GROUNDED" badge (phone layout): packed brown earth with pebbles, and green vines that grow
# across it from the bottom, sprouting leaves, then slowly sway. Shown while a player can't be
# moved by the opponent (pushes and pulls ignored: Focus, Double Lariat...). Same white-and-black
# rim as the other badges.

var _pebbles : Array = []   # {"p": Vector2 (0..1), "r": float (x h), "shade": float}
var _vines : Array = []     # {"x0", "x1", "amp", "freq", "ph", "leaves": [u...]}
var _grow : float = 0.0     # 0..1, how far the vines have grown (from when it appears)

func _setup() -> void:
	if text == "":
		text = "GROUNDED"
	font_color = Color(0.95, 1.0, 0.86)
	outline_color = Color(0.16, 0.09, 0.02)
	var rng := RandomNumberGenerator.new()
	rng.seed = 7311
	for i in range(14):
		_pebbles.append({"p": Vector2(rng.randf(), rng.randf_range(0.15, 0.95)),
				"r": rng.randf_range(0.04, 0.09), "shade": rng.randf_range(0.0, 1.0)})
	for i in range(3):
		var leaves := []
		for k in range(5):
			leaves.append(rng.randf_range(0.1, 0.95))
		_vines.append({"x0": rng.randf_range(-0.05, 0.25) + i * 0.3, "x1": rng.randf_range(0.25, 0.45) + i * 0.3,
				"amp": rng.randf_range(0.12, 0.22), "freq": rng.randf_range(2.0, 3.2), "ph": rng.randf() * TAU,
				"leaves": leaves, "y": rng.randf_range(0.55, 0.8)})

func pop_in(target_pos : Vector2) -> void:
	_grow = 0.0
	super.pop_in(target_pos)

func _process(delta : float) -> void:
	_grow = minf(1.0, _grow + delta / 1.4)
	super._process(delta)

func _vine_point(v : Dictionary, inner : Rect2, u : float) -> Vector2:
	var x : float = lerpf(v["x0"], v["x1"], u)
	var sway : float = sin(_t * 1.1 + v["ph"]) * 0.03 * u
	var y : float = v["y"] - sin(u * PI * v["freq"] + v["ph"]) * v["amp"] * (0.4 + 0.6 * u) + sway
	return inner.position + Vector2(x * inner.size.x, clampf(y, 0.08, 0.98) * inner.size.y)

func _draw_fill(inner : Rect2, poly : PackedVector2Array) -> void:
	var h := size.y
	# Earth: warm brown on top, darker loam below.
	var cols := PackedColorArray()
	for p in poly:
		var v := clampf((p.y - inner.position.y) / inner.size.y, 0.0, 1.0)
		cols.append(Color(0.55, 0.36, 0.17).lerp(Color(0.27, 0.16, 0.06), v))
	draw_polygon(poly, cols)
	# Strata lines and pebbles.
	for k in range(1, 3):
		var y := inner.position.y + inner.size.y * k / 3.0
		var line := PackedVector2Array()
		for s in range(9):
			var x := inner.position.x + inner.size.x * s / 8.0
			line.append(Vector2(x, y + sin(s * 1.3 + k) * h * 0.03))
		for seg in Geometry2D.intersect_polyline_with_polygon(line, poly):
			if seg.size() >= 2:
				draw_polyline(seg, Color(0.2, 0.11, 0.03, 0.45), maxf(1.0, h * 0.03), true)
	for pb in _pebbles:
		var c : Vector2 = inner.position + pb["p"] * inner.size
		var r : float = pb["r"] * h
		if Geometry2D.is_point_in_polygon(c, poly):
			draw_circle(c, r, Color(0.62, 0.55, 0.45).lerp(Color(0.38, 0.32, 0.26), pb["shade"]))
			draw_circle(c - Vector2(r, r) * 0.3, r * 0.35, Color(1, 1, 1, 0.18))
	# Vines growing across, with leaves sprouting along them.
	var vw := maxf(1.5, h * 0.065)
	for v in _vines:
		var steps := 18
		var upto := int(round(steps * _grow))
		if upto < 1:
			continue
		var pts := PackedVector2Array()
		for s in range(upto + 1):
			pts.append(_vine_point(v, inner, float(s) / steps))
		for seg in Geometry2D.intersect_polyline_with_polygon(pts, poly):
			if seg.size() >= 2:
				draw_polyline(seg, Color(0.1, 0.3, 0.06), vw * 1.5, true)
				draw_polyline(seg, Color(0.33, 0.68, 0.18), vw, true)
		for lu in v["leaves"]:
			if lu > _grow:
				continue
			var a := _vine_point(v, inner, lu)
			var b := _vine_point(v, inner, minf(1.0, lu + 0.04))
			var dir := (b - a).normalized()
			var nrm := Vector2(-dir.y, dir.x) * (1.0 if int(lu * 100) % 2 == 0 else -1.0)
			var ls := h * 0.22 * clampf((_grow - lu) * 4.0, 0.0, 1.0)
			if ls < 0.5:
				continue
			var tip := a + (nrm * 0.9 + dir * 0.5).normalized() * ls
			var mid := (a + tip) / 2.0
			var side := (tip - a).orthogonal().normalized() * ls * 0.3
			var leaf := PackedVector2Array([a, mid + side, tip, mid - side])
			_draw_clipped(leaf, poly, Color(0.42, 0.8, 0.22))
			for seg in Geometry2D.intersect_polyline_with_polygon(PackedVector2Array([a, tip]), poly):
				if seg.size() >= 2:
					draw_polyline(seg, Color(0.2, 0.5, 0.1), 1.0, true)
	var gloss := _pill(Rect2(inner.position + Vector2(inner.size.y * 0.35, inner.size.y * 0.07),
			Vector2(inner.size.x - inner.size.y * 0.7, inner.size.y * 0.24)), 8)
	draw_colored_polygon(gloss, Color(1, 1, 1, 0.12))
