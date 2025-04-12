// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../database/DatabaseProvider.dart';
import '../../navegacion/navigation.dart';
class Administrador extends StatefulWidget {
  const Administrador({super.key, required this.title, required this.anteriorpantalla});

  final String title;
  final String anteriorpantalla;

  @override
  State<Administrador> createState() => _MyAdministradorPageState();
}

class _MyAdministradorPageState extends State<Administrador> {
  final databaseProvider = DatabaseProvider();
  late Navigation navigation;
  late TextEditingController _passwordController;
  bool subidaFirebase = false;
  bool subidaFTP = false;
  bool permitirProductosDesconocidos = false;
  bool permitirCambiarNombre = false;
  bool mostrarCantidades = true;
  bool mostrarInventario = true;
  bool mostrarSubirDatos = true;
  bool atajosadministrador = false;

  String idioma = "Español";


  Future<void> cargarIdioma() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      idioma = prefs.getString('idioma') ?? 'Español';
    });
  }

  @override
  void initState() {
    super.initState();
    cargarIdioma();
    navigation = Navigation(context);
    _passwordController = TextEditingController();
    loadSettings();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void showToastMessage(String message) => Fluttertoast.showToast(
    msg: message,
  );

  void loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      subidaFirebase = prefs.getBool('subidaFirebase') ?? false;
      subidaFTP = prefs.getBool('subidaFTP') ?? false;
      permitirProductosDesconocidos =
          prefs.getBool('permitirProductosDesconocidos') ?? false;
      permitirCambiarNombre = prefs.getBool('permitirCambiarNombre') ?? false;
      mostrarCantidades = prefs.getBool('mostrarCantidades') ?? true;
      mostrarInventario = prefs.getBool('mostrarInventario') ?? true;
      mostrarSubirDatos = prefs.getBool('mostrarSubirDatos') ?? true;
      atajosadministrador = prefs.getBool('atajosadministrador')?? false;
    });
  }

  void saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('subidaFirebase', subidaFirebase);
    prefs.setBool('subidaFTP', subidaFTP);
    prefs.setBool('permitirProductosDesconocidos', permitirProductosDesconocidos);
    prefs.setBool('permitirCambiarNombre', permitirCambiarNombre);
    prefs.setBool('mostrarCantidades', mostrarCantidades);
    prefs.setBool('mostrarInventario', mostrarInventario);
    prefs.setBool('mostrarSubirDatos', mostrarSubirDatos);
    prefs.setBool('atajosadministrador', atajosadministrador);
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
        widget.title,
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
            Text(
              idioma == 'Español' ? 'SUBIDA DE DATOS' : 'DATA UPLOAD',
              style: const TextStyle(
                color: Color(0xFF3304F8),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            SwitchListTile(
              title: Text(idioma == 'Español' ? 'Subida de datos instantánea en Firebase' : 'Instant Firebase data upload'),
              value: subidaFirebase,
              onChanged: (value) {
                setState(() {
                  subidaFirebase = value;
                  saveSettings();
                });
              },
            ),
            const SizedBox(height: 30),
            SwitchListTile(
              title: Text(idioma == 'Español' ? 'Añadir FTP como subida de datos' : 'Add FTP as data upload'),
              value: subidaFTP,
              onChanged: (value) {
                setState(() {
                  subidaFTP = value;
                  saveSettings();
                });
              },
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 300,
              height: 70,
              child: ElevatedButton(
                onPressed: navigation.navigateToFTP,
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
                    const Icon(Icons.electrical_services, color: Colors.white,),
                    const SizedBox(width: 10),
                    Text(
                      idioma == 'Español' ? 'CONFIGURAR FTP' : 'CONFIGURE FTP',
                      style: const TextStyle(fontSize: 15, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 60),
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
                onPressed: navigation.navigateToContrasena,
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
                      idioma == 'Español' ? 'CAMBIAR CONTRASEÑA ADMIN' : 'CHANGE ADMIN PASSWORD',
                      style: const TextStyle(fontSize: 15, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            SwitchListTile(
              title: Text(idioma == 'Español' ? 'Permitir cambiar nombre' : 'Allow change name'),
              value: permitirCambiarNombre,
              onChanged: (value) {
                setState(() {
                  permitirCambiarNombre = value;
                  saveSettings();
                });
              },
            ),
            const SizedBox(height: 30),
            SwitchListTile(
              title: Text(idioma == 'Español' ? 'Permitir productos desconocidos' : 'Allow unknown products'),
              value: permitirProductosDesconocidos,
              onChanged: (value) {
                setState(() {
                  permitirProductosDesconocidos = value;
                  saveSettings();
                });
              },
            ),
            const SizedBox(height: 30),
            SwitchListTile(
              title: Text(idioma == 'Español' ? 'Rol de Administrador' : 'Admin Rol'),
              value: atajosadministrador,
              onChanged: (value) {
                setState(() {
                  atajosadministrador = value;
                  saveSettings();
                });
              },
            ),
            const SizedBox(height: 60),
            Text(
              idioma == 'Español' ? 'OTROS' : 'OTHERS',
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
                onPressed: navigation.navigateToNombre,
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
                    const Icon(Icons.account_balance_outlined, color: Colors.white,),
                    const SizedBox(width: 10),
                    Text(
                      idioma == 'Español' ? 'CAMBIAR NOMBRE EMPRESA' : 'CHANGE COMPANY NAME',
                      style: const TextStyle(fontSize: 15, color: Colors.white),
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
                onPressed: navigation.navigateToTotalAdministrador,
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
                    const Icon(Icons.account_tree, color: Colors.white,),
                    const SizedBox(width: 10),
                    Text(
                      idioma == 'Español' ? 'TOTAL ADMINISTRADOR' : 'ADMINISTRATOR TOTAL',
                      style: const TextStyle(fontSize: 15, color: Colors.white, ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
            SwitchListTile(
              title: Text(idioma == 'Español' ? 'Mostrar Cantidades' : 'Show Quantities'),
              value: mostrarCantidades,
              onChanged: (value) {
                setState(() {
                  mostrarCantidades = value;
                  saveSettings();
                });
              },
            ),
            const SizedBox(height: 30),
            SwitchListTile(
              title: Text(idioma == 'Español' ? 'Mostrar Inventario' : 'Show Inventory'),
              value: mostrarInventario,
              onChanged: (value) {
                setState(() {
                  mostrarInventario = value;
                  saveSettings();
                });
              },
            ),
            const SizedBox(height: 30),
            SwitchListTile(
              title: Text(idioma == 'Español' ? 'Mostrar Subir Datos' : 'Show Data Upload'),
              value: mostrarSubirDatos,
              onChanged: (value) {
                setState(() {
                  mostrarSubirDatos = value;
                  saveSettings();
                });
              },
            ),
          ],
        ),
      ),
        )
    );
  }
}
