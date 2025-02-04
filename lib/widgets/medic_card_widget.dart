import 'package:flutter/material.dart';
import 'package:agendiet/views/edit_medic.view.dart';
import 'package:http/http.dart' as http;

class MedicCard extends StatelessWidget {
  final Map<String, dynamic> medicacao;
  final VoidCallback onUpdate;

  const MedicCard({
    super.key,
    required this.medicacao,
    required this.onUpdate,
  });

  Future<void> _deleteMedicacao(BuildContext context) async {
    final id = medicacao['id_medicacao'];
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro: ID da medicação não encontrado')),
      );
      return;
    }

    final url = Uri.parse('http://10.0.2.2:8000/medicacoes/delete/$id');
    final response = await http.post(url);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medicação excluída com sucesso!')),
      );
      onUpdate();
    } else {
      print('Erro ao excluir medicação: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir: ${response.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Adicionando logs para depuração com as chaves corretas
    print('MedicCard - Horário: ${medicacao['horario_inicio']}');
    print('MedicCard - Nome: ${medicacao['nome']}');

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
            offset: const Offset(1, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(Icons.access_time, color: Colors.blueGrey),
                const SizedBox(width: 4),
                Text(
                  medicacao['horario_inicio'] ?? '00:00',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.medical_services, color: Colors.orange),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    medicacao['nome'] ?? 'Sem nome',
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditMedicScreen(medicacao: medicacao),
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
                      content: const Text("Tem certeza que deseja excluir esta medicação?"),
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
                    _deleteMedicacao(context);
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
