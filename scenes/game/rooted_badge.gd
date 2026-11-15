extends "res://scenes/game/status_gem_badge.gd"
# "ROOTED" badge (phone layout): packed earth like GROUNDED, with a tangle of pale roots spreading
# down and out through the dirt (growing in when the badge appears, then swaying a little). Shown
# on a player who can't move (Halberdier, Cave In, Wolf Trap...). `arrow_dir`: when only one way
# is blocked (Halberdier: no Advance or Close), a white arrow at the right end of the badge points
# the way they can't go (-1 left, 1 right, 0 none), the lettering moving over to make room. Same
# white-and-black rim as the other badges.

var arrow_dir : int = 0 :
	set(v):
		arrow_dir = v
		_fit_label()
		queue_redraw()

var _roots : Array = []     # each: {"x0": float (across, 0..1 of the width), "pts": PackedVector2Array
	# (x: sideways offset in badge heights, y: depth 0..1), "w": float, "start": float}
var _pebbles : Array = []
var _grow : float = 0.0       # 0..1, how far the roots have grown in this cycle
var _cycle_t : float = 0.0    # time into the current cycle
var _fade : float = 1.0       # the roots' opacity (they fade out before growing again)
# The roots grow in slowly, stay a moment fully grown, fade, and grow again, on a loop.
const GROW_TIME := 2.0
const HOLD_TIME := 1.0
const FADE_TIME := 0.6

func _setup() -> void:
	if text == "":
		text = "ROOTED"
	font_color = Color(1.0, 0.95, 0.85)
	outline_color = Color(0.16, 0.08, 0.02)
	var rng := RandomNumberGenerator.new()
	rng.seed = 9021
	for i in range(10):
		_pebbles.append({"p": Vector2(rng.randf(), rng.randf_range(0.2, 0.95)), "r": rng.randf_range(0.035, 0.07)})
	# Roots hanging down from the top edge through the dirt, each forking into thinner side roots
	# that slant down and away.
	for i in range(7):
		var x0 := 0.07 + i * 0.145 + rng.randf_range(-0.03, 0.03)
		var lean := rng.randf_range(-0.35, 0.35)
		var main := _root_path(rng, Vector2(0.0, 0.0), lean, 1.05, 8)
		_roots.append({"x0": x0, "pts": main, "w": 0.1, "start": 0.0})
		for k in range(2):
			var at : Vector2 = main[rng.randi_range(2, 5)]
			var side := -1.0 if k == 0 else 1.0
			var branch := _root_path(rng, at, side * rng.randf_range(0.35, 0.6), 0.5, 5)
			_roots.append({"x0": x0, "pts": branch, "w": 0.055, "start": 0.3 + 0.25 * k})

# A wandering path from `from`, heading down `length` (of the badge's height) and sideways by
# `lean` badge heights in all.
func _root_path(rng : RandomNumberGenerator, from : Vector2, lean : float, length : float, n : int) -> PackedVector2Array:
	var pts := PackedVector2Array([from])
	var p := from
	for s in range(n):
		p += Vector2(lean / n + rng.randf_range(-0.04, 0.04), length / n)
		pts.append(Vector2(p.x, minf(p.y, 1.05)))
	return pts

# (with an arrow, the lettering keeps to the part of the badge left of it)
func _fit_label() -> void:
	super._fit_label()
	if _label == null or arrow_dir == 0:
		return
	var room := size.y * 0.95
	_label.size = Vector2(size.x - room, size.y)
	var f : Font = _label.get_theme_font("font")
	var fs := _label.get_theme_font_size("font_size")
	while fs > 10 and f.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x > _label.size.x - size.y * 0.45:
		fs -= 1
	_label.add_theme_font_size_override("font_size", fs)

func pop_in(target_pos : Vector2) -> void:
	_cycle_t = 0.0
	_grow = 0.0
	_fade = 1.0
	super.pop_in(target_pos)

