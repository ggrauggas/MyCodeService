<div align="center">
  <img src="https://readme-typing-svg.demolab.com?font=Roboto+Mono&weight=600&size=28&duration=4000&pause=1000&color=5BCDEC&center=true&vCenter=true&width=500&lines=MyCodeService;Tu+gestor+de+códigos+de+barras+inteligente" alt="Typing SVG" />
</div>

<div align="center" style="margin: 20px 0;">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white">
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white">
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black">
  <img src="https://img.shields.io/badge/SQLite-003B57?style=for-the-badge&logo=sqlite&logoColor=white">
</div>

## 📱 Descripción del Proyecto

**MyCodeService** es una aplicación móvil desarrollada con Flutter que permite escanear, organizar y gestionar códigos de barras de manera eficiente. Ideal para inventarios, coleccionistas o cualquier usuario que necesite mantener un registro organizado de códigos de productos.

```dart
void main() {
  runApp(
    MaterialApp(
      home: CodeScannerApp(),
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blueAccent,
        accentColor: Colors.cyan[300],
      ),
    ),
  );
}
