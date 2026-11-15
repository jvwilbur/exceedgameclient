extends "res://scenes/game/status_gem_badge.gd"
# "BARRIER" badge (phone layout): a shimmering force field. A translucent cyan-blue
# energy shell over a honeycomb of hexagons that light up in waves, with a ripple that sweeps
# across now and then. Shown while the opponent can't move past this player. Same white-and-black
# rim as the other badges.

var _hexes : Array = []       # centres (pixels) of the honeycomb cells
var _built_for : Vector2 = Vector2.ZERO

func _setup() -> void:
	if text == "":
		text = "BARRIER"
	font_color = Color(0.92, 1.0, 1.0)
	outline_color = Color(0.0, 0.12, 0.3)

func _build(inner : Rect2) -> void:
	_built_for = inner.size
	_hexes.clear()
	var r := inner.size.y * 0.28
	var dx := r * sqrt(3.0)
	var dy := r * 1.5
	var row := 0
	var y := inner.position.y - r
	while y < inner.end.y + r:
		var x := inner.position.x - dx + (dx / 2.0 if row % 2 == 1 else 0.0)
		while x < inner.end.x + dx:
			_hexes.append(Vector2(x, y))
			x += dx
		y += dy
		row += 1

func _hex(c : Vector2, r : float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for k in range(6):
		var a := PI / 6.0 + k * PI / 3.0
		pts.append(c + Vector2(cos(a), sin(a)) * r)
	return pts

func _draw_fill(inner : Rect2, poly : PackedVector2Array) -> void:
	if _built_for != inner.size:
		_build(inner)
	var h := size.y
	# Deep blue shell, brighter at the edges (the field is densest at its rim).
	var cols := PackedColorArray()
	var mid := inner.position + inner.size / 2.0
	for p in poly:
		var e := clampf(absf(p.x - mid.x) / (inner.size.x / 2.0), 0.0, 1.0)
		cols.append(Color(0.02, 0.12, 0.32).lerp(Color(0.1, 0.55, 0.9), e * e))
	draw_polygon(poly, cols)
	# Honeycomb: each cell lights up as a slow wave passes through it.
	var r := inner.size.y * 0.28
	for c in _hexes:
		var wave := 0.5 + 0.5 * sin(_t * 2.2 - (c.x - inner.position.x) / inner.size.x * 6.0 + c.y * 0.05)
		var hp := _hex(c, r * 0.93)
		_draw_clipped(hp, poly, Color(0.35, 0.85, 1.0, 0.06 + 0.2 * wave * wave))
		var loop := PackedVector2Array(hp)
		loop.append(hp[0])
		for seg in Geometry2D.intersect_polyline_with_polygon(loop, poly):
			if seg.size() >= 2:
				draw_polyline(seg, Color(0.6, 0.95, 1.0, 0.25 + 0.4 * wave), maxf(1.0, h * 0.025), true)
	# A ripple sweeping across every few seconds, as if something had bumped the field.
	var cyc := fposmod(_t, 3.2) / 1.0
	if cyc < 1.0:
		var x := lerpf(inner.position.x - h * 0.3, inner.end.x + h * 0.3, cyc)
		var band := PackedVector2Array([Vector2(x - h * 0.18, inner.position.y), Vector2(x + h * 0.18, inner.position.y),
				Vector2(x + h * 0.18, inner.end.y), Vector2(x - h * 0.18, inner.end.y)])
		_draw_clipped(band, poly, Color(0.8, 1.0, 1.0, 0.28 * sin(cyc * PI)))
	# The whole field breathes a little.
	draw_colored_polygon(poly, Color(0.5, 0.9, 1.0, 0.05 + 0.05 * sin(_t * 3.0)))
	var gloss := _pill(Rect2(inner.position + Vector2(inner.size.y * 0.35, inner.size.y * 0.07),
			Vector2(inner.size.x - inner.size.y * 0.7, inner.size.y * 0.26)), 8)
	draw_colored_polygon(gloss, Color(1, 1, 1, 0.16))
