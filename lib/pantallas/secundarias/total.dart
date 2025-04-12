import 'package:flutter/material.dart';
import '../../database/DatabaseProvider.dart';

class Total extends StatefulWidget {
  const Total({super.key, required this.title});
  final String title;

  @override
  State<Total> createState() => _MyContenidoPageState();
}

class _MyContenidoPageState extends State<Total> {
  final databaseProvider = DatabaseProvider();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _getData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      List<Map<String, dynamic>> data = snapshot.data ?? [];
                      return ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          var item = data[index];
                          return ListTile(
                            title: Text(item['nombre']),
                            subtitle: Text('Cantidad: ${item['cantidad']}'),
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
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getData() async {
    List<Map<String, dynamic>> cantidades = await databaseProvider.getAllCantidades();
    List<Map<String, dynamic>> inventario = await databaseProvider.getAllInventario();
    List<Map<String, dynamic>> data = [...cantidades, ...inventario];
    return data;
  }
}
