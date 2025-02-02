import 'package:agendiet/views/edit_meal_view.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MealCard extends StatelessWidget {
  final Map<String, dynamic> refeicao;
  final VoidCallback onUpdate; // Função para atualizar a lista

  const MealCard({
    super.key,
    required this.refeicao,
    required this.onUpdate, // Adicionando a função de atualização
  });

  // Função para excluir a refeição da API
  Future<void> _deleteMeal(BuildContext context) async {
    final url = Uri.parse('http://10.0.2.2:8000/planos-alimentares/delete/${refeicao['id']}');

    final response = await http.delete(url);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Refeição excluída com sucesso!')),
      );
      onUpdate();  // Atualiza a lista após exclusão
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir: ${response.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, spreadRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${refeicao['nome']}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Divider(color: Colors.black26),
          Text(
            'Tag: ${refeicao['tag']}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${refeicao['descricao']}',
                  style: const TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () async {
                      // Aguardar o retorno da tela de edição
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditMealScreen(refeicao: refeicao),
                        ),
                      );

                      // Se o resultado for "updated", recarregar os dados
                      if (result == "updated") {
                        onUpdate();
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      // Exibir um diálogo de confirmação antes de excluir
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
                        _deleteMeal(context);  // Chama a função de exclusão
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
