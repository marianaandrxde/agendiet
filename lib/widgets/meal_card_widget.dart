import 'package:agendiet/views/edit_meal_view.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MealCard extends StatelessWidget {
  final Map<String, dynamic> refeicao;
  final VoidCallback onUpdate;

  const MealCard({
    super.key,
    required this.refeicao,
    required this.onUpdate,
  });

  Future<void> _deleteMeal(BuildContext context) async {
    final url = Uri.parse('http://10.0.2.2:8000/planos-alimentares/delete/${refeicao['id']}');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Refeição excluída com sucesso!')),
      );
      onUpdate();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir: ${response.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            spreadRadius: 1,
            offset: Offset(1, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, color: Colors.blueGrey),
              const SizedBox(width: 4),
              Text(
                refeicao['horario'] ?? '00:00',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 16),
              Icon(Icons.restaurant, color: Colors.orange),
              const SizedBox(width: 4),
              Text(
                refeicao['descricao'] ?? 'Sem descrição',
                style: TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditMealScreen(refeicao: refeicao),
                    ),
                  );
                  if (result == "updated") {
                    onUpdate();
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  bool confirmDelete = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Confirmar Exclusão"),
                      content: const Text("Tem certeza que deseja excluir esta refeição?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancelar"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Excluir", style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );

                  if (confirmDelete) {
                    _deleteMeal(context);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}