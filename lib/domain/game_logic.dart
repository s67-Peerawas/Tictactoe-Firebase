import 'mark.dart';

class GameLogic {
  final int gridSize;
  final String emptyCell;

  List<Mark> marks = [];
  String currentTurn = 'O';
  bool isGameOver = false;
  String winner = ''; // '', 'X', 'O', 'DRAW'

  GameLogic({
    this.gridSize = 3,
    this.emptyCell = '',
  });

  void clearBoard() {
    marks = [];
    currentTurn = 'O';
    isGameOver = false;
    winner = '';
  }

  bool placeMark(int row, int col, {String? type}) {
    if (isGameOver) return false;
    if (row < 0 || col < 0 || row >= gridSize || col >= gridSize) return false;
    final occupied = marks.any((m) => m.row == row && m.col == col);
    if (occupied) return false;

    final t = type ?? currentTurn;
    marks = [...marks, Mark(row: row, col: col, type: t)];

    final w = _winnerOf();
    if (w.isNotEmpty) {
      winner = w;
      isGameOver = true;
    } else if (_isDraw()) {
      winner = 'DRAW';
      isGameOver = true;
    } else {
      currentTurn = (currentTurn == 'O') ? 'X' : 'O';
    }
    return true;
  }

  String _winnerOf() {
    final n = gridSize;
    final board = List.generate(n, (_) => List.filled(n, emptyCell));
    for (final m in marks) {
      board[m.row][m.col] = m.type;
    }

    bool eq(List<String> line) =>
        line.isNotEmpty && line[0] != emptyCell && line.every((e) => e == line[0]);

    for (int i = 0; i < n; i++) {
      if (eq(board[i])) return board[i][0];
      final col = [for (int r = 0; r < n; r++) board[r][i]];
      if (eq(col)) return col[0];
    }
    final d1 = [for (int i = 0; i < n; i++) board[i][i]];
    if (eq(d1)) return d1[0];
    final d2 = [for (int i = 0; i < n; i++) board[i][n - 1 - i]];
    if (eq(d2)) return d2[0];
    return '';
  }

  bool _isDraw() {
    return marks.length >= gridSize * gridSize && _winnerOf().isEmpty;
  }
}


