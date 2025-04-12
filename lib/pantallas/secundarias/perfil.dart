// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../database/DatabaseProvider.dart';
import '../../navegacion/navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Perfil extends StatefulWidget {
  const Perfil({super.key, required this.title, required this.anteriorpantalla});

  final String title;
  final String anteriorpantalla;

  @override
  State<Perfil> createState() => _MyAdministradorPageState();
}

class _MyAdministradorPageState extends State<Perfil> {
  final databaseProvider = DatabaseProvider();
  late Navigation navigation;

  String emailtext = "Desconocido";
  String contrasena = "Desconocido";
   String idioma = "Español" ;
  bool _showPassword = false;

  @override
  void initState() {
    loaddata();
    super.initState();
    navigation = Navigation(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void showToastMessage(String message) =>
      Fluttertoast.showToast(msg: message);

  Future<void> loaddata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    String? contrasenaemail = prefs.getString('contrasena_email');
    String? idiomaactual = prefs.getString('idioma');

    setState(() {
      emailtext = email ?? 'Desconocido';
      contrasena = contrasenaemail ?? 'Desconocido';
      idioma = idiomaactual ?? 'Español';
    });
  }

  Future<void> cambiarIdioma(String newValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('idioma', newValue);
    setState(() {
      idioma = newValue;
    });
    showToastMessage(idioma == 'Español' ? 'Idioma cambiado' : 'Language changed');
  }


  Future<void> cambiarContrasena() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    String? email = auth.currentUser?.email;
    if (email != null) {
      try {
        await auth.sendPasswordResetEmail(email: email);
        showToastMessage(                      idioma == 'Español' ?
        'Correo electronico enviado para cambiar la contraseña' : 'Email sent to change password',
        );
      } catch (error) {
        showToastMessage(       idioma == 'Español' ?
        'Error al enviar el correo de restauracion $error' : 'Error sending restoration email: $error');
      }
    } else {
      showToastMessage(               idioma == 'Español' ?
      'No se pudo enviar el correo de restauracion' : 'The restoration email could not be sent',
      );
    }
  }

  Future<void> eliminarCuenta() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(  idioma == 'Español' ?
          'Eliminar cuenta' : 'Delete account'),
          content: Text(  idioma == 'Español' ?
          'Estas seguro de eliminar la cuenta' : 'Are you sure to delete the account?'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                FirebaseAuth auth = FirebaseAuth.instance;
                try {
                  await auth.currentUser?.delete();
                  showToastMessage( idioma == 'Español' ?
                  'Cuenta eliminada ' : 'Account deleted');
                } catch (error) {
                  showToastMessage( idioma == 'Español' ?
                  'Error al eliminar la cuenta $error' : 'Error deleting account $error');
                }
                Navigator.of(context).pop();
                navigation.navigateToRegistro();
              },
              child: Text(idioma == 'Español' ?
              'Si' : 'Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(idioma == 'Español' ?
              'Cancelar' : 'Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> salir() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(  idioma == 'Español' ?
          'Salir de la sesion ' : 'Sign off'),
          content: Text(  idioma == 'Español' ?
          'Estas seguro de salir de la sesión?' : 'Are you sure to sign off?'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                navigation.navigateToRegistro();
                showToastMessage( idioma == 'Español' ?
                'Has salido de la sesion  ' : 'Logged off');
              },
              child: Text(idioma == 'Español' ?
              'Si' : 'Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(idioma == 'Español' ?
              'Cancelar' : 'Cancel'),
            ),
          ],
        );
      },
    );
  }
  Future<bool> _onWillPop() async {
    if (widget.anteriorpantalla == 'Menu') {
           navigation.navigateToMenu();
    } else {
      navigation.navigateToAjustes();
    }
    return false;
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop:_onWillPop,
        child: Scaffold(
        appBar: AppBar(
        title: Text(
        idioma== "Español" ? "PERFIL" : "PROFILE",
        style: const TextStyle(fontSize: 30, color: Colors.white),
    ),
    centerTitle: true,
    backgroundColor: const Color(0xFF3304F8),
    ),
    body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Color(0xFF7E57C2)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 1.8],
                tileMode: TileMode.clamp,
              ),
            ),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(
                    'imagenes/profile.png',
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                ),
                const Text(
                  'EMAIL',
                  style: TextStyle(
                    color: Color(0xFF3304F8),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  emailtext,
                  style: const TextStyle(
                    color: Color(0xFF1E0B89),
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  idioma == 'Español' ? 'CONTRASEÑA' : 'PASSWORD',
                  style: const TextStyle(
                    color: Color(0xFF3304F8),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _showPassword ? contrasena : '**********',
                        style: const TextStyle(
                          color: Color(0xFF1E0B89),
                          fontSize: 20,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: 300,
                  height: 70,
                  child: ElevatedButton(
                    onPressed: cambiarContrasena,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: const Color(0xFF5E46C2),
                      padding: const EdgeInsets.all(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.password_sharp, color: Colors.white,),
                        const SizedBox(width: 10),
                        Text(
                          idioma == 'Español' ? 'CAMBIAR CONTRASEÑA' : 'CHANGE PASSWORD',
                          style: const TextStyle(fontSize: 15, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  idioma == 'Español' ? 'IDIOMA' : 'LANGUAGE',
                  style: const TextStyle(
                    color: Color(0xFF3304F8),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  idioma == 'Español' ? 'Idioma actual: ' : 'Actual language',
                  style: const TextStyle(
                    color: Color(0xFF1E0B89),
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButton<String>(
                  dropdownColor: Colors.blueAccent,
                  value: idioma,
                  onChanged: (String? newValue) {
                    setState(() {
                      idioma = newValue!;
                      cambiarIdioma(newValue);
                    });
                  },
                  items: <String>['Español', 'Inglés'].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(color: Color(0xFF1E0B89), fontSize: 20,),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 30),
                Text(
                  idioma == 'Español' ? 'SEGURIDAD' : 'SECURITY',

                  style: const TextStyle(
                    color: Color(0xFF3304F8),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: 300,
                  height: 70,
                  child: ElevatedButton(
                    onPressed: salir,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: const Color(0xFF5E46C2),
                      padding: const EdgeInsets.all(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout, color: Colors.white,),
                        const SizedBox(width: 10),
                        Text(idioma == 'Español' ? 'CERRAR SESION' : 'LOG OFF', style: const TextStyle(fontSize: 15, color: Colors.white),),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),
                SizedBox(
                  width: 300,
                  height: 70,
                  child: ElevatedButton(
                    onPressed: eliminarCuenta,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: const Color(0xFFD50000),
                      padding: const EdgeInsets.all(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.delete, color: Colors.white,),
                        const SizedBox(width: 10),
                        Text(
                          idioma == 'Español' ? 'ELIMINAR CUENTA' : 'DELETE ACCOUNT',
                          style: const TextStyle(fontSize: 15, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      );

  }
}
