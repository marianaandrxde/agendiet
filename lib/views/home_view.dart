import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:agendiet/widgets/nutrient_consumption_widget.dart';
import 'package:agendiet/widgets/progress_widget.dart';
import 'package:agendiet/views/profile_view.dart';
import 'meal_schedule_view.dart';

class HomeView extends StatefulWidget {
  final int userId; // ID do usuário logado
  final String userName; // Nome do usuário

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
    // final weightGoalResponse = await http.get(
    //   Uri.parse('http://127.0.0.1:8000/metas-peso/get/${widget.userId}'),
    // );
  final weightGoalResponse = {
    "id": 1,  // Use número inteiro em vez de string para id
    "idUsuario": 1,  // Também é inteiro
    "pesoPretendido": 50.0,  // O peso é um número de ponto flutuante
    "dataInicio": DateTime(2023, 1, 1),  // DateTime para representar datas
    "dataLimite": DateTime(2023, 12, 31),  // Outro DateTime
    "foiAtingido": false,  // Booleano para indicar se foi atingido
  };

    if (weightRecordsResponse.statusCode == 200) {
      final weightRecords = jsonDecode(weightRecordsResponse.body);
    //  final weightGoal = jsonDecode(weightGoalResponse.body);

      final weightGoal = weightGoalResponse;

      return {
        'weightRecords': weightRecords,
        'weightGoal': weightGoal,
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
      backgroundColor: Colors.white,
      appBar: _selectedIndex == 0
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Olá!',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.pink,
                    child: Text(
                      'M',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
          : null,
      body: _selectedIndex == 0
          ? FutureBuilder<Map<String, dynamic>>(
  future: _fetchHomeData(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
      return Center(
        child: Text('Erro ao carregar dados: ${snapshot.error}'),
      );
    } else if (!snapshot.hasData || snapshot.data == null) {
      return const Center(child: Text('Nenhum dado encontrado.'));
    } else {
      final data = snapshot.data!;

      // Verifique se o 'weightRecords' é uma lista válida
      final weightRecords = data['weightRecords'];
      if (weightRecords is List && weightRecords.isNotEmpty) {
        // Ordena os registros de peso pelo id de forma crescente, 
        // depois seleciona o último, que terá o maior id (mais antigo)
       weightRecords.sort((a, b) => a['id'] < b['id'] ? 1 : -1);

        final latestWeight = weightRecords[0]; // O registro com maior 'id'
        final currentWeight = latestWeight['peso']; // Acessa o peso mais recente
        final weightGoal = data['weightGoal'];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProgressSquareWidget(
              pesoAtual: currentWeight,
              metaPeso: weightGoal['pesoPretendido'],
            ),
            const SizedBox(height: 16),
            NutrientConsumptionWidget(
              pesoAtual: currentWeight,
              metaPeso: weightGoal['pesoPretendido'],
            ),
          ],
        );
      } else {
        return const Center(child: Text('Nenhum registro de peso encontrado.'));
      }
                }
              },
            )
          : _selectedIndex == 1
              ? MealScheduleView(userId: widget.userId,)
              : UserProfileView(userId: widget.userId, userName: widget.userName), 
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Agenda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
    );
  }
}
