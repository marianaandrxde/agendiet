import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';  // Para converter a resposta JSON

class EditMealScreen extends StatefulWidget {
  final Map<String, dynamic> refeicao;  // Alterado para Map<String, dynamic>

  const EditMealScreen({super.key, required this.refeicao});

  @override
  _EditMealScreenState createState() => _EditMealScreenState();
}

class _EditMealScreenState extends State<EditMealScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nomeController;
  late TextEditingController _tagController;
  late TextEditingController _descricaoController;

  String? _periodoDoDia;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.refeicao['nome']);
    _tagController = TextEditingController(text: widget.refeicao['tag']);
    _descricaoController = TextEditingController(text: widget.refeicao['descricao']);
    _periodoDoDia = widget.refeicao['periodoDoDia'];  // Adaptação para o mapa
  }

  // Função para enviar a atualização do plano alimentar ao backend
Future<void> _updateMeal() async {
  final url = Uri.parse('http://10.0.2.2:8000/planos-alimentares/update/${widget.refeicao['id']}');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'nome': _nomeController.text,
      'tag': _tagController.text,
      'periodoDoDia': _periodoDoDia!,
      'descricao': _descricaoController.text,
    }),
  );

  if (response.statusCode == 200) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Plano Alimentar atualizado com sucesso!')),
    );
    Navigator.pop(context, "updated"); // Retorna "updated" ao fechar a tela
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro: ${response.statusCode}')),
    );
  }
}


  void _saveMeal() {
    if (_formKey.currentState!.validate()) {
      _updateMeal();  // Chama a função que envia a atualização para o servidor
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Editar Alimento',
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  hintText: 'Digite o nome do alimento',
                  fillColor: Colors.white,
                  filled: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'O nome é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tagController,
                decoration: const InputDecoration(
                  labelText: 'Tag',
                  hintText: 'Digite a tag (ex: Carboidrato, Proteína)',
                  fillColor: Colors.white,
                  filled: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'A tag é obrigatória';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _periodoDoDia,
                decoration: const InputDecoration(
                  labelText: 'Período do Dia',
                  fillColor: Colors.white,
                  filled: true,
                ),
                items: ['Manhã', 'Tarde', 'Noite']
                    .map((periodo) => DropdownMenuItem<String>(
                          value: periodo,
                          child: Text(periodo),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _periodoDoDia = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Selecione o período do dia';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'Digite uma descrição para o alimento',
                  fillColor: Colors.white,
                  filled: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'A descrição é obrigatória';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveMeal,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Salvar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
