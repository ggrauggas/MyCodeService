// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mycodeservice/pantallas/principal/administrador.dart';
import 'package:mycodeservice/pantallas/principal/menu.dart';
import 'package:mycodeservice/pantallas/secundarias/total.dart';
import 'package:mycodeservice/pantallas/principal/ajustes.dart';
import 'package:mycodeservice/pantallas/principal/cantidades.dart';
import 'package:mycodeservice/pantallas/secundarias/total_administrador.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pantallas/secundarias/FTPConfig.dart';
import '../pantallas/principal/RegistroPage.dart';
import '../pantallas/secundarias/contraseña.dart';
import '../pantallas/principal/inventario.dart';
import '../pantallas/secundarias/nombre.dart';
import '../pantallas/secundarias/perfil.dart';

class Navigation {
 BuildContext context;

 Navigation(this.context);

 void navigateToAjustes() {
  Navigator.push(
   context,
   MaterialPageRoute(builder: (context) => const Ajustes(title: "AJUSTES")),
  );
 }
 void navigateToTotalAdministrador() {
  Navigator.push(
   context,
   MaterialPageRoute(builder: (context) => const Totaladministrador(title: "TOTAL FIREBASE")),
  );
 }
 void navigateToNombre() {
  Navigator.push(
   context,
   MaterialPageRoute(builder: (context) => const Nombre(title: "NOMBRE DE EMPRESA")),
  );
 }

 Future<String> cargarIdioma() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
   return  prefs.getString('idioma') ?? 'Español';
  }


 void navigateToContrasena() {
  Navigator.push(
   context,
   MaterialPageRoute(builder: (context) => const Contrasena(title: "NUEVA CONTRASEÑA")),
  );
 }

 void navigateToPerfil(String anteriorpantalla) {
  Navigator.push(
   context,
   MaterialPageRoute(builder: (context) => Perfil(title: "PERFIL", anteriorpantalla:  anteriorpantalla,),),
  );
 }

  Future<void> navigateToRegistro() async {
   Navigator.push(
    context,
    MaterialPageRoute(
        builder: (context) => const RegistroPage(title: "REGISTRO",)),
   );
  }
  void navigateToFTP() {
   Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const FTPConfig(title: "FTP")),
   );
  }


  Future<Map<String, bool>> loadSettings() async {
   SharedPreferences prefs = await SharedPreferences.getInstance();
   return {
    'subidaFirebase': prefs.getBool('subidaFirebase') ?? false,
    'subidaFTP': prefs.getBool('subidaFTP') ?? false,
    'permitirProductosDesconocidos': prefs.getBool(
        'permitirProductosDesconocidos') ?? false,
    'permitirCambiarNombre': prefs.getBool('permitirCambiarNombre') ?? false,
    'mostrarCantidades': prefs.getBool('mostrarCantidades') ?? true,
    'mostrarInventario': prefs.getBool('mostrarInventario') ?? true,
    'mostrarSubirDatos': prefs.getBool('mostrarSubirDatos') ?? true,
   };
  }

  void navigateToMenu() async {
   Map<String, bool> settings = await loadSettings();

   Navigator.push(
    context,
    MaterialPageRoute(
     builder: (context) =>
         Menu(
          title: "PRINCIPAL",
          mostrarSubidaDatos: settings['mostrarSubirDatos'] ?? true,
          mostrarInventario: settings['mostrarInventario'] ?? true,
          mostrarCantidades: settings['mostrarCantidades'] ?? true,
          ftp: settings['subidaFTP'] ?? false,
         ),
    ),
   );
  }

  void navigateToAdministrador(String pantallaactual) {
   Navigator.push(
    context,
    MaterialPageRoute(
        builder: (context) => Administrador(title: "ADMINISTRADOR", anteriorpantalla: pantallaactual,)),
   );
  }

  void navigateToTotal() {
   Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const Total(title: "TOTAL")),
   );
  }
  Future<void> navigateToCantidades() async {
   Map<String, bool> settings = await loadSettings();
   SharedPreferences prefs = await SharedPreferences.getInstance();
   String? nombreguardado = prefs.getString('nombre');
   Navigator.push(
    context,
    MaterialPageRoute(builder: (context) =>
        Cantidad(title: "CANTIDADES",
         empresa: nombreguardado ?? "Empresa",
         subidaFirebase: settings['subidaFirebase'] ?? false,
         permitirProductosDesconocidos: settings['permitirProductosDesconocidos'] ??
             false,
         permitirCambiarNombre: settings['permitirCambiarNombre'] ?? false,)),
   );
  }

  Future<void> navigateToInventario() async {
   SharedPreferences prefs = await SharedPreferences.getInstance();
   String? nombreguardado = prefs.getString('nombre');
   Map<String, bool> settings = await loadSettings();

   Navigator.push(
    context,
    MaterialPageRoute(builder: (context) =>
        Inventario(title: "INVENTARIO",
         subidaFirebase: settings['subidaFirebase'] ?? false,
         permitirProductosDesconocidos: settings['permitirProductosDesconocidos'] ??
             false,
         empresa: nombreguardado ?? "Empresa",
         permitirCambiarNombre: settings['permitirCambiarNombre'] ?? false,)),
   );
  }

}
