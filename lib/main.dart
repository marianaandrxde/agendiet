import 'package:agendiet/views/home_view.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AgenDiet',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    if (email.isNotEmpty && password.isNotEmpty) {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/login'),
        body: jsonEncode({'email': email, 'senha': password}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userName = data['name'];
        final userId = data['id'];

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeView(userName: userName, userId: userId),
          ),
        );
      } else {
        _showDialog('Erro', 'Credenciais inválidas ou erro na requisição.');
      }
    } else {
      _showDialog('Erro', 'Preencha todos os campos.');
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
      ),
    );
  }

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'AgenDiet',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 40),
            _buildTextField(_emailController, 'E-mail', Icons.email, false),
            const SizedBox(height: 16),
            _buildTextField(_passwordController, 'Senha', Icons.lock, true),
            const SizedBox(height: 24),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, bool obscureText) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[200],
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      obscureText: obscureText,
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _login,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Entrar'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton(
            onPressed: _navigateToRegister,
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Cadastrar'),
          ),
        ),
      ],
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _register() async {
    String name = _nameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/registrar-usuario'),
        body: jsonEncode({'name': name, 'email': email, 'password': password, 'eh_nutricionista': false}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        _showDialog('Cadastro realizado', 'Conta criada com sucesso!');
        Navigator.pop(context);
      } else {
        _showDialog('Erro', 'Falha no cadastro. Tente novamente.');
      }
    } else {
      _showDialog('Erro', 'Preencha todos os campos.');
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, bool obscureText) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[200],
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      obscureText: obscureText,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildTextField(_nameController, 'Nome', Icons.person, false),
            const SizedBox(height: 16),
            _buildTextField(_emailController, 'E-mail', Icons.email, false),
            const SizedBox(height: 16),
            _buildTextField(_passwordController, 'Senha', Icons.lock, true),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _register,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Registrar'),
            ),
          ],
        ),
      ),
    );
  }
}
