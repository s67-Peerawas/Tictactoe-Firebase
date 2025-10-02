// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Domain / Data / UI (ชื่อไฟล์ตามโปรเจกต์เดิมของคุณ)
import 'domain/models.dart';
import 'data/game_repository.dart';
import 'data/local_repository.dart';
import 'data/firestore_repository.dart';
import 'ui/game_controller.dart';
import 'ui/game_board.dart';

// สลับ true = ใช้ Firestore จริง, false = โหมดออฟไลน์ (Local)
const useFirestore = true;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  GameRepository repo;

  if (useFirestore) {
    // ถ้ายังไม่มี firebase_options.dart อยู่บนเครื่อง
    // บรรทัดนี้พอใช้งานได้ชั่วคราวบน Android:
    await Firebase.initializeApp();

    // ถ้าคุณรัน flutterfire configure แล้ว ให้ใช้แบบนี้แทน:
    // import 'firebase_options.dart';
    // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
    // ตั้งค่าห้อง/ผู้เล่นสำหรับทดลอง
    // (จะให้ผู้ใช้พิมพ์เองภายหลังก็ได้)
    const gameId = "test_game";
    final playerId = 'player-${DateTime.now().millisecondsSinceEpoch}';

    return MultiProvider(
      providers: [
        // ถ้าอยากให้ส่วนอื่นๆ อ่าน repo ตรงๆ จาก context ได้ด้วย
        Provider<GameRepository>.value(value: repo),

        // GameController ของโปรเจกต์คุณคอนสตรักเตอร์รับ (repo, gameId, playerId)
        ChangeNotifierProvider(
          create: (_) => GameController(
            repo: repo,
            gameId: gameId,
            playerId: playerId,
          )..init(), // ถ้า controller มี init() ให้เรียกหนึ่งครั้งตอนเริ่ม
        ),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SafeArea(child: GameBoard()),
      ),
    );
  }
}
