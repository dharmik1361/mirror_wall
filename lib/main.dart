import 'package:flutter/material.dart';
import 'package:mirror_wall/model/all.dart';
import 'package:mirror_wall/view/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences pref;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  pref = await SharedPreferences.getInstance();

  runApp(MirrorApp());
}

class MirrorApp extends StatelessWidget {
  const MirrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => BrowserModel(),)
    ],builder: (context, child) {
      return MaterialApp(
        title: "Mirror App",
        debugShowCheckedModeBanner: false,
        home: MirrorScreen(),
      );
    },
    );
  }
}
