// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../database/DatabaseProvider.dart';
import '../../navegacion/navigation.dart';
import '../../PDF/PDFGenerator.dart';

class Ajustes extends StatefulWidget {
  const Ajustes({super.key, required this.title});

  final String title;

  @override
  State<Ajustes> createState() => _MyAjustesPageState();
}

class _MyAjustesPageState extends State<Ajustes> {
  final databaseProvider = DatabaseProvider();
  final pdf = PDFGenerator();
  late Navigation navigation;
  late TextEditingController _passwordController;
  late String idioma;
  bool atajos = false;


  Future<void> cargarIdioma() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      idioma = prefs.getString('idioma') ?? 'Español';
    });
  }
  Future<void> loadAtajos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    atajos = prefs.getBool('atajosadministrador')?? false;

  }


  @override
  void initState() {
    super.initState();
    navigation = Navigation(context);
    _passwordController = TextEditingController();
    cargarIdioma();
    loadAtajos();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void showToastMessage(String message) => Fluttertoast.showToast(
    msg: message,
  );

  String _contrasenaGuardada = "";

  void cargarContrasena() async {
    Map<String, String> contrasenaMap = await returnContrasena();
    _contrasenaGuardada = contrasenaMap['password'] ?? "";
  }

  Future<Map<String, String>> returnContrasena() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'password': prefs.getString('password') ?? "",
    };
  }

  void eliminarDatos() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:  Text(idioma == 'Español' ?
          'Eliminar memoria local' :
          'Delete local memory',),
          content:  Text(idioma == 'Español' ?
          'Desea eliminar los datos locales de cantidades e inventario?' :
          'Do you want to delete local quantity and inventory data?',),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                databaseProvider.borrarTodoCantidad();
                databaseProvider.borrarTodoElInventario();
                showToastMessage(idioma == 'Español' ?
                'Datos eliminados correctamente' :
                'Successfully deleted data',);
              },
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:  Text(idioma == 'Español' ?
              'Cancelar' :
              'Cancel',),
            ),
          ],
        );
      },
    );
  }

  void showAdminPasswordDialog() {
    cargarContrasena();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:  Text(idioma == 'Español' ?
          ' Ingrese la contraseña de administrador' :
          'Enter the administrator password ',),
          content: TextField(
            controller: _passwordController,
            obscureText: true,
            decoration:  InputDecoration(
              hintText: idioma == 'Español' ?
              ' Contraseña' :
              'Password ',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_passwordController.text == _contrasenaGuardada) {
                  Navigator.of(context).pop();
                  navigation.navigateToAdministrador("Ajustes");
                  _passwordController.clear();
                } else {
                  Navigator.of(context).pop();
                  showToastMessage(idioma == 'Español' ?
                  'Contraseña incorrecta' :
                  'Incorrect password',);
                  _passwordController.clear();
                }
              },
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                _passwordController.clear();
                Navigator.of(context).pop();
              },
              child:  Text(idioma == 'Español' ?
              'Cancelar' :
              'Cancel',),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        navigation.navigateToMenu();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            idioma == 'Español' ? 'AJUSTES' : 'SETTINGS',
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 50),
                SizedBox(
                  width: 300,
                  height: 70,
                  child: ElevatedButton(
                    onPressed: (){
                      if(atajos){
                        navigation.navigateToAdministrador("Ajustes");
                      }else{
                       showAdminPasswordDialog();
                      }
                    },
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
                        const Icon(Icons.admin_panel_settings, color: Colors.white,),
                        const SizedBox(width: 10),
                         Text(
                          idioma == 'Español' ? 'ADMINISTRADOR' : 'ADMINISTRATOR',
                          style: const TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: 300,
                  height: 70,
                  child: ElevatedButton(
                    onPressed: () {navigation.navigateToPerfil("AJUSTES");},
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
                        const Icon(Icons.account_circle, color: Colors.white,),
                        const SizedBox(width: 10),
                         Text(
                          idioma == 'Español' ? 'PERFIL' : 'PROFILE',
                          style: const TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ), const SizedBox(height: 30),
                SizedBox(
                  width: 300,
                  height: 70,
                  child: ElevatedButton(
                    onPressed: navigation.navigateToTotal,
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
                        const Icon(Icons.account_tree_outlined, color: Colors.white,),
                        const SizedBox(width: 10),
                         Text(
                          idioma == 'Español' ? 'MOSTRAR TOTAL' : 'SEE TOTAL',
                          style: const TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: 300,
                  height: 70,
                  child: ElevatedButton(
                    onPressed: () {
                      pdf.generatePDF(context);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: const Color(0xFF5E46C2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.picture_as_pdf_outlined, color: Colors.white,),
                        const SizedBox(width: 10),
                         Text(
                          idioma == 'Español' ? 'COMPARTIR PDF ' : 'SHARE PDF',
                          style: const TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),
                SizedBox(
                  width: 300,
                  height: 70,
                  child: ElevatedButton(
                    onPressed: eliminarDatos,
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
                        const Icon(Icons.restore_from_trash_outlined, color: Colors.redAccent,),
                        const SizedBox(width: 10),
                         Text(
                          idioma == 'Español' ? 'ELIMINAR DATOS' : 'DELETE DATA',
                          style: const TextStyle(fontSize: 20, color: Colors.redAccent),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
