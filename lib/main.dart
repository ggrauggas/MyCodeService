import 'package:flutter/material.dart';
import 'package:mycodeservice/pantallas/principal/RegistroPage.dart';
import 'package:provider/provider.dart';
import 'package:mycodeservice/database/DatabaseProvider.dart';
import 'package:mycodeservice/pantallas/secundarias/LoadingSceen.dart';
import 'package:firebase_core/firebase_core.dart';


Future<void> main() async {
 WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
   options: const FirebaseOptions(
       apiKey: "AIzaSyDyGDFDeiKMp-x7PvlUMgW9DnMvKAjHcec",
       appId: "1:808493454507:android:51133669e59f43882213ee",
       messagingSenderId: "808493454507",
       projectId: "mycodeservice-516e1"));

 runApp(const MyCodeService());
}

class MyCodeService extends StatelessWidget {
  const MyCodeService({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DatabaseProvider(),
      child: MaterialApp(
        title: 'MyCodeService',
        theme: ThemeData(),
        home: const AppInitializer(),
      ),
    );
  }
}
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  _AppInitializerState createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  late DatabaseProvider _databaseProvider;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    _databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);
    await _databaseProvider.initialize();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    if (_databaseProvider.initialized) {
      return const RegistroPage(title: "REGISTRO");
    } else {
      return const LoadingScreen();
    }
  }
}
