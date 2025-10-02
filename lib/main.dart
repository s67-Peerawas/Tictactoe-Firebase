import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'domain/models.dart';
import 'data/game_repository.dart';
import 'data/local_repository.dart';
import 'data/firestore_repository.dart';
import 'ui/game_controller.dart';
import 'ui/game_board.dart';

const useFirestore = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  GameRepository repo;
  if (useFirestore) {
    await Firebase.initializeApp();
    repo = FirestoreGameRepository(FirebaseFirestore.instance);
  } else {
    repo = LocalGameRepository();
  }

  runApp(MyApp(repo: repo));
}

class MyApp extends StatelessWidget {
  final GameRepository repo;
  const MyApp({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    final gameId = "test_game";
    final playerId = UniqueKey().toString().substring(0, 5);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => GameController(
            repo: repo,
            gameId: gameId,
            playerId: playerId,
          )..init(),
        ),
      ],
      child: const MaterialApp(
        home: SafeArea(child: GameBoard()),
      ),
    );
  }
}
