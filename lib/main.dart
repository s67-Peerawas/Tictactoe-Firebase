import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

const int boardSize = 3;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: GameBoard(
          gameId: 'test_game',
          playerId: UniqueKey().toString().substring(0, 5),
        ),
      ),
    );
  }
}

class GameBoard extends StatefulWidget {
  final String gameId;
  final String playerId;

  GameBoard({required this.gameId, required this.playerId});

  @override
  _GameBoardState createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String mySymbol = "";

  @override
  void initState() {
    super.initState();
    createGame();
  }

  Future<void> createGame() async {
    final doc = await firestore.collection('games').doc(widget.gameId).get();
    if (!doc.exists) {
      await firestore.collection('games').doc(widget.gameId).set({
        'board': List.generate(boardSize * boardSize, (_) => ""),
        'turn': 'X',
        'winner': '',
        'players': {'X': widget.playerId, 'O': ''}, // ให้ player O ว่าง
      });
      mySymbol = 'X';
    } else {
      final data = doc.data()!;
      if (data['players']['O'] == '') {
        await firestore.collection('games').doc(widget.gameId).update({
          'players.O': widget.playerId,
        });
        mySymbol = 'O';
      } else {
        mySymbol = data['players']['X'] == widget.playerId ? 'X' : 'O';
      }
    }
    setState(() {});
  }

  Future<void> resetGame() async {
    await firestore.collection('games').doc(widget.gameId).set({
      'board': List.generate(boardSize * boardSize, (_) => ""),
      'turn': 'X',
      'winner': '',
      'players': {'X': '', 'O': ''},
    });
  }

  Future<void> makeMove(List<List<String>> board, int row, int col, String turn) async {
    if (board[row][col] == "" && turn == mySymbol) {
      board[row][col] = mySymbol;
      List<String> flatBoard = board.expand((e) => e).toList();
      String winner = checkWinner(board);
      String nextTurn = (mySymbol == "X") ? "O" : "X";

      await firestore.collection("games").doc(widget.gameId).update({
        'board': flatBoard,
        'turn': winner == "" ? nextTurn : turn,
        'winner': winner,
      });
    }
  }

  String checkWinner(List<List<String>> b) {
    for (int i = 0; i < boardSize; i++) {
      if (b[i][0] != "" && b[i][0] == b[i][1] && b[i][1] == b[i][2]) return b[i][0];
      if (b[0][i] != "" && b[0][i] == b[1][i] && b[1][i] == b[2][i]) return b[0][i];
    }
    if (b[0][0] != "" && b[0][0] == b[1][1] && b[1][1] == b[2][2]) return b[0][0];
    if (b[0][2] != "" && b[0][2] == b[1][1] && b[1][1] == b[2][0]) return b[0][2];
    if (b.every((row) => row.every((v) => v != ""))) return "Tie";
    return "";
  }

  @override
  Widget build(BuildContext context) {
    double tableSize = MediaQuery.of(context).size.width;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: firestore.collection("games").doc(widget.gameId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

        final data = snapshot.data!.data() ?? {};
        final flatBoard = (data['board'] as List?)?.map((e) => e.toString()).toList() ??
            List.generate(boardSize * boardSize, (_) => "");
        final board = List.generate(
            boardSize, (row) => flatBoard.sublist(row * boardSize, (row + 1) * boardSize));

        final turn = data['turn'] ?? 'X';
        final winner = data['winner'] ?? '';

        return Scaffold(
          appBar: AppBar(title: Text("TicTacToe Firebase")),
          body: Column(
            children: [
              SizedBox(
                width: tableSize,
                height: tableSize,
                child: GestureDetector(
                  onTapDown: (details) {
                    if (winner == "" && turn == mySymbol) {
                      double cellSize = tableSize / boardSize;
                      int col = (details.localPosition.dx / cellSize).floor();
                      int row = (details.localPosition.dy / cellSize).floor();
                      makeMove(board, row, col, turn);
                    }
                  },
                  child: Stack(
                    children: [
                      CustomPaint(size: Size(tableSize, tableSize), painter: GridPainter()),
                      ...List.generate(boardSize, (row) {
                        return List.generate(boardSize, (col) {
                          final mark = board[row][col];
                          if (mark == "") return SizedBox.shrink();
                          double cellSize = tableSize / boardSize;
                          return Positioned(
                            left: col * cellSize,
                            top: row * cellSize,
                            width: cellSize,
                            height: cellSize,
                            child: Center(
                              child: Text(
                                mark,
                                style: TextStyle(
                                  fontSize: cellSize / 1.5,
                                  fontWeight: FontWeight.bold,
                                  color: mark == "O" ? Colors.blue : Colors.red,
                                ),
                              ),
                            ),
                          );
                        });
                      }).expand((e) => e).toList(),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text("You are: $mySymbol", style: TextStyle(fontSize: 24)),
              Text("Turn: $turn", style: TextStyle(fontSize: 24)),
              if (winner != "") Text("Winner: $winner", style: TextStyle(fontSize: 28)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: resetGame,
                child: Text("Reset Game"),
              ),
            ],
          ),
        );
      },
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3;

    double cellWidth = size.width / boardSize;
    double cellHeight = size.height / boardSize;

    for (int i = 0; i <= boardSize; i++) {
      canvas.drawLine(Offset(0, cellHeight * i), Offset(size.width, cellHeight * i), paint);
      canvas.drawLine(Offset(cellWidth * i, 0), Offset(cellWidth * i, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