func _process(delta : float) -> void:
	_cycle_t += delta
	if _cycle_t >= GROW_TIME + HOLD_TIME + FADE_TIME:
		_cycle_t = 0.0
	_grow = minf(1.0, _cycle_t / GROW_TIME)
	_fade = 1.0 - clampf((_cycle_t - GROW_TIME - HOLD_TIME) / FADE_TIME, 0.0, 1.0)
	super._process(delta)

func _draw_fill(inner : Rect2, poly : PackedVector2Array) -> void:
	var h := size.y
	# Earth: dark and damp, a little lighter at the top.
	var cols := PackedColorArray()
	for p in poly:
		var v := clampf((p.y - inner.position.y) / inner.size.y, 0.0, 1.0)
		cols.append(Color(0.42, 0.27, 0.13).lerp(Color(0.19, 0.11, 0.04), v))
	draw_polygon(poly, cols)
	for pb in _pebbles:
		var c : Vector2 = inner.position + pb["p"] * inner.size
		if Geometry2D.is_point_in_polygon(c, poly):
			draw_circle(c, pb["r"] * h, Color(0.5, 0.42, 0.32, 0.8))
	# The roots, growing down through the dirt: a dark edge, a pale core.
	for r in _roots:
		var g := clampf((_grow - r["start"]) / maxf(0.01, 1.0 - r["start"]), 0.0, 1.0)
		if g <= 0.0:
			continue
		var src : PackedVector2Array = r["pts"]
		var upto := maxi(1, int(round((src.size() - 1) * g)))
		var x0 : float = inner.position.x + float(r["x0"]) * inner.size.x
		var ih := inner.size.y
		# Drawn a segment at a time, thinning toward the tip.
		var w0 : float = maxf(1.0, h * r["w"])
		for i in range(upto):
			var a : Vector2 = src[i]
			var b : Vector2 = src[i + 1]
			var sa := sin(_t * 1.3 + a.y * 5.0 + float(r["x0"]) * 9.0) * 0.04 * a.y
			var sb := sin(_t * 1.3 + b.y * 5.0 + float(r["x0"]) * 9.0) * 0.04 * b.y
			var pa := Vector2(x0 + (a.x + sa) * ih, inner.position.y + a.y * ih)
			var pb := Vector2(x0 + (b.x + sb) * ih, inner.position.y + b.y * ih)
			var w := maxf(0.8, w0 * (1.0 - 0.75 * float(i) / float(src.size() - 1)))
			for seg in Geometry2D.intersect_polyline_with_polygon(PackedVector2Array([pa, pb]), poly):
				if seg.size() >= 2:
					draw_polyline(seg, Color(0.12, 0.06, 0.02, 0.9 * _fade), w * 1.7, true)
					draw_polyline(seg, Color(0.86, 0.74, 0.55, _fade), w, true)
	var gloss := _pill(Rect2(inner.position + Vector2(inner.size.y * 0.35, inner.size.y * 0.07),
			Vector2(inner.size.x - inner.size.y * 0.7, inner.size.y * 0.22)), 8)
	draw_colored_polygon(gloss, Color(1, 1, 1, 0.1))
	# One way blocked: a white arrow at the right end, pointing the way they can't move.
	if arrow_dir != 0:
		var ah := inner.size.y * 0.7
		var cx : float = inner.end.x - inner.size.y * 0.6
		var cy := inner.position.y + inner.size.y / 2.0
		var d := float(arrow_dir)
		var shaft := ah * 0.22
		var arrow := PackedVector2Array([
			Vector2(cx - d * ah * 0.5, cy - shaft), Vector2(cx, cy - shaft), Vector2(cx, cy - ah * 0.5),
			Vector2(cx + d * ah * 0.5, cy), Vector2(cx, cy + ah * 0.5), Vector2(cx, cy + shaft),
			Vector2(cx - d * ah * 0.5, cy + shaft)])
		if d < 0:
			arrow.reverse()
		var outline := PackedVector2Array(arrow)
		outline.append(arrow[0])
		draw_colored_polygon(arrow, Color(1, 1, 1))
		draw_polyline(outline, Color(0, 0, 0), maxf(1.5, h * 0.05), true)
