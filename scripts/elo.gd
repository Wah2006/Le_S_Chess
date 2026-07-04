# scripts/elo.gd
extends Node

const K_FACTOR = 32  # Standard K-factor for chess

# Calculate new Elo rating
func calculate_new_elo(player_elo: float, opponent_elo: float, score: float) -> float:
	"""
	score: 1.0 = win, 0.5 = draw, 0.0 = loss
	"""
	var expected_score = 1.0 / (1.0 + pow(10, (opponent_elo - player_elo) / 400.0))
	var new_elo = player_elo + K_FACTOR * (score - expected_score)
	return round(new_elo)  # Round to whole number

# Example usage:
# new_white_elo = elo_manager.calculate_new_elo(white_elo, black_elo, 1.0)