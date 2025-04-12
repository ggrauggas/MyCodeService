// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../navegacion/navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key, required this.title});
  final String title;

  @override
  State<RegistroPage> createState() => _MyRegistroPageState();
}

class _MyRegistroPageState extends State<RegistroPage> {
  late Navigation navigation;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _showPassword = false;
  bool _uploading = false;
  String idioma = "Español";
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  @override
  void initState() {
    cargarIdioma();
    super.initState();
    navigation = Navigation(context);
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  Future<void> cargarIdioma() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      idioma = prefs.getString('idioma') ?? 'Español';
    });
  }

  void showToastMessage(String message) => Fluttertoast.showToast(
    msg: message,
  );

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> registerWithEmailAndPassword(String email, String password) async {
    if (password.length < 6) {
      showToastMessage(idioma == 'Español' ?
      'La contraseña debe tener al menos 6 caracteres ' :
      'The password must be at least 6 characters ');
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await FirebaseAuth.instance.currentUser!.sendEmailVerification();
      showToastMessage(idioma == 'Español' ?
      'Se ha enviado un correo de verificación ' :
      'A verification email has been sent ');

    } catch (e) {
      if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text(
                  idioma == 'Español' ?
                  'El correo ya está en uso. Por favor utilice otro correo ' :
                  'The email is already in use. Please use another email '),
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
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('ERROR'),
              content: Text(
                  idioma == 'Español' ?
                  'Ha habido un error en el registro ' :
                  'There has been an error in the registry'),
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

  void signInWithEmailAndPassword(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      saveEmail(_emailController.text.trim(), password);
      setState(() {
        _uploading = false;
      });
      showToastMessage(idioma == 'Español' ?
      'Inicio de sesión exitoso ' :
      'Successful login');
      _passwordController.clear();
      _emailController.clear();
      navigation.navigateToMenu();
    } catch (e) {
      setState(() {
        _uploading = false;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(idioma == 'Español' ?
            'Error en el inicio de sesión' :
            'Login failed'),
            content: Text(idioma == 'Español' ?
            'Por favor compruebe que las credenciales son correctas o que tiene conexión a internet.' :
            'Please check that the credentials are correct or you have acces to internet.'),
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

  Future<void> saveEmail(String email, String contrasena) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('contrasena_email', contrasena);
  }

  void _register() {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    registerWithEmailAndPassword(email, password);
  }

  void _signIn() {
    setState(() {
      _uploading = true;
    });
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    signInWithEmailAndPassword(email, password);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "MY CODE SERVICE",
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF3304F8),
        ),
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height - kToolbarHeight,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Color(0xFF7E57C2)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 1.8],
                tileMode: TileMode.clamp,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Image.asset(
                      'imagenes/profile.png',
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    idioma == 'Español' ? 'REGISTRO / INICIO DE SESIÓN' : 'REGISTER / LOGIN',
                    style: const TextStyle(
                      color: Color(0xFF3304F8),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    child: TextField(
                      focusNode: _emailFocus,
                      onSubmitted: (value) {
                        FocusScope.of(context).requestFocus(_passwordFocus);
                      },
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: idioma == 'Español' ? 'Introduce el correo electrónico...' : 'Enter your email...',
                        hintStyle: const TextStyle(color: Colors.black),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    child: TextField(
                      focusNode: _passwordFocus,
                      onSubmitted: (value) {
                        FocusScope.of(context).unfocus();
                      },
                      controller: _passwordController,
                      obscureText: !_showPassword,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                        hintText: idioma == 'Español' ? 'Introduce la contraseña...' : 'Enter your password...',
                        hintStyle: const TextStyle(color: Colors.black),
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                          icon: Icon(
                            _showPassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _uploading ? null : _signIn,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      backgroundColor: _uploading ? Colors.grey : const Color(0xFF1E0B89),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.login, size: 20, color: Colors.white),
                        const SizedBox(width: 5),
                        Text(
                          idioma == 'Español' ? 'INICIAR SESIÓN' : 'SIGN IN',
                          style: const TextStyle(fontSize: 15, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _uploading ? null : () {
                      if (_emailController.text.isEmpty) {
                        showToastMessage(idioma == "Español" ? "El email está vacío" : "The email is empty");
                      } else if (_emailController.text.contains("@") && _emailController.text.contains(".")) {
                        cambiarContrasena();
                      } else {
                        showToastMessage(idioma == "Español" ? "El formato del email no es correcto" : "The email format is incorrect");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      backgroundColor: _uploading ? Colors.grey : const Color(0xFF1E0B89),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.restore_page_outlined, size: 20, color: Colors.white),
                        const SizedBox(width: 5),
                        Text(
                          idioma == 'Español' ? 'ENVIAR EMAIL DE RESTAURACIÓN' : 'SEND RESTORE EMAIL',
                          style: const TextStyle(fontSize: 15, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _uploading ? null : _register,
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.black, fontSize: 20),
                        children: [
                          TextSpan(text: idioma == 'Español' ? '¿No tienes usuario aún?  ' : 'Not a user yet?  '),
                          TextSpan(
                            text: idioma == 'Español' ? 'Regístrate ahora' : 'Register now',
                            style: const TextStyle(color: Color(0xFF1E0B89)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> cambiarContrasena() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    String? email = _emailController.text;
    if (email != "") {
      try {
        await auth.sendPasswordResetEmail(email: email);
        showToastMessage(idioma == 'Español' ?
        'Correo electrónico enviado para cambiar la contraseña' : 'Email sent to change password',
        );
      } catch (error) {
        showToastMessage(idioma == 'Español' ?
        'Error al enviar el correo de restauración $error' : 'Error sending restoration email: $error');
      }
    } else {
      showToastMessage(idioma == 'Español' ?
      'No se pudo enviar el correo de restauración' : 'The restoration email could not be sent',
      );
    }
  }
}
