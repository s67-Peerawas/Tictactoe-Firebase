import 'models.dart';

String checkWinner(List<List<String>> b) {
  final int n = b.length;

  int r = 0;
  while (r < n) {
    final String first = b[r][0];
    if (first.isNotEmpty) {
      int c = 1;
      bool allSame = true;
      while (c < n) {
        if (b[r][c] != first) {
          allSame = false;
          break;
        }
        c++;
      }
      if (allSame) return first;
    }
    r++;
  }

  int c = 0;
  while (c < n) {
    final String first = b[0][c];
    if (first.isNotEmpty) {
      int rr = 1;
      bool allSame = true;
      while (rr < n) {
        if (b[rr][c] != first) {
          allSame = false;
          break;
        }
        rr++;
      }
      if (allSame) return first;
    }
    c++;
  }

  {
    final String first = b[0][0];
    if (first.isNotEmpty) {
      int i = 1;
      bool allSame = true;
      while (i < n) {
        if (b[i][i] != first) {
          allSame = false;
          break;
        }
        i++;
      }
      if (allSame) return first;
    }
  }

  {
    final String first = b[0][n - 1];
    if (first.isNotEmpty) {
      int i = 1;
      bool allSame = true;
      while (i < n) {
        if (b[i][n - 1 - i] != first) {
          allSame = false;
          break;
        }
        i++;
      }
      if (allSame) return first;
    }
  }

  {
    int rr = 0;
    while (rr < n) {
      int cc = 0;
      while (cc < n) {
        if (b[rr][cc].isEmpty) {
          return ""; 
        }
        cc++;
      }
      rr++;
    }
  }

  return "Tie";
}

bool isInsideBoard(int row, int col, int n) {
  return row >= 0 && row < n && col >= 0 && col < n;
}

int rcToIndex(int row, int col, int n) {
  return row * n + col;
}

