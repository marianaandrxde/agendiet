import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Para converter a resposta JSON
import 'package:agendiet/widgets/meal_card_widget.dart';
import 'package:agendiet/views/add_meal_view.dart';

class MealScheduleView extends StatefulWidget {
  final int userId;

  const MealScheduleView({super.key, required this.userId});

  @override
  _MealScheduleViewState createState() => _MealScheduleViewState();
}

class _MealScheduleViewState extends State<MealScheduleView> {
  List<Map<String, dynamic>> mealPlans = [];

  // Função para buscar planos alimentares
  Future<void> fetchMealPlans() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/planos-alimentares/get/${widget.userId}'));

    if (response.statusCode == 200) {
      // Se a resposta for bem-sucedida, parse o JSON
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        mealPlans = data.map((item) => item as Map<String, dynamic>).toList();
      });
    } else {
      throw Exception('Falha ao carregar planos alimentares');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMealPlans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Detalhes',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: mealPlans.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.restaurant_outlined,
                      size: 60,
                      color: Colors.green.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Você não possui refeições cadastradas.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Comece adicionando uma.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: mealPlans.length,
              itemBuilder: (context, index) {
                return MealCard(
                  refeicao: mealPlans[index],
                  onUpdate: fetchMealPlans, // Atualiza a lista ao editar/remover
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navega para a tela de adicionar refeição
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddMealScreen(userId: widget.userId)),
          );

          // Se a refeição foi adicionada, atualiza a lista
          if (result == true) {
            fetchMealPlans();
          }
        },
        backgroundColor: Colors.green.shade400,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
