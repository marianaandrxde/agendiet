import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddMealScreen extends StatefulWidget {
  final int userId;

  const AddMealScreen({super.key, required this.userId});

  @override
  _AddMealScreenState createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nomeController;
  late TextEditingController _tagController;
  late TextEditingController _descricaoController;

  String? _periodoDoDia;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController();
    _tagController = TextEditingController();
    _descricaoController = TextEditingController();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _tagController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _saveMeal() async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse(
          'http://10.0.2.2:8000/planos-alimentares/registrar/${widget.userId}');

      // Mapear o período para os valores esperados pela API
      String periodoApi = '';
      if (_periodoDoDia == 'Manhã') {
        periodoApi = 'M';
      } else if (_periodoDoDia == 'Tarde') {
        periodoApi = 'T';
      } else if (_periodoDoDia == 'Noite') {
        periodoApi = 'N';
      }

      final response = await http.post(
        url,
        body: json.encode({
          'nome': _nomeController.text,
          'id_usuario': widget.userId, // Pegar o userId diretamente
          'id_nutricionista': 1, // Preencha com o ID do nutricionista, se necessário
          'tag': _tagController.text,
          'descricao': _descricaoController.text,
          'periodoDoDia': periodoApi,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('Plano Alimentar registrado com sucesso!');
        Navigator.pop(context, true);
      } else {
        print('Erro ao salvar plano alimentar');
      }
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
        title: const Text(
          'Adicionar refeição',
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context, true);
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
