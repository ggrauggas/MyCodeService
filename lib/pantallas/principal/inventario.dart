// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import '../../database/DatabaseProvider.dart';
import '../../navegacion/navigation.dart';
import '../secundarias/buscador.dart';

class Inventario extends StatefulWidget {
  const Inventario({
    super.key,
    required this.title,
    required this.empresa,
    required this.subidaFirebase,
    required this.permitirProductosDesconocidos,
    required this.permitirCambiarNombre,
  });

  final String title;
  final String empresa;
  final bool subidaFirebase;
  final bool permitirProductosDesconocidos;
  final bool permitirCambiarNombre;

  @override
  State<Inventario> createState() => _MyContenidoPageState();
}

class _MyContenidoPageState extends State<Inventario> {
  late Navigation navigation;
  late String idioma;
  late Future<List<Map<String, dynamic>>> _inventariosFuture;
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _codigoController2 = TextEditingController();
  final TextEditingController _nuevonombreController = TextEditingController();
  String email = "email desconocido";
  final FocusNode _codigoFocusNode = FocusNode();

  Future<void> loadEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? nombreguardado = prefs.getString('email');
    if (nombreguardado != null) {
      email = nombreguardado;
    }
  }

  @override
  void initState() {
    super.initState();
    navigation = Navigation(context);
    _initializeDatabase();
    cargarIdioma();
    loadEmail();
  }

  Future<void> _initializeDatabase() async {
    final databaseProvider = DatabaseProvider();
    await databaseProvider.initialize();
    setState(() {
      _inventariosFuture = databaseProvider.mostrarInventarios();
      FocusScope.of(context).requestFocus(_codigoFocusNode);
    });
  }

  Future<void> cargarIdioma() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      idioma = prefs.getString('idioma') ?? 'Español';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          idioma == 'Español' ? 'INVENTARIO' : 'INVENTORY',
          style: const TextStyle(fontSize: 20, color: Colors.white),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: Colors.black),
                      ),
                      child: TextField(
                        focusNode: _codigoFocusNode,
                        controller: _codigoController,
                        style: const TextStyle(color: Colors.black),
                        cursorColor: Colors.lightBlue,
                        onSubmitted: (value) {
                          _agregarCodigoALaBaseDeDatos(
                              value.trim(), _codigoController2.text.trim());
                          _codigoController.clear();
                          _codigoController2.clear();
                          FocusScope.of(context).requestFocus(_codigoFocusNode);
                        },
                        decoration: InputDecoration(
                          hintText: idioma == 'Español'
                              ? 'Introduce el código...'
                              : 'Introduce the code...',
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      _navigateToBuscador(context);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: _scanBarcode,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  border: Border.all(color: Colors.black),
                ),
                child: TextField(
                  controller: _codigoController2,
                  readOnly: true,
                  style: const TextStyle(color: Colors.black),
                  cursorColor: Colors.lightBlue,
                  decoration: const InputDecoration(
                    hintText: '-',
                    hintStyle: TextStyle(color: Colors.black),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _inventariosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(idioma == 'Español'
                          ? 'Error al cargar los datos '
                          : 'Error charging the data '),
                    );
                  } else {
                    final inventarios = snapshot.data!;
                    return ListView.builder(
                      itemCount: inventarios.length,
                      itemBuilder: (context, index) {
                        final inventario = inventarios[index];
                        return Column(
                          children: [
                            ListTile(
                              title: Text(inventario['codigo']),
                              onTap: () => _onItemSelected(context, inventario),
                              subtitle: Text(
                                idioma == 'Español'
                                    ? 'Cantidad: ${inventario['cantidad']} Nombre: ${inventario['nombre']}'
                                    : 'Quantity: ${inventario['cantidad']} Name: ${inventario['nombre']} ',
                              ),
                            ),
                            const Divider(color: Colors.grey),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showToastMessage(String message) =>
      Fluttertoast.showToast(
        msg: message,
      );

  Future<void> subirElementoAInventarioFirestore(
      String codigo, String empresa, String nombre, int cantidad) async {
    try {
      CollectionReference inventarioCollection =
      FirebaseFirestore.instance.collection('inventario');
      String horaLocal = DateTime.now().toLocal().toString();
      String nombreDocumento = "UPDATE_${horaLocal}_$codigo";

      await inventarioCollection.doc(nombreDocumento).set({
        'codigo': codigo,
        'empresa': empresa,
        'nombre': nombre,
        'cantidad': cantidad,
        'email': email
      });
      showToastMessage('Elemento subido correctamente a Firestore');
    } catch (e) {
      showToastMessage('Error al subir el elemento a Firestore: $e');
    }
  }

  void _agregarCodigoALaBaseDeDatos(String codigo, String nombre) async {
    final String articulosJsonString =
    await rootBundle.loadString('json/articulos.json');
    final List<dynamic> articulosJson = json.decode(articulosJsonString);
    final articulo = articulosJson
        .firstWhere((articulo) => articulo[0] == int.parse(codigo),
        orElse: () => null);

    final databaseProvider = DatabaseProvider();
    await databaseProvider.initialize();

    if (articulo != null) {
      await databaseProvider.addInventario(
          codigo, widget.empresa, 1, articulo[1]);
      if (widget.subidaFirebase) {
        subirElementoAInventarioFirestore(
            codigo, widget.empresa, articulo[1], 1);
      }
    } else {
      if (widget.permitirProductosDesconocidos) {
        await databaseProvider.addInventario(
            codigo, widget.empresa, 1, "Producto Desconocido");

        if (widget.subidaFirebase) {
          subirElementoAInventarioFirestore(
              codigo, widget.empresa, "Producto Desconocido", 1);
        }
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(idioma == 'Español'
                ? 'Producto desconocido '
                : 'Unknown product'),
            content: Text(idioma == 'Español'
                ? 'El producto con el código $codigo no se encuentra en la selección de artículos'
                : 'The product with the code $codigo wasn\'t found in the article selection'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(idioma == 'Español' ? 'Aceptar' : 'Accept'),
              ),
            ],
          ),
        );
      }
    }

    _codigoController.clear();
    _codigoController2.clear();
    setState(() {
      _inventariosFuture = databaseProvider.mostrarInventarios();
    });
  }

  void _navigateToBuscador(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ArticulosWindow(onArticuloSelected: _onArticuloSelected)),
    );
  }

  void _onArticuloSelected(Articulo articulo) {
    _codigoController.text = articulo.codigo.toString();
    _codigoController2.text = articulo.descripcion.toString();
    _agregarCodigoALaBaseDeDatos(_codigoController.text, _codigoController2.text);
  }

  void _onItemSelected(BuildContext context, Map<String, dynamic> inventario) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(idioma == 'Español'
            ? 'Opciones de artículo'
            : 'Article options'),
        content: Text(idioma == 'Español'
            ? 'Que desea hacer con el artículo con el código  ${inventario['codigo']}?'
            : 'What do you want to do with the article with the code  ${inventario['codigo']}?'),
        actions: [
          widget.permitirCambiarNombre
              ? TextButton(
            onPressed: () {
              Navigator.pop(context);
              _Dialognombre(context, inventario);
            },
            child: Text(idioma == 'Español'
                ? 'Cambiar nombre'
                : 'Change name'),
          )
              : const SizedBox.shrink(),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(idioma == 'Español' ? 'Cancelar' : 'Cancel')),
          TextButton(
              onPressed: () {
                _eliminarArticulo(inventario['id']);
                Navigator.pop(context);
              },
              child: Text(idioma == 'Español' ? 'Eliminar' : 'Delete')),
        ],
      ),
    );
  }

  void _Dialognombre(BuildContext context, Map<String, dynamic> inventario) {
    showDialog(
      context: context,
      builder: (context) {
        _nuevonombreController.text = inventario['nombre'].toString();
        return AlertDialog(
          title: Text(idioma == 'Español'
              ? 'Cambiar nombre'
              : 'Change name'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(idioma == 'Español'
                  ? 'Introduce el nuevo nombre'
                  : 'Introduce the new name'),
              TextField(
                controller: _nuevonombreController,
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(idioma == 'Español' ? 'Cancelar' : 'Cancel')),
            TextButton(
              onPressed: () {
                _modificarNombre(
                    inventario['id'], _nuevonombreController.text.trim());
                Navigator.pop(context);
              },
              child: Text(idioma == 'Español'
                  ? 'Cambiar nombre'
                  : 'Change name'),
            ),
          ],
        );
      },
    );
  }

  void _modificarNombre(int id, String nuevonombre) async {
    final databaseProvider = DatabaseProvider();
    await databaseProvider.initialize();
    await databaseProvider.actualizarNombreInventario(id, nuevonombre);
    setState(() {
      _inventariosFuture = databaseProvider.mostrarInventarios();
    });
  }

  void _eliminarArticulo(int id) async {
    final databaseProvider = DatabaseProvider();
    await databaseProvider.initialize();
    await databaseProvider.eliminarInventarioPorId(id);
    setState(() {
      _inventariosFuture = databaseProvider.mostrarInventarios();
    });
  }

  Future<void> _scanBarcode() async {
    try {
      final barcode = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666",
        idioma == 'Español' ? 'Cancelar' : 'Cancel',
        true,
        ScanMode.BARCODE,
      );

      if (barcode != '-1') {
        _codigoController.text = barcode;
        _codigoController2.text = '';
        _agregarCodigoALaBaseDeDatos(_codigoController.text, _codigoController2.text);
      }
    } on PlatformException {
      showToastMessage(idioma == 'Español'
          ? 'Error al escanear el código de barras'
          : 'Error scanning barcode');
    }
  }
}
