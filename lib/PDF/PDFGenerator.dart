// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import '../database/DatabaseProvider.dart';

class PDFGenerator {

  PDFGenerator();

  Future<void> generatePDF(BuildContext context) async {
    try {

      final pdf = pw.Document();
      final databaseProvider = DatabaseProvider();
      await databaseProvider.initialize();

      final int totalElements = await databaseProvider.getTotalElements();
      String horaLocal = DateFormat('dd/MM/yyyy').format(DateTime.now().toLocal());
      final int totalInventario = await databaseProvider.getTotalInventario();
      final int totalCantidad = await databaseProvider.getTotalCantidad();
      final double percentageInventario = await databaseProvider.getPercentageInventario();
      final String formattedPercentageInventario = percentageInventario.isNaN ? '0%' : '${percentageInventario.toStringAsFixed(2)}%';

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? email = prefs.getString('email');
      String emailText = email ?? 'Desconocido';
      String? idioma = prefs.getString('idioma');

      final double percentageCantidad = await databaseProvider.getPercentageCantidad();
      final String formattedPercentageCantidad = percentageCantidad.isNaN ? '0%' : '${percentageCantidad.toStringAsFixed(2)}%';
      final int totalProductosDesconocidos = await databaseProvider.getTotalProductosDesconocidos();
      final double percentageProductosDesconocidos = await databaseProvider.getPercentageProductosDesconocidos();
      final String formattedPercentageProductosDesconocidos = percentageProductosDesconocidos.isNaN ? '0%' : '${percentageProductosDesconocidos.toStringAsFixed(2)}%';

      final Uint8List watermarkImage = (await rootBundle.load('imagenes/MYCODESERVICE.png')).buffer.asUint8List();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Container(
              decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFE0E0E0)),
              padding: const pw.EdgeInsets.all(20),
              child: pw.Stack(
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Header(
                        child: pw.Text(
                          idioma == 'Español' ?
                          'ESTADISITICAS TOTALES' :
                          'TOTAL STATS',
                          style: pw.TextStyle(fontSize: 30, font: pw.Font.helveticaBold()),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 20),
                        child: pw.Text(
                          idioma == 'Español' ?
                          'Estadisticas del usuario: $emailText' :
                          'Stats from the user: $emailText' ,
                          style: const pw.TextStyle(fontSize: 10,),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 20),
                        child: pw.Text(
                          idioma == 'Español' ?
                          'Fecha: $horaLocal' :
                          'Date: $horaLocal',
                          style: const pw.TextStyle(fontSize: 10,),
                        ),
                      ),
                      pw.Table.fromTextArray(
                        border: null,
                        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFC0C0C0)),
                        cellHeight: 30,
                        cellAlignments: {
                          0: pw.Alignment.centerLeft,
                          1: pw.Alignment.centerRight,
                        },
                        columnWidths: {
                          0: const pw.FractionColumnWidth(0.7),
                          1: const pw.FractionColumnWidth(0.3),
                        },
                        headers: [
                          idioma == 'Español' ? 'Descripción' : 'Description',
                          idioma == 'Español' ? 'Valor' : 'Value'
                        ],
                        data: [
                          [idioma == 'Español' ? 'Número total de elementos' : 'Total number of elements', '$totalElements'],
                          [idioma == 'Español' ? 'Número total de elementos en inventario' : 'Total number of inventory items', '$totalInventario'],
                          [idioma == 'Español' ? 'Número total de elementos en cantidades' : 'Total number of items in quantities', '$totalCantidad'],
                          [idioma == 'Español' ? 'Porcentaje de elementos en inventario' : 'Percentage of items in inventory', formattedPercentageInventario],
                          [idioma == 'Español' ? 'Porcentaje de elementos en cantidades' : 'Percentage of items in quantities', formattedPercentageCantidad],
                          [idioma == 'Español' ? 'Número total de productos desconocidos' : 'Total number of unknown products', '$totalProductosDesconocidos'],
                          [idioma == 'Español' ? 'Porcentaje de productos desconocidos' : 'Percentage of unknown products', formattedPercentageProductosDesconocidos],
                        ],
                      ),
                    ],
                  ),

                  pw.Positioned(
                    right: 20,
                    bottom: 20,
                    child: pw.Image(pw.MemoryImage(watermarkImage), width: 100, height: 100),
                  ),
                ],
              ),
            );
          },
        ),
      );

      final Uint8List pdfBytes = await pdf.save();
      final output = await getTemporaryDirectory();
      File file;

      if(idioma=="Español"){
         file = File("${output.path}/estadisticas.pdf");

      }else{
         file = File("${output.path}/stats.pdf");
      }
      await file.writeAsBytes(pdfBytes);
      await Share.shareFiles([file.path], text: idioma == 'Español' ? ' PDF Estadisticas: $horaLocal' : 'PDF Stats: $horaLocal');

    } catch (e) {

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Hubo un error al generar el PDF: $e'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
