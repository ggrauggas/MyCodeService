import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Totaladministrador extends StatefulWidget {
  const Totaladministrador({super.key, required this.title});
  final String title;

  @override
  State<Totaladministrador> createState() => Totaladministradorstate();
}

class Totaladministradorstate extends State<Totaladministrador> {
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

        child: _buildCombinedList(),
      ),
    );
  }

  Widget _buildCombinedList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('inventario').snapshots(),
      builder: (context, inventarioSnapshot) {
        if (inventarioSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (inventarioSnapshot.hasError) {
          return Center(child: Text('Error: ${inventarioSnapshot.error}'));
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('cantidades').snapshots(),
          builder: (context, cantidadesSnapshot) {
            if (cantidadesSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (cantidadesSnapshot.hasError) {
              return Center(child: Text('Error: ${cantidadesSnapshot.error}'));
            }

            final inventarioDocs = inventarioSnapshot.data?.docs ?? [];
            final cantidadesDocs = cantidadesSnapshot.data?.docs ?? [];
            final combinedDocs = [...inventarioDocs, ...cantidadesDocs];

            return ListView.builder(
              itemCount: combinedDocs.length,
              itemBuilder: (context, index) {
                final doc = combinedDocs[index];
                final data = doc.data() as Map<String, dynamic>;
                return Column(
                  children: [
                    ListTile(
                      title: Text(data['nombre'] ?? 'Nombre no disponible'),
                      subtitle: Text('Cantidad: ${data['cantidad'] ?? 'No disponible'} \nUser: ${data['email'] ?? 'No disponible'} \nCódigo: ${data['codigo'] ?? 'No disponible'}' ),
                    ),
                    const Divider(color: Colors.grey),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
