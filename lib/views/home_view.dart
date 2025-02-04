import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:agendiet/widgets/progress_widget.dart';
import 'package:agendiet/views/profile_view.dart';
import 'meal_schedule_view.dart';

class HomeView extends StatefulWidget {
  final int userId;
  final String userName;

  const HomeView({
    required this.userId,
    required this.userName,
    super.key,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;

  Future<Map<String, dynamic>> _fetchHomeData() async {
    final weightRecordsResponse = await http.get(
      Uri.parse('http://10.0.2.2:8000/pesos/get/${widget.userId}'),
    );

    final weightGoalResponse = {
      "id": 1,
      "pesoPretendido": 50.0,
      "foiAtingido": false,
    };

    if (weightRecordsResponse.statusCode == 200) {
      final weightRecords = jsonDecode(weightRecordsResponse.body);
      return {
        'weightRecords': weightRecords,
        'weightGoal': weightGoalResponse,
      };
    } else {
      throw Exception('Falha ao carregar dados da API');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Olá, ${widget.userName}!',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            CircleAvatar(
              backgroundColor: Colors.green[400],
              child: Text(
                widget.userName[0].toUpperCase(),
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
      body: _selectedIndex == 0
          ? FutureBuilder<Map<String, dynamic>>(
              future: _fetchHomeData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erro ao carregar dados',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return Center(
                    child: Text(
                      'Nenhum dado encontrado.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                } else {
                  final data = snapshot.data!;
                  final weightRecords = data['weightRecords'];
                  final weightGoal = data['weightGoal'];

                  final progressoMeta = weightGoal['pesoPretendido'] != 0
                      ? (weightRecords[0]['peso'] / weightGoal['pesoPretendido'])
                      : 0;

                  return SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Progresso da Meta de Peso'),
                        _buildCard(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Peso Atual: ${weightRecords[0]['peso']} kg',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Meta: ${weightGoal['pesoPretendido']} kg',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                              SizedBox(height: 12),
                              LinearProgressIndicator(
                                value: progressoMeta,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                              ),
                            ],
                          ),
                        ),
                        _buildSectionTitle('Últimas Atualizações'),
                        _buildWeightList(weightRecords),
                      ],
                    ),
                  );
                }
              },
            )
          : _selectedIndex == 1
              ? MealScheduleView(userId: widget.userId)
              : UserProfileView(userId: widget.userId, userName: widget.userName),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Agenda'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildCard(Widget child) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  Widget _buildWeightList(List<dynamic> weightRecords) {
    return Column(
      children: weightRecords
          .take(5)
          .map(
            (record) => Card(
              margin: EdgeInsets.only(bottom: 8),
              elevation: 3,
              child: ListTile(
                contentPadding: EdgeInsets.all(16),
                leading: Icon(Icons.timeline, color: Colors.green),
                title: Text(
                  'Peso: ${record['peso']} kg',
                  style: TextStyle(fontSize: 16),
                ),
                subtitle: Text(
                  'Data: ${DateTime.parse(record['data']).day}/${DateTime.parse(record['data']).month}/${DateTime.parse(record['data']).year}',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
