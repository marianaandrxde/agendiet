import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:agendiet/widgets/meal_card_widget.dart';
import 'package:agendiet/views/add_meal_view.dart';
import 'package:agendiet/views/add_medic_view.dart'; 
import 'package:agendiet/widgets/medic_card_widget.dart';

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
  List<Map<String, dynamic>> _medicacoes = [];
  Map<String, bool> _isExpanded = {};
  String? _diversificacaoMensagem;
  IconData? _mensagemIcone;

  @override
  void initState() {
    super.initState();
    for (var dia in _diasDaSemana) {
      _isExpanded[dia] = false;
      _fetchDadosPorDia(dia);
    }
    _fetchMedicacoes();
  }

  Future<void> _fetchDadosPorDia(String dia) async {
    await _fetchRefeicoesPorDia(dia);
    _verificarDiversificacao();
  }

  Future<void> _fetchRefeicoesPorDia(String dia) async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/planos-alimentares/get/${widget.userId}/$dia'));

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

  Future<void> _fetchMedicacoes() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/medicacoes/get/${widget.userId}'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _medicacoes = data.map((item) => item as Map<String, dynamic>).toList();
      });
    } else {
      setState(() {
        _medicacoes = [];
      });
    }
  }

  void _verificarDiversificacao() {
    // Contando as tags nas refeições
    Map<String, int> tagContagem = {};

    // Iterando sobre todas as refeições
    for (var dia in _refeicoesPorDia.values) {
      for (var refeicao in dia) {
        String tag = refeicao['tag'] ?? '';
        tagContagem[tag] = (tagContagem[tag] ?? 0) + 1;
      }
    }

    // Verificando se há tags com mais de 3 refeições
    bool diversificada = true;
    for (var tag in tagContagem.keys) {
      if (tagContagem[tag]! >= 3) {
        diversificada = false;
        _diversificacaoMensagem = 'Você está consumindo bastante $tag, não acha? Que tal diversificar sua dieta?';
        _mensagemIcone = Icons.mood_bad; // Ícone de tristeza
        break;
      }
    }

    if (diversificada) {
      _diversificacaoMensagem = 'Você está com uma dieta diversificada! Continue assim.';
      _mensagemIcone = Icons.mood; // Ícone de felicidade
    }

    setState(() {});
  }

  Future<void> _deleteMedicacao(int id) async {
    final url = Uri.parse('http://10.0.2.2:8000/medicacoes/delete/$id');
    final response = await http.post(url);

    if (response.statusCode == 200) {
      setState(() {
        _medicacoes = _medicacoes.where((medicacao) => medicacao['id_medicacao'] != id).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medicação excluída com sucesso!')),
      );
    } else {
      print('Erro ao excluir medicação: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${response.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (_diversificacaoMensagem != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(_mensagemIcone, color: _mensagemIcone == Icons.mood ? Colors.green : Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_diversificacaoMensagem!),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
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
                    children: [
                      ...(_refeicoesPorDia[dia] ?? []).map((refeicao) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: MealCard(
                            refeicao: refeicao,
                            onUpdate: () => _fetchRefeicoesPorDia(dia),
                          ),
                        );
                      }).toList(),
                      ..._medicacoes.map((medicacao) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: MedicCard(
                            medicacao: medicacao,
                            onUpdate: _fetchMedicacoes,
                          ),
                        );
                      }).toList(),
                      if ((_refeicoesPorDia[dia]?.isEmpty ?? true) && _medicacoes.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Nenhuma refeição cadastrada.',
                            style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOptions(),
        backgroundColor: Colors.green.shade400,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.restaurant_menu, color: Colors.green),
              title: Text("Adicionar Refeição"),
              onTap: () async {
                Navigator.pop(context);
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
            ),
            ListTile(
              leading: Icon(Icons.medical_services, color: Colors.blue),
              title: Text("Adicionar Medicação"),
              onTap: () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddMedicScreen(userId: widget.userId)),
                );

                if (result == true) {
                  _fetchMedicacoes();
                }
              },
            ),
          ],
        );
      },
    );
  }
}