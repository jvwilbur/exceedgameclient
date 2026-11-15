extends Control
# A rounded box ablaze (phone layout, Season 3 Critical): the backdrop of the CRITICAL tag on the
# strike banner and of the Critical bonus box. Fire inside (see critical_fire.gd), a white rim
# with a thin dark line inside it, like the CRITICAL badge. It ignores the mouse.

const Fire = preload("res://scenes/game/critical_fire.gd")

var radius : float = 14.0
var rim : float = 4.0
var intensity : float = 1.0   # how tall the flames reach (lower behind text that must stay readable)
var scrim : float = 0.0       # a dark veil over the fire (0..1), for text on top
var _t : float = 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_t = randf() * 3.0

func _process(delta : float) -> void:
	_t += delta
	queue_redraw()

func _rounded(rect : Rect2, r : float) -> PackedVector2Array:
	r = minf(r, minf(rect.size.x, rect.size.y) / 2.0)
	var pts := PackedVector2Array()
	var corners := [rect.position + Vector2(rect.size.x - r, r), rect.position + Vector2(rect.size.x - r, rect.size.y - r),
			rect.position + Vector2(r, rect.size.y - r), rect.position + Vector2(r, r)]
	for c in range(4):
		var a0 := -PI / 2.0 + c * PI / 2.0
		for k in range(7):
			var a := a0 + PI / 2.0 * k / 6.0
			pts.append(corners[c] + Vector2(cos(a), sin(a)) * r)
	return pts

func _draw() -> void:
	if size.x < 8.0 or size.y < 8.0:
		return
	draw_colored_polygon(_rounded(Rect2(Vector2.ZERO, size), radius), Color(1, 1, 1))
	var dark := Rect2(Vector2(rim, rim), size - Vector2(rim, rim) * 2.0)
	draw_colored_polygon(_rounded(dark, radius - rim), Color(0.12, 0.0, 0.0))
	var inner := Rect2(dark.position + Vector2(1.5, 1.5), dark.size - Vector2(3.0, 3.0))
	var poly := _rounded(inner, radius - rim - 1.5)
	Fire.draw_fire(self, inner, poly, _t, intensity)
	if scrim > 0.0:
		draw_colored_polygon(poly, Color(0.1, 0.0, 0.0, scrim))
