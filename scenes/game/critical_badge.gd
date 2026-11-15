extends "res://scenes/game/status_gem_badge.gd"
# "CRITICAL" badge (phone layout, Season 3): a pill ablaze, with flames licking up from the
# bottom and sparks drifting off. Shown once a strike's Critical cost is paid (or a boost in play
# makes the strike Critical, e.g. Unstoppable). Same white-and-black rim as the other badges.

const Fire = preload("res://scenes/game/critical_fire.gd")

func _setup() -> void:
	if text == "":
		text = "CRITICAL"
	font_color = Color(1.0, 0.97, 0.85)
	outline_color = Color(0.35, 0.02, 0.0)

func _draw_fill(inner : Rect2, poly : PackedVector2Array) -> void:
	Fire.draw_fire(self, inner, poly, _t)
	var gloss := _pill(Rect2(inner.position + Vector2(inner.size.y * 0.35, inner.size.y * 0.07),
			Vector2(inner.size.x - inner.size.y * 0.7, inner.size.y * 0.24)), 8)
	draw_colored_polygon(gloss, Color(1, 1, 1, 0.14))
	# A hot flare now and then.
	var cyc := fposmod(_t, 2.8)
	if cyc < 0.4:
		draw_colored_polygon(poly, Color(1.0, 0.8, 0.3, 0.18 * (1.0 - cyc / 0.4)))
