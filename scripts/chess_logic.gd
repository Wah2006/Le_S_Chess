# scripts/chess_logic.gd
extends Node

enum PieceType { EMPTY, PAWN, KNIGHT, BISHOP, ROOK, QUEEN, KING }
enum PlayerColor { WHITE, BLACK }

class ChessPiece:
	var type: PieceType = PieceType.EMPTY
	var color: PlayerColor
	var has_moved: bool = false

var board: Array = []
var current_turn: PlayerColor = PlayerColor.WHITE
var move_history: Array = []
var game_over: bool = false
var winner: PlayerColor = PlayerColor.WHITE  # Default, will be set properly

signal board_changed

func _init():
	reset_game()

func reset_game():
	board = []
	board.resize(8)
	for i in 8:
		board[i] = []
		board[i].resize(8)
		board[i].fill(null)
	
	setup_starting_position()
	current_turn = PlayerColor.WHITE
	move_history.clear()
	game_over = false
	winner = PlayerColor.WHITE

func setup_starting_position():
	var back = [PieceType.ROOK, PieceType.KNIGHT, PieceType.BISHOP, PieceType.QUEEN, 
				PieceType.KING, PieceType.BISHOP, PieceType.KNIGHT, PieceType.ROOK]
	for x in 8:
		board[0][x] = create_piece(back[x], PlayerColor.BLACK)
		board[1][x] = create_piece(PieceType.PAWN, PlayerColor.BLACK)
		board[6][x] = create_piece(PieceType.PAWN, PlayerColor.WHITE)
		board[7][x] = create_piece(back[x], PlayerColor.WHITE)

func create_piece(type: PieceType, color: PlayerColor) -> ChessPiece:
	var p = ChessPiece.new()
	p.type = type
	p.color = color
	return p

func attempt_move(from: Vector2i, to: Vector2i) -> String:
	if game_over or not is_valid_pos(from) or not is_valid_pos(to):
		return ""
	
	var piece = get_piece(from)
	if not piece or piece.color != current_turn:
		return ""
	
	if not is_legal_move(from, to):
		return ""
	
	var captured = get_piece(to) != null
	var san = generate_basic_san(from, to, captured)
	
	board[to.y][to.x] = board[from.y][from.x]
	board[from.y][from.x] = null
	board[to.y][to.x].has_moved = true
	
	move_history.append(san)
	current_turn = PlayerColor.BLACK if current_turn == PlayerColor.WHITE else PlayerColor.WHITE
	
	check_game_over()
	emit_signal("board_changed")
	return san

func is_legal_move(from: Vector2i, to: Vector2i) -> bool:
	var piece = get_piece(from)
	if not piece: return false
	if from == to: return false
	
	var target = get_piece(to)
	if target and target.color == piece.color:
		return false
	
	match piece.type:
		PieceType.PAWN:
			return is_legal_pawn_move(from, to, piece.color)
		PieceType.KNIGHT:
			return is_legal_knight_move(from, to)
		PieceType.BISHOP:
			return is_legal_bishop_move(from, to)
		PieceType.ROOK:
			return is_legal_rook_move(from, to)
		PieceType.QUEEN:
			return is_legal_bishop_move(from, to) or is_legal_rook_move(from, to)
		PieceType.KING:
			return is_legal_king_move(from, to)
	return false

# ... (keep the rest of your legal move functions as they are)
# Simple implementations (expandable)

func is_legal_pawn_move(from: Vector2i, to: Vector2i, color: PlayerColor) -> bool:

	var dir = -1 if color == PlayerColor.WHITE else 1

	var start_rank = 6 if color == PlayerColor.WHITE else 1

	

	# Normal move

	if to.x == from.x and to.y == from.y + dir and not get_piece(to):

		return true

	# Double move

	if to.x == from.x and from.y == start_rank and to.y == from.y + 2*dir and not get_piece(to):

		return true

	# Capture

	if abs(to.x - from.x) == 1 and to.y == from.y + dir and get_piece(to):

		return true

	return false

func is_legal_knight_move(from: Vector2i, to: Vector2i) -> bool:

	var dx = abs(to.x - from.x)

	var dy = abs(to.y - from.y)

	return (dx == 1 and dy == 2) or (dx == 2 and dy == 1)

func is_legal_bishop_move(from: Vector2i, to: Vector2i) -> bool:

	if abs(to.x - from.x) != abs(to.y - from.y): return false

	return is_path_clear(from, to)

func is_legal_rook_move(from: Vector2i, to: Vector2i) -> bool:

	if from.x != to.x and from.y != to.y: return false

	return is_path_clear(from, to)

func is_legal_king_move(from: Vector2i, to: Vector2i) -> bool:

	return abs(to.x - from.x) <= 1 and abs(to.y - from.y) <= 1

func is_path_clear(from: Vector2i, to: Vector2i) -> bool:

	var dx = sign(to.x - from.x)

	var dy = sign(to.y - from.y)

	var x = from.x + dx

	var y = from.y + dy

	while x != to.x or y != to.y:

		if get_piece(Vector2i(x, y)): return false

		x += dx

		y += dy

	return true

func get_piece(pos: Vector2i) -> ChessPiece:

	if not is_valid_pos(pos): return null

	return board[pos.y][pos.x]

func is_valid_pos(pos: Vector2i) -> bool:

	return pos.x >= 0 and pos.x < 8 and pos.y >= 0 and pos.y < 8



func generate_basic_san(_from: Vector2i, to: Vector2i, _captured: bool) -> String:
	var piece = get_piece(to)
	var letter = ""
	match piece.type:
		PieceType.KNIGHT: letter = "N"
		PieceType.BISHOP: letter = "B"
		PieceType.ROOK: letter = "R"
		PieceType.QUEEN: letter = "Q"
		PieceType.KING: letter = "K"
	var files = "abcdefgh"
	return letter + files[to.x] + str(8 - to.y)

func check_game_over():
	pass  # Expand later




func has_piece_at(pos: Vector2i) -> bool:
	return get_piece(pos) != null
