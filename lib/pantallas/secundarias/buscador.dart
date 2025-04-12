// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ArticulosWindow extends StatefulWidget {

  final Function(Articulo) onArticuloSelected;
  const ArticulosWindow({super.key, required this.onArticuloSelected});

  @override
  _ArticulosWindowState createState() => _ArticulosWindowState();
}

class _ArticulosWindowState extends State<ArticulosWindow> {
  late Future<List<Articulo>> _articulosFuture;
  final TextEditingController _filtroController = TextEditingController();
  late String idioma;

  @override
  void initState() {
    super.initState();
    _articulosFuture = _cargarArticulos(context);
    cargarIdioma();
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
          idioma == 'Español' ?
          'ARTICULOS' :
          'ARTICLES',
          style: const TextStyle(fontSize: 20, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF3304F8),
      ),
      body:
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _filtroController,
              onChanged: _filtrarArticulos,
              decoration: const InputDecoration(
                labelText: 'Buscar',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Articulo>>(
              future: _articulosFuture,
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
                  final articulos = snapshot.data!;
                  return ListView.builder(
                    itemCount: articulos.length,
                    itemBuilder: (context, index) {
                      final articulo = articulos[index];
                      return ListTile(
                        title: Text('Código: ${articulo.codigo}'),
                        subtitle: Text('Nombre: ${articulo.descripcion}'),
                        onTap: () {
                          widget.onArticuloSelected(articulo);
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Articulo>> _cargarArticulos(BuildContext context) async {
    String data = await DefaultAssetBundle.of(context).loadString('json/articulos.json');
    List<dynamic> jsonResult = json.decode(data);
    List<Articulo> articulos = jsonResult.map((element) {
      int codigo = element[0] as int;
      String descripcion = element[1] as String;
      return Articulo(codigo: codigo, descripcion: descripcion);
    }).toList();
    return articulos;
  }

  void _filtrarArticulos(String filtro) {
    setState(() {
      _articulosFuture = _cargarArticulosFiltrados(filtro);
    });
  }

  Future<List<Articulo>> _cargarArticulosFiltrados(String filtro) async {
    List<Articulo> todosArticulos = await _cargarArticulos(context);
    return todosArticulos.where((articulo) {
      return articulo.codigo.toString().contains(filtro) || articulo.descripcion.toLowerCase().contains(filtro.toLowerCase());
    }).toList();
  }
}


class Articulo {
  final int codigo;
  final String descripcion;

  Articulo({required this.codigo, required this.descripcion});
}
