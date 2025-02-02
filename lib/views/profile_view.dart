import 'dart:convert';
import 'package:agendiet/views/meta_view.dart';
import 'package:flutter/material.dart';
import 'package:agendiet/views/update_weight_view.dart';
import 'package:http/http.dart' as http;

class UserProfileView extends StatefulWidget {
  final String userName;
  final int userId;

  const UserProfileView({super.key, required this.userName, required this.userId});

  @override
  _UserProfileViewState createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  late Future<String> _latestWeight;

  @override
  void initState() {
    super.initState();
    _latestWeight = fetchLatestWeight(widget.userId);
  }

  Future<String> fetchLatestWeight(int userId) async {
    final url = Uri.parse('http://10.0.2.2:8000/pesos/latest/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['peso'].toString();  // Considerando que o campo peso está na resposta
    } else {
      throw Exception('Falha ao carregar peso');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.green.shade400,
                child: Text(
                  widget.userName.isNotEmpty ? widget.userName[0] : '',
                  style: const TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.userName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 32),
              FutureBuilder<String>(
                future: _latestWeight,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Text('Erro ao carregar peso');
                  } else if (snapshot.hasData) {
                    return Text(
                      'Peso mais recente: ${snapshot.data} kg',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    );
                  } else {
                    return const Text('Nenhum peso registrado');
                  }
                },
              ),
              const SizedBox(height: 32),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: <Widget>[
                  _buildQuadrant(
                    context, 'Atualize seu peso', Icons.accessibility,
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UpdateWeightScreen(userId: widget.userId),
                        ),
                      );
                      if (result == true) {
                        setState(() {
                          // Atualiza o peso após retornar da tela de atualização
                          _latestWeight = fetchLatestWeight(widget.userId);
                        });
                      }
                    },
                  ),
                  _buildQuadrant(
                    context, 'Visualize seu progresso', Icons.show_chart,
                    onTap: () {
                      print('Visualizar progresso');
                    },
                  ),
                  _buildQuadrant(
                    context, 'Estabeleça suas metas', Icons.flag,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EstabelecerMetaView(userId: widget.userId),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuadrant(BuildContext context, String title, IconData icon, {VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap ?? () {},
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                size: 40,
                color: Colors.green.shade400,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}