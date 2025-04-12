// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../PDF/PDFGenerator.dart';
import '../../database/DatabaseProvider.dart';
import '../../navegacion/navigation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Menu extends StatefulWidget {
  const Menu({
    super.key,
    required this.title,
    required this.mostrarSubidaDatos,
    required this.mostrarCantidades,
    required this.mostrarInventario,
    required this.ftp
  });

  final String title;
  final bool mostrarSubidaDatos;
  final bool mostrarCantidades;
  final bool mostrarInventario;
  final bool ftp;

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  final databaseProvider = DatabaseProvider();
  late Navigation navigation;
  bool _uploading = false;
  late TextEditingController _passwordController;

  String email = "email desconocido";
  String idioma = "Español";
  final pdf = PDFGenerator();
  bool atajos = false;


  Future<void> loadEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? nombreguardado = prefs.getString('email');
    if (nombreguardado != null) {
      email = nombreguardado;
    }
  }
  Future<void> loadAtajos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    atajos = prefs.getBool('atajosadministrador')?? false;

  }


  void showToastMessage(String message) =>
      Fluttertoast.showToast(
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
    _passwordController = TextEditingController();
    cargarIdioma();
    loadEmail();
    loadAtajos();

  }

  void navigateToCantidades() {
    navigation.navigateToCantidades();
  }


  Future<void> subirDatosCantidadesFirestore() async {
    try {
      loadEmail();
      final databaseProvider = DatabaseProvider();
      await databaseProvider.initialize();
      CollectionReference cantidadesCollection = FirebaseFirestore.instance
          .collection('cantidades');
      List<Map<String, dynamic>> cantidades = await databaseProvider
          .getAllCantidades();

      for (var cantidad in cantidades) {
        String codigoProducto = cantidad['codigo'];
        String horaLocal = DateTime.now().toLocal().toString();
        String nombreDocumento = "UPDATE_${horaLocal}_$codigoProducto";

        await cantidadesCollection.doc(nombreDocumento).set({
          'codigo': cantidad['codigo'],
          'empresa': cantidad['empresa'],
          'nombre': cantidad['nombre'],
          'cantidad': cantidad['cantidad'],
          'email': email,
        });
      }
    } catch (e) {
      showToastMessage(idioma == "Español" ?'Error al subir datos de la tabla "cantidades" a Firestore' : "Error trying to update quantity data to Firestore");
    }
  }

  Future<void> subirDatosFTP() async {

    final databaseProvider = DatabaseProvider();
    await databaseProvider.initialize();
    databaseProvider.loadFTP();
    bool result = await databaseProvider.exportToCSV(context, idioma);
    if (result){
      showBienFTP(context, idioma);
    }else{
      showMalFTP(context);
    }



  }
  void showBienFTP(BuildContext context, String idioma) {
    setState(() {
      _uploading = false;
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(idioma == 'Español' ?
          ' FTP y Firebase subido correctamente.\n ¿Desea borrar los datos locales?' :
          'FTP and Firebase updated succesfully. \n Do you want to delete the local data?'),

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
              child: const Text('Borrar los datos'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _uploading = false;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Mantener los datos'),
            ),

          ],
        );
      },
    );
  }

  void showMalFTP(BuildContext context) {
    setState(() {
      _uploading = false;
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(idioma == 'Español' ?
          ' Ha habido un error en la subida del FTP' :
          'There was an error updating the FTP',),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                navigation.navigateToFTP();
              },
              child: const Text("FTP Settings"),
            ),

          ],
        );
      },
    );
  }
  Future<bool> subirDatosConTimeout(Future<void> Function() uploadFunction) async {
    try {
      await Future.any([
        uploadFunction(),
        Future.delayed(const Duration(seconds: 5), () {
          throw TimeoutException('Tiempo de espera agotado');
        }),
      ]);
      return true;
    } on TimeoutException catch (_) {
      showToastMessage(idioma == 'Español' ? 'La subida ha fallado por tiempo de espera agotado' : 'Upload failed due to timeout');
      setState(() {
        _uploading = false;
      });
      return false;
    } catch (e) {
      showToastMessage(idioma == 'Español' ? 'Error al subir los datos: $e' : 'Error uploading data: $e');
      setState(() {
        _uploading = false;
      });
      return false;
    }
  }

  Future<void> subirDatosInventarioFirestore() async {
    try {
      loadEmail();
      final databaseProvider = DatabaseProvider();
      await databaseProvider.initialize();
      CollectionReference inventarioCollection = FirebaseFirestore.instance
          .collection('inventario');
      List<Map<String, dynamic>> inventario = await databaseProvider
          .getAllInventario();
      for (var item in inventario) {
        String codigoProducto = item['codigo'];
        String horaLocal = DateTime.now().toLocal().toString();
        String nombreDocumento = "UPDATE_${horaLocal}_$codigoProducto";

        await inventarioCollection.doc(nombreDocumento).set({
          'codigo': item['codigo'],
          'empresa': item['empresa'],
          'nombre': item['nombre'],
          'cantidad': item['cantidad'],
          'email': email
        });
      }
      showToastMessage('Datos de "inventario" subidos correctamente a Firestore');
    } catch (e) {
      showToastMessage(idioma == "Español" ?'Error al subir datos de la tabla "inventario" a Firestore' : "Error trying to update inventory data to Firestore");
    }
  }

  void showAdminPasswordDialog() {
    cargarContrasena();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(idioma == 'Español' ?
          ' Ingrese la contraseña de administrador' :
          'Enter the administrator password ',),
          content: TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
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
                  navigation.navigateToAdministrador("Menu");
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
              child: Text(idioma == 'Español' ?
              'Cancelar' :
              'Cancel',),
            ),
          ],
        );
      },
    );
  }

  Future<void> subirdatosFirebase() async {
    setState(() {
      _uploading = true;
    });
    try {

      bool respuesta1 = await subirDatosConTimeout(subirDatosInventarioFirestore);
      bool respuesta2 = await subirDatosConTimeout(subirDatosCantidadesFirestore);

      if(!respuesta1 || !respuesta2){
        return;
      }
      if (widget.ftp) {
        showToastMessage(idioma == "Español" ? "Firebase subido correctamente" : "Firebase updated succesfully");
        try {
          await subirDatosConTimeout(subirDatosFTP);
        } catch (e) {
          setState(() {
            _uploading = false;
          });
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Error'),
                content: Text(idioma == 'Español' ? 'Hubo un error en la subida de datos a FTP: $e' : 'There was an error uploading data to FTP: $e'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        _uploading = false;
                      });
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } else {
        setState(() {
          _uploading = false;
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('FireStore'),
              content: Text(idioma == 'Español'
                  ? 'Los datos se han subido correctamente.\n ¿Desea borrar los datos locales?'
                  : 'The data has been uploaded correctly.\n Do you want to delete the local data?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _uploading = false;
                    });
                  },
                  child: const Text('Mantener datos'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    databaseProvider.borrarTodoCantidad();
                    databaseProvider.borrarTodoElInventario();
                    showToastMessage(idioma == 'Español' ?
                    'Datos eliminados correctamente' :
                    'Successfully deleted data',);

                    setState(() {
                      _uploading = false;
                    });
                  },
                  child: const Text('Borrar datos'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(idioma == 'Español'
                ? 'Hubo un error en la subida de datos: $e'
                : 'There was an error uploading data: $e'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _uploading = false;
                  });
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
  Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(idioma == 'Español' ?'Salir de la sesión' : "Log Out"),
        content: Text(idioma == 'Español' ?'¿Estás seguro que quieres salir de la sesión?' : "Are you sure you want to exit the session?"),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(idioma == "Español" ?'Cancelar' : "Cancel"),
          ),
          TextButton(
            onPressed: () => { Navigator.pop(context, false),
              navigation.navigateToRegistro(),
              showToastMessage(idioma == "Español" ? "Ha salido de la sesión" : "Log Out")},
            child: Text(idioma == "Español" ?'Si' : "Yes"),
          ),
        ],
      ),
    ).then((value) => value ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              widget.title,
              style: const TextStyle(fontSize: 30, color: Colors.white),
            ),
            centerTitle: true,
            backgroundColor: const Color(0xFF3304F8),
          ),
          body: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Color(0xFF7E57C2)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 1.8],
                  tileMode: TileMode.clamp,
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const SizedBox(height: 30),

                        const SizedBox(height: 200),
                        if (widget.mostrarCantidades) ...[
                          SizedBox(
                            width: 300,
                            height: 70,
                            child: ElevatedButton(
                              onPressed: _uploading ? null : navigation.navigateToCantidades,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: _uploading ? Colors.grey : const Color(0xFF5E46C2),
                                padding: const EdgeInsets.all(20),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.list, color: Colors.white),
                                  const SizedBox(width: 10),
                                  Text(
                                    idioma == 'Español' ? 'CANTIDADES' : 'QUANTITIES',
                                    style: const TextStyle(fontSize: 20, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                        if (widget.mostrarInventario) ...[
                          SizedBox(
                            width: 300,
                            height: 70,
                            child: ElevatedButton(
                              onPressed: _uploading ? null : navigation.navigateToInventario,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: _uploading ? Colors.grey : const Color(0xFF5E46C2),
                                padding: const EdgeInsets.all(20),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.library_books_sharp, color: Colors.white),
                                  const SizedBox(width: 10),
                                  Text(
                                    idioma == 'Español' ? 'INVENTARIO' : 'INVENTORY',
                                    style: const TextStyle(fontSize: 20, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                        if (widget.mostrarSubidaDatos) ...[
                          SizedBox(
                            width: 300,
                            height: 70,
                            child: ElevatedButton(
                              onPressed: _uploading ? null : subirdatosFirebase,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: _uploading ? Colors.grey : const Color(0xFF1E0B89),
                                padding: const EdgeInsets.all(20),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.upcoming, color: Colors.white),
                                  const SizedBox(width: 10),
                                  Text(
                                    idioma == 'Español' ? 'SUBIR DATOS' : 'UPLOAD DATA',
                                    style: const TextStyle(fontSize: 20, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        const SizedBox(height: kToolbarHeight),
                        Image.asset(
                          'imagenes/MYCODESERVICE.png',
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                        if (_uploading) const SizedBox(height: 300),
                        if (_uploading) const CircularProgressIndicator(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Color(0xFF3304F8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        idioma == 'Español' ? 'MENÚ' : 'MENU',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 35,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            idioma == 'Español' ? 'Usuario: $email' : 'User: $email',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                          if (atajos) const Icon(Icons.admin_panel_settings_outlined, color: Colors.white) else const Icon(Icons.account_circle_outlined, color: Colors.white),
                        ],
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings),
                  title: Text(
                    idioma == 'Español' ? 'ADMINISTRADOR' : 'ADMINISTRATOR',
                    style: const TextStyle(fontSize: 20, color: Colors.black),
                  ),
                  onTap: () {
                    if (atajos) {
                      navigation.navigateToAdministrador("Menu");
                    } else {
                      showAdminPasswordDialog();
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.account_circle),
                  title: Text(
                    idioma == 'Español' ? 'PERFIL' : 'PROFILE',
                    style: const TextStyle(fontSize: 20, color: Colors.black),
                  ),
                  onTap: () {
                    navigation.navigateToPerfil("Menu");
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf_outlined),
                  title: Text(
                    idioma == 'Español' ? 'GENERAR PDF' : 'GENERATE PDF',
                    style: const TextStyle(fontSize: 20, color: Colors.black),
                  ),
                  onTap: () {
                    pdf.generatePDF(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.account_tree),
                  title: const Text(
                    'TOTAL',
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                  onTap: () {
                    navigation.navigateToTotal();
                  },
                ),
                if (atajos) ...[
                  ListTile(
                    leading: const Icon(Icons.electrical_services),
                    title: Text(
                      idioma == 'Español' ? 'CONFIGURAR FTP' : 'CONFIGURATE FTP',
                      style: const TextStyle(fontSize: 20, color: Colors.black),
                    ),
                    onTap: () {
                      navigation.navigateToFTP();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.password),
                    title: Text(
                      idioma == 'Español' ? 'CAMBIAR CONTRASEÑA' : 'CHANGE PASSWORD',
                      style: const TextStyle(fontSize: 20, color: Colors.black),
                    ),
                    onTap: () {
                      navigation.navigateToContrasena();
                    },
                  ), ListTile(
                    leading: const Icon(Icons.account_balance_outlined),
                    title: Text(
                      idioma == 'Español' ? 'CAMBIAR NOMBRE EMPRESA' : 'CHANGE COMPANY NAME',
                      style: const TextStyle(fontSize: 20, color: Colors.black),
                    ),
                    onTap: () {
                      navigation.navigateToNombre();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text(
                      'TOTAL FIREBASE',
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                    onTap: () {
                      navigation.navigateToTotalAdministrador();

                    },
                  ),
                ],
              ],
            ),
          ),

          floatingActionButton: FloatingActionButton(
            onPressed: _uploading ? null : navigation.navigateToAjustes,
            tooltip: 'Ajustes',
            backgroundColor: _uploading ? Colors.grey : Colors.cyan,
            child: const Icon(Icons.settings_sharp),
          ),
        )
    );

  }

}
