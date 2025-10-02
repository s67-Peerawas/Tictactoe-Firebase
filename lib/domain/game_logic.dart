import 'models.dart';

String checkWinner(List<List<String>> b) {
  for (int i = 0; i < boardSize; i++) {
    if (b[i][0] != "" && b[i][0] == b[i][1] && b[i][1] == b[i][2]) return b[i][0];
    if (b[0][i] != "" && b[0][i] == b[1][i] && b[1][i] == b[2][i]) return b[0][i];
  }
  if (b[0][0] != "" && b[0][0] == b[1][1] && b[1][1] == b[2][2]) return b[0][0];
  if (b[0][2] != "" && b[0][2] == b[1][1] && b[1][1] == b[2][0]) return b[0][2];

  final filled = b.every((row) => row.every((v) => v != ""));
  return filled ? "Tie" : "";
}

bool isInsideBoard(int row, int col) =>
    row >= 0 && row < boardSize && col >= 0 && col < boardSize;

int rcToIndex(int row, int col) => row * boardSize + col;
