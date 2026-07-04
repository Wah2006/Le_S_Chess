# Local Chess ♟️

A **local two-player chess desktop application** built with Godot 4.

## Features

- **Local Hotseat Multiplayer** (Player 1 vs Player 2 on the same device)
- **Full Chess Rules** from scratch (no external engine)
- **Drag & Drop** piece movement
- **Standard Algebraic Notation (SAN)** move logging
- **No Undo** (strict rules as per SRS)
- **Elo Rating System** with automatic updates
- **SQLite Database** for match history and leaderboard
- **Sound Effects** for moves, captures, check, and game end
- **Dark Grey & White** chessboard theme

## Screenshots


## How to Play

1. Download and extract the game.
2. Run `LocalChess.exe` (Windows).
3. Click **New Game**.
4. Use **mouse drag & drop** to move pieces.
5. View move history in the sidebar.
6. Check the Leaderboard for Elo rankings.

## Controls

- **Left Click** — Select / Move piece
- **New Game** — Start a new match
- **Leaderboard** — View top players

## Technical Details

- **Engine**: Godot 4.5+
- **Language**: GDScript
- **Database**: SQLite (godot-sqlite plugin)
- **Platform**: Windows (exported .exe)

## Project Structure

### LocalChess/
### ├── scenes/           # UI scenes
### ├── scripts/          # Game logic
### ├── assets/
### │   ├── sprites/      # Piece images
### │   └── sounds/       # Sound effects
### ├── main.tscn
### └── project.godot


## Future Enhancements

- Online multiplayer
- Multiple board themes
- PGN export
- AI opponent
- More sound packs

## License

GNU License - Feel free to use and modify.

---

**Made with ❤️ using Godot**
