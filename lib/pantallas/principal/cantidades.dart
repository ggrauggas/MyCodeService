// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../secundarias/buscador.dart';
import '../../database/DatabaseProvider.dart';
import '../../navegacion/navigation.dart';

class Cantidad extends StatefulWidget {
  const Cantidad({super.key, required this.title,
    required this.permitirProductosDesconocidos,
    required this.empresa,
    required this.subidaFirebase,
    required this.permitirCambiarNombre});

  final String title;
  final String empresa;
  final bool subidaFirebase;
  final bool permitirProductosDesconocidos;
  final bool permitirCambiarNombre;
  @override
  State<Cantidad> createState() => _MyContenidoPageState();
}

class _MyContenidoPageState extends State<Cantidad> {
  late Navigation navigation;
  late Future<List<Map<String, dynamic>>> _cantidadFuture;
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _nombrecontroller = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _nuevonombreController = TextEditingController();
  String email = "email desconocido";
  late String idioma;

  Future<void> cargarIdioma() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      idioma = prefs.getString('idioma') ?? 'Español';
    });
  }

  Future<void> loadEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? nombreguardado = prefs.getString('email');
    if (nombreguardado != null) {
      email = nombreguardado;
    }
  }

  final TextEditingController _nuevaCantidadController = TextEditingController();
  final FocusNode _cantidadFocusNode = FocusNode();
  final FocusNode _codigoFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    navigation = Navigation(context);
    _initializeDatabase();
    loadEmail();
    cargarIdioma();
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nombrecontroller.dispose();
    _cantidadController.dispose();
    _nuevaCantidadController.dispose();
    _cantidadFocusNode.dispose();
    super.dispose();
  }

  Future<void> _initializeDatabase() async {
    final databaseProvider = DatabaseProvider();
    await databaseProvider.initialize();
    setState(() {
      _cantidadFuture = databaseProvider.mostrarCantidad();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          idioma == 'Español' ? 'CANTIDADES' : 'QUANTITIES',
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
                        onSubmitted: _onCodigoSubmitted,
                        decoration: InputDecoration(
                          hintText: idioma == 'Español' ? 'Introduce el código...' : 'Introduce the code',
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
                  color: Colors.transparent,
                  border: Border.all(color: Colors.black),
                ),
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: _cantidadController,
                  focusNode: _cantidadFocusNode,
                  onSubmitted: _onCantidadSubmitted,
                  style: const TextStyle(color: Colors.black),
                  cursorColor: Colors.lightBlue,
                  decoration: InputDecoration(
                    hintText: idioma == 'Español' ? 'Introduce la cantidad...' : 'Introduce the quantity',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
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
                  controller: _nombrecontroller,
                  readOnly: true, // No editable
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
                future: _cantidadFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error al cargar los datos: ${snapshot.error}'),
                    );
                  } else {
                    final inventarios = snapshot.data!;
                    return ListView.builder(
                      itemCount: inventarios.length,
                      itemBuilder: (context, index) {
                        final cantidad = inventarios[index];
                        return Column(
                          children: [
                            ListTile(
                              title: Text(cantidad['codigo']),
                              onTap: () => _onItemSelected(context, cantidad),
                              subtitle: Text(
                                'Cantidad: ${cantidad['cantidad']} Nombre: ${cantidad['nombre']}',
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
      Fluttertoast.showToast(msg: message);

  Future<void> subirElementoACantidadesFirestore(String codigo, String empresa, String nombre, int cantidad) async {
    try {
      CollectionReference cantidadesCollection = FirebaseFirestore.instance.collection('cantidades');
      String horaLocal = DateTime.now().toLocal().toString();
      String nombreDocumento = "UPDATE_${horaLocal}_$codigo";

      await cantidadesCollection.doc(nombreDocumento).set({
        'codigo': codigo,
        'empresa': empresa,
        'nombre': nombre,
        'cantidad': cantidad,
        'email': email
      });
      showToastMessage('Elemento subido correctamente a Firestore');
    } catch (e) {
      showToastMessage('Error al subir el elemento a Firestore');
    }
  }

  void _agregarCodigoALaBaseDeDatos(String codigo, String nombre, int cantidad) async {
    final String articulosJsonString = await rootBundle.loadString('json/articulos.json');
    final List<dynamic> articulosJson = json.decode(articulosJsonString);
    final articulo = articulosJson.firstWhere((articulo) => articulo[0] == int.parse(codigo), orElse: () => null);

    final databaseProvider = DatabaseProvider();
    await databaseProvider.initialize();

    if (articulo != null) {
      await databaseProvider.addCantidad(codigo, widget.empresa, cantidad, articulo[1]);

      if (widget.subidaFirebase) {
        subirElementoACantidadesFirestore(codigo, widget.empresa, articulo[1], cantidad);
      }
    } else {
      if (widget.permitirProductosDesconocidos) {
        await databaseProvider.addCantidad(codigo, widget.empresa, cantidad, "Producto Desconocido");

        if (widget.subidaFirebase) {
          subirElementoACantidadesFirestore(codigo, widget.empresa, "Producto Desconocido", cantidad);
        }
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(idioma == 'Español' ? 'Producto desconocido' : 'Unknown product'),
            content: Text(idioma == 'Español' ?
            'El producto con el código $codigo no se encuentra en la selección de artículos' :
            'The product with the code $codigo wasn\'t found in the article selection'),
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
    setState(() {
      _cantidadFuture = databaseProvider.mostrarCantidad();
    });
  }

  void _navigateToBuscador(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ArticulosWindow(onArticuloSelected: _onArticuloSelected)),
    );
  }

  void _onCodigoSubmitted(String value) {
    FocusScope.of(context).requestFocus(_cantidadFocusNode);
  }

  void _onCantidadSubmitted(String value) {
    try {
      int tercerElemento = int.parse(value.trim());
      if (tercerElemento != 0) {
        _agregarCodigoALaBaseDeDatos(_codigoController.text.trim(), _nombrecontroller.text.trim(), tercerElemento);

        _codigoController.clear();
        _nombrecontroller.clear();
        _cantidadController.clear();
      }
    } on FormatException {
      showToastMessage('El tercer elemento no es un número entero válido.');
    }
    FocusScope.of(context).requestFocus(_codigoFocusNode);
  }

  void _onItemSelected(BuildContext context, Map<String, dynamic> cantidad) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(idioma == 'Español' ? 'Opciones de artículo' : 'Article options'),
        content: Text(idioma == 'Español' ?
        '¿Qué desea hacer con el artículo con el código ${cantidad['codigo']}?' :
        'What do you want to do with the article with the code ${cantidad['codigo']}?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(idioma == 'Español' ? 'Cancelar' : 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              _eliminarCantidad(cantidad['id']);
              Navigator.pop(context);
            },
            child: Text(idioma == 'Español' ? 'Eliminar' : 'Delete'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _Dialogcantidad(context, cantidad);
            },
            child: Text(idioma == 'Español' ? 'Modificar cantidad' : 'Modify quantity'),
          ),
          widget.permitirCambiarNombre
              ? TextButton(
            onPressed: () {
              Navigator.pop(context);
              _Dialognombre(context, cantidad);
            },
            child: Text(idioma == 'Español' ? 'Cambiar nombre' : 'Change name'),
          )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  void _Dialognombre(BuildContext context, Map<String, dynamic> cantidad) {
    showDialog(
      context: context,
      builder: (context) {
        _nuevonombreController.text = cantidad['nombre'].toString();
        return AlertDialog(
          title: Text(idioma == 'Español' ? 'Modificar nombre' : 'Modify name'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(idioma == 'Español' ? 'Introduce el nuevo nombre:' : 'Introduce the new name:'),
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
              child: Text(idioma == 'Español' ? 'Cancelar' : 'Cancel'),
            ),
            TextButton(
              onPressed: () {
                _modificarNombre(cantidad['id'], _nuevonombreController.text.trim());
                Navigator.pop(context);
              },
              child: Text(idioma == 'Español' ? 'Modificar nombre' : 'Modify name'),
            ),
          ],
        );
      },
    );
  }

  void _Dialogcantidad(BuildContext context, Map<String, dynamic> cantidad) {
    showDialog(
      context: context,
      builder: (context) {
        _nuevaCantidadController.text = cantidad['cantidad'].toString();
        return AlertDialog(
          title: Text(idioma == 'Español' ? 'Modificar cantidad' : 'Modify quantity'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(idioma == 'Español' ? 'Introduce la nueva cantidad:' : 'Introduce the new quantity:'),
              TextField(
                controller: _nuevaCantidadController,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(idioma == 'Español' ? 'Cancelar' : 'Cancel'),
            ),
            TextButton(
              onPressed: () {
                _modificarCantidad(cantidad['id'], int.parse(_nuevaCantidadController.text.trim()));
                Navigator.pop(context);
              },
              child: Text(idioma == 'Español' ? 'Modificar cantidad' : 'Modify quantity'),
            ),
          ],
        );
      },
    );
  }

  void _modificarNombre(int id, String nuevonombre) async {
    final databaseProvider = DatabaseProvider();
    await databaseProvider.initialize();
    await databaseProvider.actualizarNombreCantidad(id, nuevonombre);
    setState(() {
      _cantidadFuture = databaseProvider.mostrarCantidad();
    });
  }

  void _onArticuloSelected(Articulo articulo) {
    _codigoController.text = articulo.codigo.toString();
    _nombrecontroller.text = articulo.descripcion.toString();
    FocusScope.of(context).requestFocus(_cantidadFocusNode);
  }

  void _modificarCantidad(int id, int nuevaCantidad) async {
    final databaseProvider = DatabaseProvider();
    await databaseProvider.initialize();
    await databaseProvider.actualizarCantidad(id, nuevaCantidad);
    setState(() {
      _cantidadFuture = databaseProvider.mostrarCantidad();
    });
  }

  void _eliminarCantidad(int id) async {
    final databaseProvider = DatabaseProvider();
    await databaseProvider.initialize();
    await databaseProvider.eliminarCantidadPorId(id);
    setState(() {
      _cantidadFuture = databaseProvider.mostrarCantidad();
    });
  }

  Future<void> _scanBarcode() async {
    try {
      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        idioma == 'Español' ? 'Cancelar' : 'Cancel',
        true,
        ScanMode.BARCODE,
      );

      if (barcodeScanRes != '-1') {
        _codigoController.text = barcodeScanRes;
        final String articulosJsonString = await rootBundle.loadString('json/articulos.json');
        final List<dynamic> articulosJson = json.decode(articulosJsonString);
        final articulo = articulosJson.firstWhere((articulo) => articulo[0] == int.parse(barcodeScanRes), orElse: () => null);

        if (articulo != null) {
          _nombrecontroller.text = articulo[1];
          FocusScope.of(context).requestFocus(_cantidadFocusNode);

        } else {
          if (!widget.permitirProductosDesconocidos) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(idioma == 'Español' ? 'Producto desconocido' : 'Unknown product'),
                content: Text(idioma == 'Español' ? 'El producto con el código $barcodeScanRes no se encuentra en la selección de artículos' : 'The product with the code $barcodeScanRes wasn\'t found in the article selection'),
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
      }
    } on PlatformException {
      showToastMessage(idioma == 'Español' ? 'Error al escanear el código de barras' : 'Error scanning barcode');
    }
  }
}
