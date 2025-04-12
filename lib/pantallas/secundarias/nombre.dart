import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../navegacion/navigation.dart';

class Nombre extends StatefulWidget {
  const Nombre({super.key, required this.title});

  final String title;

  @override
  State<Nombre> createState() => _MyContenidoPageState();
}

class _MyContenidoPageState extends State<Nombre> {
  late Navigation navigation;
  late TextEditingController nombrecontroller;
  late String idioma;

  Future<void> cargarIdioma() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      idioma = prefs.getString('idioma') ?? 'Español';
    });
  }

  @override
  void initState() {
    super.initState();
    navigation = Navigation(context);
    nombrecontroller = TextEditingController();
    loadPassword();
    cargarIdioma();
  }

  @override
  void dispose() {
    nombrecontroller.dispose();
    super.dispose();

  }

  Future<void> loadPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? nombreguardado = prefs.getString('nombre');
    if (nombreguardado != null) {
      nombrecontroller.text = nombreguardado;
    }else{
      nombrecontroller.text = "Empresa";

    }
  }

  Future<void> savePassword(String newPassword) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('nombre', newPassword);
  }

  void showToastMessage(String message) => Fluttertoast.showToast(
    msg: message,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          idioma == 'Español' ? 'NOMBRE DE EMPRESA' : 'COMPANY NAME',
          style: const TextStyle(fontSize: 20, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF3304F8),
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
                        idioma == 'Español' ? 'Introduce el nuevo nombre' : 'Enter the new name',
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
                          controller: nombrecontroller,
                          style: const TextStyle(color: Colors.black),
                          cursorColor: Colors.lightBlue,
                          decoration: const InputDecoration(
                            border: InputBorder.none,

                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () async {
                          String newPassword = nombrecontroller.text;
                          await savePassword(newPassword);
                          showToastMessage(idioma == 'Español' ? 'Nombre cambiado' : 'Name changed',);
                          },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          backgroundColor: const Color(0xFF5E46C2),
                          padding: const EdgeInsets.all(20),
                        ),
                        child: Text(
                          idioma == 'Español' ? 'CAMBIAR NOMBRE' : 'CHANGE NAME',
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

