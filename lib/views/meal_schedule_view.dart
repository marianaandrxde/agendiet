import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:agendiet/widgets/meal_card_widget.dart';
import 'package:agendiet/views/add_meal_view.dart';

class MealScheduleView extends StatefulWidget {
  final int userId;

  const MealScheduleView({super.key, required this.userId});

  @override
  _MealScheduleViewState createState() => _MealScheduleViewState();
}

class _MealScheduleViewState extends State<MealScheduleView> {
  final List<String> _diasDaSemana = [
    'Segunda-feira', 'Terça-feira', 'Quarta-feira',
    'Quinta-feira', 'Sexta-feira', 'Sábado', 'Domingo'
  ];

  Map<String, List<Map<String, dynamic>>> _refeicoesPorDia = {};
  Map<String, bool> _isExpanded = {};

  @override
  void initState() {
    super.initState();
    for (var dia in _diasDaSemana) {
      _isExpanded[dia] = false;
      _fetchRefeicoesPorDia(dia);
    }
  }

  Future<void> _fetchRefeicoesPorDia(String dia) async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/planos-alimentares/dia/$dia'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _refeicoesPorDia[dia] = data.map((item) => item as Map<String, dynamic>).toList();
      });
    } else {
      setState(() {
        _refeicoesPorDia[dia] = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Agenda de Refeições',
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _diasDaSemana.length,
        itemBuilder: (context, index) {
          final dia = _diasDaSemana[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(
                dia,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              initiallyExpanded: _isExpanded[dia]!,
              onExpansionChanged: (bool expanded) {
                setState(() {
                  _isExpanded[dia] = expanded;
                });
              },
              children: _refeicoesPorDia[dia]?.map((refeicao) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: MealCard(
                        refeicao: refeicao,
                        onUpdate: () => _fetchRefeicoesPorDia(dia),
                      ),
                    );
                  }).toList() ??
                  [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Nenhuma refeição cadastrada.',
                        style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                      ),
                    )
                  ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddMealScreen(userId: widget.userId)),
          );

          if (result == true) {
            for (var dia in _diasDaSemana) {
              _fetchRefeicoesPorDia(dia);
            }
          }
        },
        backgroundColor: Colors.green.shade400,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
