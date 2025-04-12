import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../navegacion/navigation.dart';

class Contrasena extends StatefulWidget {
  const Contrasena({super.key, required this.title});

  final String title;

  @override
  State<Contrasena> createState() => _MyContenidoPageState();
}

class _MyContenidoPageState extends State<Contrasena> {
  late Navigation navigation;
  late TextEditingController _passwordController;
  bool _showPassword = false;
  late String idioma;

  @override
  void initState() {
    super.initState();
    navigation = Navigation(context);
    _passwordController = TextEditingController();
    loadPassword();
    cargarIdioma();
  }

  Future<void> cargarIdioma() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      idioma = prefs.getString('idioma') ?? 'Español';
    });
  }


  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> loadPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedPassword = prefs.getString('password');
    if (savedPassword != null) {
      _passwordController.text = savedPassword;
    }
  }

  Future<void> savePassword(String newPassword) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('password', newPassword);
  }

  void showToastMessage(String message) => Fluttertoast.showToast(
    msg: message,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          idioma == 'Español' ? 'CONTRASEÑA ADMIN' : 'ADMIN PASSWORD',
          style: const TextStyle(fontSize: 20, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF5E46C2),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height - kToolbarHeight,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Color(0xFF7E57C2)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 1.8],
              tileMode: TileMode.clamp,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 80),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        idioma == 'Español' ? 'Introduce la nueva contraseña de administrador' : 'Introduce the new admin password',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.black, fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: Colors.black),
                        ),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: !_showPassword,
                          style: const TextStyle(color: Colors.black),
                          cursorColor: Colors.lightBlue,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _showPassword = !_showPassword;
                                });
                              },
                              icon: Icon(
                                _showPassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () async {
                          String newPassword = _passwordController.text;
                          await savePassword(newPassword);
                          showToastMessage( idioma == 'Español' ? 'Contraseña cambiada' : 'Password changed',);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          backgroundColor: const Color(0xFF5E46C2),
                          padding: const EdgeInsets.all(20),
                        ),
                        child: Text(
                          idioma == 'Español' ? 'CAMBIAR CONTRASEÑA DE ADMIN' : 'CHANGE THE ADMIN PASSWORD',
                          style: const TextStyle(fontSize: 15, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

