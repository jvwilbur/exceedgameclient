extends Control
# The Season 7 Cancel symbol (phone layout), drawn to fit the control: a tan clock face (a ring
# with four tick marks and one hand pointing down-right from a center dot), as printed beside a
# cancelable boost's Gauge cost, on a dark brown disc so it reads on the board. It ignores the mouse.


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _draw() -> void:
	var s := minf(size.x, size.y)
	if s < 4.0:
		return
	var c := size / 2.0
	var r := s / 2.0
	var ink := Color(0.96, 0.66, 0.36)
	draw_circle(c, r, Color(0.08, 0.04, 0.02))                  # dark rim
	draw_circle(c, r * 0.9, Color(0.47, 0.24, 0.09))            # brown disc (the boost bar's colour)
	var w := maxf(1.5, r * 0.1)
	var face := r * 0.62
	draw_arc(c, face, 0.0, TAU, 40, ink, w, true)                # the clock's ring
	# Tick marks just inside the ring at 12, 3, 6 and 9 o'clock.
	for k in range(4):
		var a := -PI / 2.0 + k * PI / 2.0
		var d := Vector2(cos(a), sin(a))
		draw_line(c + d * face * 0.62, c + d * face * 0.9, ink, w, true)
	# The hand, down to the right, from a center dot.
	var hand := Vector2(cos(PI / 4.0), sin(PI / 4.0)) * face * 0.85
	draw_line(c, c + hand, ink, w * 1.15, true)
	draw_circle(c, w * 1.1, ink)
