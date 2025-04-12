// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../navegacion/navigation.dart';

class FTPConfig extends StatefulWidget {
  const FTPConfig({super.key, required this.title});

  final String title;

  @override
  State<FTPConfig> createState() => _MyContenidoPageState();
}

class _MyContenidoPageState extends State<FTPConfig> {
  late Navigation navigation;
  late TextEditingController ip_controller;
  late TextEditingController port_controller;
  late TextEditingController user_controller;
  bool _showPassword = false;
  late String idioma;
  late TextEditingController password_controller;

  @override
  void initState() {
    super.initState();
    navigation = Navigation(context);
    ip_controller = TextEditingController();
    port_controller = TextEditingController();
    user_controller = TextEditingController();
    password_controller = TextEditingController();
    loadinfo();
    cargarIdioma();
  }

  @override
  void dispose() {
    ip_controller.dispose();
    super.dispose();
  }

  Future<void> cargarIdioma() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      idioma = prefs.getString('idioma') ?? 'Español';
    });
  }

  Future<void> saveData(String newIP,int newPort,String newUser, String newPassword) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('ip', newIP);
    await prefs.setInt('port', newPort);
    await prefs.setString('user', newUser);
    await prefs.setString('password_ftp', newPassword);


  }

  Future<void> loadinfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? ip = prefs.getString('ip');
    if (ip != null) {
      ip_controller.text = ip;
    }else{
      ip_controller.text = '127.0.0.1';
    }

    int? port = prefs.getInt('port');
    if (port != null) {
      port_controller.text = port.toString();
    }else{
      port_controller.text = "21";
    }

    String? user = prefs.getString('user');
    if (user != null) {
      user_controller.text = user;
    }else{
      user_controller.text = "user";
    }

    String? password = prefs.getString('password_ftp');
    if (password != null) {
      password_controller.text = password;
    }else{
      password_controller.text = "password";
    }

  }
  void showToastMessage(String message) => Fluttertoast.showToast(
    msg: message,
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
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
                      const Text(
                        'IP',
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: Colors.black),
                        ),
                        child: TextField(
                          controller: ip_controller,
                          style: const TextStyle(color: Colors.black),
                          cursorColor: Colors.lightBlue,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                       idioma=='Español' ? 'Puerto' : 'Port',
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

                          keyboardType: TextInputType.number,
                          controller: port_controller,
                          style: const TextStyle(color: Colors.black),
                          cursorColor: Colors.lightBlue,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        idioma=='Español' ? 'Usuario' : 'User',
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
                          controller: user_controller,
                          style: const TextStyle(color: Colors.black),
                          cursorColor: Colors.lightBlue,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      ), const SizedBox(height: 20),
                      Text(
                        idioma=='Español' ? 'Contraseña' : 'Password',
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
                          obscureText: !_showPassword,
                          controller: password_controller,
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
                          String newIP = ip_controller.text;
                          String newUsuario = user_controller.text;
                          String newPassword = password_controller.text;
                          int newPuerto = int.tryParse(port_controller.text) ?? 21;

                          await saveData(newIP, newPuerto, newUsuario,newPassword);
                          showToastMessage(idioma=='Español' ? 'FTP Cambiado' : 'FTP Config changedd',);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          backgroundColor: const Color(0xFF3304F8),
                          padding: const EdgeInsets.all(20),
                        ),
                        child: Text(
                          idioma=='Español' ? 'CAMBIAR CONFIGURACION' : 'CHANGE FTP CONFIG',
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

