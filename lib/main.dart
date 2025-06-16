import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(HomePage());
}

final FlutterSecureStorage secureStorage = FlutterSecureStorage();

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();

  final nombreCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final telefonoCtrl = TextEditingController();
  final nacimientoCtrl = TextEditingController();
  final edadCtrl = TextEditingController();

  String _resultado = '';

  Future<void> _guardarDatos() async {
    if (_formKey.currentState!.validate()) {
      await secureStorage.write(key: 'nombre', value: nombreCtrl.text);
      await secureStorage.write(key: 'email', value: emailCtrl.text);
      await secureStorage.write(key: 'telefono', value: telefonoCtrl.text);
      await secureStorage.write(key: 'nacimiento', value: nacimientoCtrl.text);
      await secureStorage.write(key: 'edad', value: edadCtrl.text);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Datos guardados de forma segura')),
      );
    }
  }

  Future<void> _leerDatos() async {
    final Map<String, String> todos = await secureStorage.readAll();

    if (todos.isEmpty) {
      setState(() {
        _resultado = 'No hay datos guardados';
      });
      return;
    }

    String resultado = '';
    todos.forEach((clave, valor) {
      resultado += '$clave: $valor\n';
    });

    setState(() {
      _resultado = resultado;
    });
  }

  Future<void> _eliminarDatos() async {
    await secureStorage.deleteAll();
    setState(() {
      _resultado = 'Todos los datos han sido eliminados';
    });
  }

  Widget _campo({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType tipo = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: tipo,
      decoration: InputDecoration(labelText: label),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gestión de Datos Sensibles')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _campo(
                  label: 'Nombre',
                  controller: nombreCtrl,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre no puede estar vacío';
                    }
                    if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ ]+$').hasMatch(value)) {
                      return 'Nombre inválido';
                    }
                    return null;
                  },
                ),
                _campo(
                  label: 'Email',
                  controller: emailCtrl,
                  tipo: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El correo no puede estar vacío';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Correo inválido';
                    }
                    return null;
                  },
                ),
                _campo(
                  label: 'Teléfono',
                  controller: telefonoCtrl,
                  tipo: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El teléfono no puede estar vacío';
                    }
                    if (!RegExp(r'^\d{10,}$').hasMatch(value)) {
                      return 'Número inválido (mínimo 10 dígitos)';
                    }
                    return null;
                  },
                ),
                _campo(
                  label: 'Fecha de nacimiento (AAAA-MM-DD)',
                  controller: nacimientoCtrl,
                  tipo: TextInputType.datetime,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La fecha no puede estar vacía';
                    }
                    try {
                      DateTime.parse(value);
                    } catch (_) {
                      return 'Formato inválido (usa AAAA-MM-DD)';
                    }
                    return null;
                  },
                ),
                _campo(
                  label: 'Edad',
                  controller: edadCtrl,
                  tipo: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La edad no puede estar vacía';
                    }
                    final edad = int.tryParse(value);
                    if (edad == null || edad < 1 || edad > 120) {
                      return 'Edad inválida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(onPressed: _guardarDatos, child: Text('Guardar')),
                ElevatedButton(onPressed: _leerDatos, child: Text('Leer')),
                ElevatedButton(
                  onPressed: _eliminarDatos,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text('Eliminar'),
                ),
                const SizedBox(height: 20),
                Text('Resultado:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(_resultado),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
