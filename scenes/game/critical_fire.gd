extends RefCounted
# Shared fire drawing for the Season 3 "Critical" visuals (phone layout): the CRITICAL badge, the
# Critical bonus box and the CRITICAL tag on the strike banner. Everything is drawn into `ci`
# (any CanvasItem, from its _draw) and clipped to the polygon `clip`.
#
# A deep red base heating to orange and yellow at the bottom, tongues of flame licking upward
# and flickering, and a few sparks drifting up.

const DEEP := Color(0.42, 0.03, 0.0)
const RED := Color(0.86, 0.12, 0.02)
const ORANGE := Color(1.0, 0.48, 0.05)
const YELLOW := Color(1.0, 0.86, 0.3)

static func clipped(ci : CanvasItem, poly : PackedVector2Array, clip : PackedVector2Array, col : Color) -> void:
	for p in Geometry2D.intersect_polygons(poly, clip):
		if p.size() >= 3:
			ci.draw_colored_polygon(p, col)

# `rect`: the area to fill; `t`: time in seconds (drives the flicker); `intensity` 0..1 scales
# how tall the flames reach (1 = the full height).
static func draw_fire(ci : CanvasItem, rect : Rect2, clip : PackedVector2Array, t : float, intensity : float = 1.0) -> void:
	var h := rect.size.y
	var w := rect.size.x
	# Base: dark red at the top, hot orange at the bottom.
	var cols := PackedColorArray()
	for p in clip:
		var v := clampf((p.y - rect.position.y) / maxf(h, 1.0), 0.0, 1.0)
		cols.append(DEEP.lerp(RED, v * 1.2) if v < 0.75 else RED.lerp(ORANGE, (v - 0.75) * 4.0))
	ci.draw_polygon(clip, cols)
	# Flame tongues, three layers (red, orange, yellow), each a row of flickering peaks.
	var layers := [[RED.lightened(0.1), 0.95, 0.0, 1.6], [ORANGE, 0.7, 1.7, 2.3], [YELLOW, 0.42, 3.1, 3.1]]
	var n := maxi(4, int(w / maxf(h * 0.42, 6.0)))
	for L in layers:
		var col : Color = L[0]
		var reach : float = L[1] * intensity
		var ph : float = L[2]
		var sp : float = L[3]
		var pts := PackedVector2Array()
		pts.append(Vector2(rect.position.x - 2.0, rect.end.y + 2.0))
		for k in range(n * 2 + 1):
			var u := float(k) / (n * 2)
			var x := rect.position.x + u * w
			var peak := k % 2 == 1
			var flick := 0.55 + 0.45 * sin(t * sp * 2.2 + k * 1.7 + ph) * sin(t * sp * 1.3 + k * 0.9)
			var y := rect.end.y - (h * reach * (0.55 + 0.45 * flick) if peak else h * reach * 0.18)
			# (the peaks lean as if in a draught)
			x += (sin(t * 1.9 + k + ph) * h * 0.08) if peak else 0.0
			pts.append(Vector2(x, y))
		pts.append(Vector2(rect.end.x + 2.0, rect.end.y + 2.0))
		clipped(ci, pts, clip, Color(col, 0.85))
	# Sparks rising.
	for i in range(6):
		var cyc := fposmod(t * 0.55 + i * 0.37, 1.0)
		var sx := rect.position.x + w * fposmod(0.13 + i * 0.29 + sin(t * 0.7 + i) * 0.03, 1.0)
		var sy := rect.end.y - cyc * h * 1.1
		var r := maxf(1.0, h * 0.045) * (1.0 - cyc)
		if r > 0.4 and Geometry2D.is_point_in_polygon(Vector2(sx, sy), clip):
			ci.draw_circle(Vector2(sx, sy), r, Color(1.0, 0.95, 0.6, 0.9 * (1.0 - cyc)))
