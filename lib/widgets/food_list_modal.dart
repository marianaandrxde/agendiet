import 'package:flutter/material.dart';
import 'package:agendiet/views/edit_meal_view.dart';

class FoodListModal extends StatelessWidget {
  final List<Map<String, dynamic>> refeicoes;  // Alterado para List<Map<String, dynamic>>
  final String periodo;

  const FoodListModal({super.key, required this.refeicoes, required this.periodo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Alimentos para $periodo',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...refeicoes.map((refeicao) => ListTile(
                title: Text(refeicao['nome'] ?? 'Nome não disponível'), // Usando chave do mapa
                subtitle: Text('Tag: ${refeicao['tag'] ?? 'Tag não disponível'}'), // Usando chave do mapa
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        _editMeal(context, refeicao); // Passa o mapa inteiro
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteMeal(context, refeicao); // Passa o mapa inteiro
                      },
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  void _editMeal(BuildContext context, Map<String, dynamic> refeicao) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMealScreen(refeicao: refeicao), // Passa o mapa inteiro
      ),
    );
  }

  void _deleteMeal(BuildContext context, Map<String, dynamic> refeicao) {
    // Lógica para excluir o alimento, usando o 'id' do mapa
    print("Excluir refeição com id: ${refeicao['id']}");
    // Aqui você pode chamar uma função de exclusão que passe o id para a API
  }
}
