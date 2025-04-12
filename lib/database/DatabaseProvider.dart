import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../navegacion/navigation.dart';


class DatabaseProvider extends ChangeNotifier {

  late Database _database;
  bool _initialized = false;
  bool get initialized => _initialized;
  Database get database => _database;
  late Navigation navigation;

  DatabaseProvider() {
    _initDatabase();
  }


  Future<List<Map<String, dynamic>>> query(String tableName) async {
    return await _database.query(tableName);
  }

  String ip ="";
  String user ="";
  String pass ="";
  int port =21;



  Future<void> loadFTP() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ip = prefs.getString('ip') ?? '';
    user = prefs.getString('user') ?? '';
    pass = prefs.getString('password_ftp') ?? '';
    port = prefs.getInt('port') ?? 21;
  }

  Future<String> _convertToCSV(List<Map<String, dynamic>> records) async {
    final StringBuffer csvContent = StringBuffer();
    if (records.isNotEmpty) {
      csvContent.writeln(records[0].keys.join(','));
      for (final record in records) {
        final values = record.values.map((value) => '"$value"').join(',');
        csvContent.writeln(values);
      }
    }
    return csvContent.toString();
  }

  Future<bool> exportToCSV(BuildContext context, String idioma) async {
    final List<String> tableNames = ['inventario', 'cantidad'];
    bool result = true;
    for (final tableName in tableNames) {
      final List<Map<String, dynamic>> records = await _database.query(tableName);
      final csvContent = await _convertToCSV(records);
      result &= await uploadCSVToFTP('$tableName.csv', csvContent, context, idioma);
    }
    return result;
  }

  Future<File> _createCSVFile(String csvContent) async {
    final Directory tempDir = Directory.systemTemp;
    final File tempFile = File('${tempDir.path}/data'+DateTime.now().toLocal().toString()+'.csv');
    await tempFile.writeAsString(csvContent);
    return tempFile;
  }

  Future<bool> uploadCSVToFTP(String fileName, String content, BuildContext context, String idioma) async {
    try {
      final ftp = FTPConnect(ip, user: user, port: port, pass: pass,);
      print('Connecting to FTP ...');
      await ftp.connect();
      final File fileToUpload = await _createCSVFile(content);
      bool uploadSuccess = await ftp.uploadFile(fileToUpload, sRemoteName: fileName);
      await ftp.disconnect();
      print('Disconnected from FTP.');

      if (uploadSuccess) {
        ftp.disconnect();
        return true;
      } else {
        ftp.disconnect();
        Fluttertoast.showToast(
          msg: idioma == 'Español' ? "Error al subir el archivo" : "Failed to upload file",
        );
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: idioma == 'Español' ? "Error al subir el archivo" : "Failed to upload file",
      );
      return false;
    }
  }



  Future<void> _initDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'inventario.db'),
      onCreate: (db, version) {
        db.execute(
          "CREATE TABLE inventario(id INTEGER PRIMARY KEY AUTOINCREMENT, codigo TEXT, empresa TEXT, cantidad INTEGER, nombre TEXT)",
        );
        db.execute(
          "CREATE TABLE cantidad(id INTEGER PRIMARY KEY AUTOINCREMENT, codigo TEXT, empresa TEXT, cantidad INTEGER, nombre TEXT)",
        );
      },
      version: 1,
    );
    _initialized = true;
    notifyListeners();
  }

  Future<void> initialize() async {
    if (!_initialized) {
      await _initDatabase();
    }
  }
  Future<int> getTotalElements() async {
    final int totalInventario = await getTotalInventario();
    final int totalCantidad = await getTotalCantidad();
    return totalInventario + totalCantidad;
  }

  Future<int> getTotalInventario() async {
    final List<Map<String, dynamic>> inventarios = await mostrarInventarios();
    return inventarios.length;
  }

  Future<int> getTotalCantidad() async {
    final List<Map<String, dynamic>> cantidades = await mostrarCantidad();
    return cantidades.length;
  }

  Future<double> getPercentageInventario() async {
    final int total = await getTotalElements();
    final int totalInventario = await getTotalInventario();
    return (totalInventario / total) * 100;
  }

  Future<double> getPercentageCantidad() async {
    final int total = await getTotalElements();
    final int totalCantidad = await getTotalCantidad();
    return (totalCantidad / total) * 100;
  }

  Future<int> getTotalProductosDesconocidos() async {
    final List<Map<String, dynamic>> inventarios = await mostrarInventarios();
    int desconocidos = 0;
    for (var inventario in inventarios) {
      if (inventario['nombre'] == 'Producto Desconocido') {
        desconocidos++;
      }
    }
    return desconocidos;
  }

  Future<double> getPercentageProductosDesconocidos() async {
    final int totalInventario = await getTotalInventario();
    final int desconocidos = await getTotalProductosDesconocidos();
    return (desconocidos / totalInventario) * 100;
  }

  Future<String> getProductoMasRegistrado() async {
    final List<Map<String, dynamic>> inventarios = await mostrarInventarios();
    String productoMasRegistrado = '';
    int maxCantidad = 0;
    for (var inventario in inventarios) {
      if (inventario['cantidad'] > maxCantidad) {
        maxCantidad = inventario['cantidad'];
        productoMasRegistrado = inventario['nombre'];
      }
    }
    return productoMasRegistrado;
  }
  Future<void> eliminarInventarioPorId(int id) async {
    if (!_initialized) {
      throw Exception("La base de datos no ha sido inicializada.");
    }
    await _database.delete(
      'inventario',
      where: 'id = ?',
      whereArgs: [id],
    );
    notifyListeners();
  }


  Future<void> eliminarCantidadPorId(int id) async {
    if (!_initialized) {
      throw Exception("La base de datos no ha sido inicializada.");
    }
    await _database.delete(
      'cantidad',
      where: 'id = ?',
      whereArgs: [id],
    );
    notifyListeners();
  }

  Future<void> actualizarCantidad(int id, int nuevaCantidad) async {
    if (!_initialized) {
      throw Exception("La base de datos no ha sido inicializada.");
    }
    await _database.update(
      'cantidad',
      {'cantidad': nuevaCantidad},
      where: 'id = ?',
      whereArgs: [id],
    );
    notifyListeners();
  }

  Future<void> actualizarNombreInventario(int id, String nuevonombre) async {
    if (!_initialized) {
      throw Exception("La base de datos no ha sido inicializada.");
    }
    await _database.update(
      'inventario',
      {'nombre': nuevonombre},
      where: 'id = ?',
      whereArgs: [id],
    );
    notifyListeners();
  }
  Future<void> actualizarNombreCantidad(int id, String nuevonombre) async {
    if (!_initialized) {
      throw Exception("La base de datos no ha sido inicializada.");
    }
    await _database.update(
      'cantidad',
      {'nombre': nuevonombre},
      where: 'id = ?',
      whereArgs: [id],
    );
    notifyListeners();
  }




  Future<void> addInventario(String codigo, String empresa, int cantidad, String nombre) async {
    if (!_initialized) {
      throw Exception("La base de datos no ha sido inicializada.");
    }
    await _database.insert(
      'inventario',
      {
        'codigo': codigo,
        'empresa': empresa,
        'cantidad':cantidad,
        'nombre': nombre,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    notifyListeners();
  }
  Future<void> addCantidad(String codigo, String empresa, int cantidad, String nombre) async {
    if (!_initialized) {
      throw Exception("La base de datos no ha sido inicializada.");
    }
    await _database.insert(
      'cantidad',
      {
        'codigo': codigo,
        'empresa': empresa,
        'cantidad':cantidad,
        'nombre': nombre,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> mostrarInventarios() async {
    final db = await database;
    final List<Map<String, dynamic>> inventarios = await db.query('inventario', orderBy: 'id DESC');
    return inventarios;
  }

  Future<List<Map<String, dynamic>>> mostrarCantidad() async {
    if (!_initialized) {
      throw Exception("La base de datos no ha sido inicializada.");
    }
    final List<Map<String, dynamic>> cantidad = await _database.query('cantidad', orderBy: 'id DESC');
    return cantidad;
  }

  Future<void> borrarTodoElInventario() async {
    if (!_initialized) {
      throw Exception("La base de datos no ha sido inicializada.");
    }
    await _database.delete('inventario');
    notifyListeners();
  }

  Future<void> borrarTodoCantidad() async {
    if (!_initialized) {
      throw Exception("La base de datos no ha sido inicializada.");
    }
    await _database.delete('cantidad');
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> getAllCantidades() async {
    try {
      await initialize();
      if (!_initialized) {
        throw Exception("La base de datos no ha sido inicializada.");
      }
      List<Map<String, dynamic>> result = await _database.query('cantidad');
      return result;
    } catch (e) {
      print('Error al obtener los datos de la tabla "cantidades": $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllInventario() async {
    try {
      await initialize();
      if (!_initialized) {
        throw Exception("La base de datos no ha sido inicializada.");
      }
      List<Map<String, dynamic>> result = await _database.query('inventario');
      return result;
    } catch (e) {
      print('Error al obtener los datos de la tabla "inventario": $e');
      return [];
    }
  }
}