import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(MyApp());
}

final FlutterSecureStorage secureStorage = FlutterSecureStorage();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guardar Contraseña Segura',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _passwordController = TextEditingController();
  String _resultado = '';
  bool _mostrarPassword = false;

  Future<void> _guardarPassword() async {
    await secureStorage.write(key: 'password', value: _passwordController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Contraseña guardada de forma segura')),
    );
  }

  Future<void> _leerPassword() async {
    final valor = await secureStorage.read(key: 'password');
    setState(() {
      _resultado = valor ?? 'No hay contraseña guardada';
    });
  }

  Future<void> _eliminarPassword() async {
    await secureStorage.delete(key: 'password');
    setState(() {
      _resultado = 'Contraseña eliminada';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gestor de Contraseña Segura')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Introduce tu contraseña:', style: TextStyle(fontSize: 16)),
            TextField(
              controller: _passwordController,
              obscureText: !_mostrarPassword,
              decoration: InputDecoration(
                hintText: '••••••••',
                suffixIcon: IconButton(
                  icon: Icon(
                    _mostrarPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _mostrarPassword = !_mostrarPassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _guardarPassword,
              child: Text('Guardar'),
            ),
            ElevatedButton(
              onPressed: _leerPassword,
              child: Text('Leer'),
            ),
            ElevatedButton(
              onPressed: _eliminarPassword,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Eliminar'),
            ),
            const SizedBox(height: 20),
            Text('Resultado: $_resultado'),
          ],
        ),
      ),
    );
  }
}
