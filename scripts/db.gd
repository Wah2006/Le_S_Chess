# scripts/database.gd
extends Node

const DB_PATH = "user://local_chess.db"

var db = SQLite.new()

signal database_ready

func _ready():
	setup_database()

func setup_database():
	db.path = DB_PATH
	db.open_db()
	
	create_users_table()
	create_games_table()
	create_moves_table()
	create_leaderboard_table()
	
	ensure_default_players()
	emit_signal("database_ready")

func create_users_table():
	db.query("""
		CREATE TABLE IF NOT EXISTS users (
			user_id INTEGER PRIMARY KEY AUTOINCREMENT,
			username TEXT UNIQUE NOT NULL,
			elo_rating REAL DEFAULT 1200.0,
			created_at TEXT DEFAULT CURRENT_TIMESTAMP
		)
	""")

func create_games_table():
	db.query("""
		CREATE TABLE IF NOT EXISTS games (
			game_id INTEGER PRIMARY KEY AUTOINCREMENT,
			player1_id INTEGER,
			player2_id INTEGER,
			winner_id INTEGER,
			date TEXT DEFAULT CURRENT_TIMESTAMP,
			FOREIGN KEY(player1_id) REFERENCES users(user_id),
			FOREIGN KEY(player2_id) REFERENCES users(user_id)
		)
	""")

func create_moves_table():
	db.query("""
		CREATE TABLE IF NOT EXISTS moves (
			move_id INTEGER PRIMARY KEY AUTOINCREMENT,
			game_id INTEGER,
			player_id INTEGER,
			notation TEXT,
			move_number INTEGER,
			timestamp TEXT DEFAULT CURRENT_TIMESTAMP,
			FOREIGN KEY(game_id) REFERENCES games(game_id)
		)
	""")

func create_leaderboard_table():
	db.query("""
		CREATE TABLE IF NOT EXISTS leaderboard (
			user_id INTEGER PRIMARY KEY,
			wins INTEGER DEFAULT 0,
			losses INTEGER DEFAULT 0,
			draws INTEGER DEFAULT 0,
			FOREIGN KEY(user_id) REFERENCES users(user_id)
		)
	""")

func ensure_default_players():
	var result = db.query("SELECT COUNT(*) as count FROM users")
	if result and result[0].count == 0:
		db.query("INSERT INTO users (username) VALUES ('Player White')")
		db.query("INSERT INTO users (username) VALUES ('Player Black')")
		db.query("INSERT INTO leaderboard (user_id) VALUES (1)")
		db.query("INSERT INTO leaderboard (user_id) VALUES (2)")

func save_game(player1_id: int, player2_id: int, winner_id: int, moves: Array) -> int:
	db.query_with_bindings("""
		INSERT INTO games (player1_id, player2_id, winner_id) 
		VALUES (?, ?, ?)
	""", [player1_id, player2_id, winner_id])
	
	var game_id = db.last_insert_rowid
	
	for i in moves.size():
		var move = moves[i]
		db.query_with_bindings("""
			INSERT INTO moves (game_id, player_id, notation, move_number)
			VALUES (?, ?, ?, ?)
		""", [game_id, move.player_id, move.notation, i+1])
	
	update_stats(player1_id, player2_id, winner_id)
	return game_id

func update_stats(player1_id: int, player2_id: int, winner_id: int):
	if winner_id == player1_id:
		increment_stat(player1_id, "wins")
		increment_stat(player2_id, "losses")
	elif winner_id == player2_id:
		increment_stat(player2_id, "wins")
		increment_stat(player1_id, "losses")
	else:
		increment_stat(player1_id, "draws")
		increment_stat(player2_id, "draws")

func increment_stat(user_id: int, stat: String):
	db.query_with_bindings("UPDATE leaderboard SET " + stat + " = " + stat + " + 1 WHERE user_id = ?", [user_id])

func get_leaderboard(limit: int = 10) -> Array:
	db.query("""
		SELECT u.username, u.elo_rating, l.wins, l.losses, l.draws
		FROM users u
		JOIN leaderboard l ON u.user_id = l.user_id
		ORDER BY u.elo_rating DESC, l.wins DESC
		LIMIT ?
	""", [limit])
	return db.query_result

func update_elo(user_id: int, new_elo: float):
	db.query_with_bindings("UPDATE users SET elo_rating = ? WHERE user_id = ?", [new_elo, user_id])

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		db.close_db()
