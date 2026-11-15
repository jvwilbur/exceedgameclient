extends Control
# The Season 3 Critical symbol (phone layout), drawn to fit the control: a red disc in a dark
# ring with the "fire" character (火) stroked in dark red-black, as printed on the cards. It
# ignores the mouse.

var glow : bool = false   # a soft pulsing glow behind it
var _t : float = 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(delta : float) -> void:
	if glow:
		_t += delta
		queue_redraw()

func _draw() -> void:
	var s := minf(size.x, size.y)
	if s < 4.0:
		return
	var c := size / 2.0
	var r := s / 2.0
	if glow:
		draw_circle(c, r, Color(1.0, 0.35, 0.1, 0.25 + 0.15 * sin(_t * 3.0)))
		r *= 0.88
	draw_circle(c, r, Color(0.08, 0.02, 0.02))                   # dark ring
	draw_circle(c, r * 0.84, Color(0.86, 0.16, 0.18))            # red disc
	draw_circle(c, r * 0.84, Color(1.0, 0.55, 0.5, 0.35), false, maxf(1.0, r * 0.06), true) # a lighter rim
	# 火: two short flicks at the sides, then a person-like 人 in the middle.
	var ink := Color(0.12, 0.0, 0.0)
	var w := maxf(1.5, r * 0.15)
	var u := r * 0.6 # (the character's half-size)
	var pts := [
		# left flick (down and in)
		[Vector2(-0.72, -0.42), Vector2(-0.5, -0.05)],
		# right flick (down and out)
		[Vector2(0.72, -0.5), Vector2(0.45, -0.05)],
		# the central stroke, down and sweeping left
		[Vector2(0.0, -0.95), Vector2(0.0, -0.1), Vector2(-0.3, 0.45), Vector2(-0.8, 0.85)],
		# the right leg, sweeping down to the right
		[Vector2(0.0, 0.0), Vector2(0.35, 0.5), Vector2(0.85, 0.85)],
	]
	for stroke in pts:
		var line := PackedVector2Array()
		for p in stroke:
			line.append(c + p * u)
		draw_polyline(line, ink, w, true)
		for p in line:
			draw_circle(p, w * 0.5, ink) # (round the ends and joints)
