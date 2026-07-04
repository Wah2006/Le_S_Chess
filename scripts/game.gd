# scripts/game.gd
extends Node

@onready var board_node = $HBoxContainer/GameContainer/Board
@onready var san_log: RichTextLabel = $HBoxContainer/SidePanel/SANLog
@onready var audio_player: AudioStreamPlayer = $AudioPlayer
@onready var db = $DB
@onready var elo_manager = $Elo
@onready var leaderboard_window = $LeaderboardWindow

var chess_logic = preload("res://scripts/chess_logic.gd").new()

var player1_id: int = 1
var player2_id: int = 2

func _ready():
	if board_node.has_signal("square_clicked"):
		board_node.square_clicked.connect(_on_square_clicked)
	new_game()

func new_game():
	chess_logic.reset_game()
	board_node.update_board(chess_logic.board)
	san_log.clear()
	san_log.append_text("[b]Move History[/b]\n")

func _on_square_clicked(pos: Vector2i):
	if chess_logic.selected_pos.x == -1:
		var piece = chess_logic.board[pos.y][pos.x]
		if piece and piece.color == chess_logic.current_turn:
			chess_logic.selected_pos = pos
			board_node.highlight_square(pos)
	else:
		var san = chess_logic.attempt_move(chess_logic.selected_pos, pos)
		if san:
			board_node.update_board(chess_logic.board)
			san_log.append_text(san + "\n")
			play_sound("move")
			
			if chess_logic.game_over:
				end_game()
		else:
			show_alert("Illegal move!")
		
		chess_logic.selected_pos = Vector2i(-1, -1)
		board_node.clear_highlights()

func end_game():
	var winner_id = -1
	if chess_logic.winner == chess_logic.PlayerColor.WHITE:
		winner_id = player1_id
	elif chess_logic.winner == chess_logic.PlayerColor.BLACK:
		winner_id = player2_id
	
	var white_elo = 1200.0
	var black_elo = 1200.0
	var score_white = 1.0 if winner_id == player1_id else 0.0 if winner_id == player2_id else 0.5
	
	var new_white = elo_manager.calculate_new_elo(white_elo, black_elo, score_white)
	var new_black = elo_manager.calculate_new_elo(black_elo, white_elo, 1.0 - score_white)
	
	db.update_elo(player1_id, new_white)
	db.update_elo(player2_id, new_black)
	db.save_game(player1_id, player2_id, winner_id, chess_logic.move_history)
	
	show_alert("Game Over!\n" + ("White Wins!" if winner_id == 1 else "Black Wins!" if winner_id == 2 else "Draw!"))

func play_sound(_type: String):
	pass # Add later

func show_alert(text: String):
	var dialog = AcceptDialog.new()
	dialog.dialog_text = text
	add_child(dialog)
	dialog.popup_centered()
