import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'data/firestore_game_repository.dart';
import 'ui/game_page.dart';           
import 'ui/online_game_page.dart';     

const bool kUseOnline = false; // true = (Firestore), false = local

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kUseOnline) {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Widget home;

    if (kUseOnline) {
      final repo = FirestoreGameRepository(FirebaseFirestore.instance);
      const gameId = 'test_game';
      final playerId = 'player-${DateTime.now().millisecondsSinceEpoch}';
      home = OnlineGamePage(
        repo: repo,
        gameId: gameId,
        playerId: playerId,
      );
    } else {
      home = const GamePage();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TicTacToe',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: home,
    );
  }
}
