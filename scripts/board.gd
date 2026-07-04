# scripts/board.gd
extends GridContainer

var board_squares: Array = []
var selected_pos: Vector2i = Vector2i(-1, -1)

signal square_clicked(pos: Vector2i)

func _ready():
	columns = 8
	create_board()

func create_board():
	for child in get_children():
		child.queue_free()
	board_squares.clear()
	
	for y in range(8):
		for x in range(8):
			var square_panel = Panel.new()
			square_panel.custom_minimum_size = Vector2(80, 80)
			square_panel.name = "Square_%d_%d" % [x, y]
			
			# Dark grey and light squares
			var is_light = (x + y) % 2 == 1
			var style = StyleBoxFlat.new()
			style.bg_color = Color(0.85, 0.82, 0.75) if is_light else Color(0.35, 0.32, 0.28)
			square_panel.add_theme_stylebox_override("panel", style)
			
			square_panel.set_meta("pos", Vector2i(x, y))
			square_panel.gui_input.connect(_on_square_input.bind(Vector2i(x, y)))
			
			add_child(square_panel)
			board_squares.append(square_panel)

func _on_square_input(event: InputEvent, pos: Vector2i):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("square_clicked", pos)

func update_board(board_state: Array):
	for y in 8:
		for x in 8:
			var idx = y * 8 + x
			var square_panel = board_squares[idx]
			# Clear old piece
			for child in square_panel.get_children():
				child.queue_free()
			
			var piece = board_state[y][x]
			if piece:
				var sprite = Sprite2D.new()
				sprite.texture = load(get_piece_texture(piece))
				sprite.scale = Vector2(0.75, 0.75)
				square_panel.add_child(sprite)

func get_piece_texture(piece) -> String:
	var prefix = "white_" if piece.color == 0 else "black_"
	var piece_name = ""
	match piece.type:
		1: piece_name = "pawn"
		2: piece_name = "knight"
		3: piece_name = "bishop"
		4: piece_name = "rook"
		5: piece_name = "queen"
		6: piece_name = "king"
	return "res://assets/sprites/" + prefix + piece_name + ".png"
	
func highlight_square(pos: Vector2i):
	var idx = pos.y * 8 + pos.x
	if idx < board_squares.size():
		board_squares[idx].modulate = Color(0.4, 1.0, 0.4, 0.6)

func clear_highlights():
	for panel in board_squares:
		panel.modulate = Color(1,1,1,1)
