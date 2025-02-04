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
  late TextEditingController _descricaoController;
  String? _tagSelecionada;
  String? _diaSelecionado;
  TimeOfDay? _horarioSelecionado;

  final List<String> _tagsPreexistentes = [
    'Carboidrato',
    'Proteína',
    'Gordura',
    'Fibra',
    'Vegetariano',
    'Vegano',
    'Sem glúten',
    'Sem lactose',
  ];

  final List<String> _diasDaSemana = [
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
    'Domingo'
  ];

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController();
    _descricaoController = TextEditingController();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _saveMeal() async {
    if (_formKey.currentState!.validate()) {
      if (_diaSelecionado == null || _horarioSelecionado == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione um dia e um horário.')),
        );
        return;
      }

      final url = Uri.parse('http://10.0.2.2:8000/planos-alimentares/registrar/${widget.userId}');

      final response = await http.post(
        url,
        body: json.encode({
          'nome': _nomeController.text,
          'id_usuario': widget.userId,
          'id_nutricionista': 1, // Preencha com o ID do nutricionista, se necessário
          'tag': _tagSelecionada, // Tag selecionada
          'descricao': _descricaoController.text,
          'horario': "${_horarioSelecionado!.hour.toString().padLeft(2, '0')}:${_horarioSelecionado!.minute.toString().padLeft(2, '0')}",
          'dia': _diaSelecionado, // Dia selecionado
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

  Future<void> _selecionarHorario() async {
    TimeOfDay? horarioEscolhido = await showTimePicker(
      context: context,
      initialTime: _horarioSelecionado ?? TimeOfDay.now(),
    );

    if (horarioEscolhido != null) {
      setState(() {
        _horarioSelecionado = horarioEscolhido;
      });
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
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
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
              DropdownButtonFormField<String>(
                value: _tagSelecionada,
                decoration: const InputDecoration(
                  labelText: 'Tag',
                  fillColor: Colors.white,
                  filled: true,
                ),
                items: _tagsPreexistentes.map((String tag) {
                  return DropdownMenuItem<String>(
                    value: tag,
                    child: Text(tag),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _tagSelecionada = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor, selecione uma tag';
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
              const SizedBox(height: 16),
              GestureDetector(
  onTap: _selecionarHorario,
  child: AbsorbPointer(
    child: TextFormField(
      decoration: InputDecoration(
        labelText: 'Horário',
        hintText: 'Selecione o horário',
        suffixIcon: const Icon(Icons.access_time),
        fillColor: Colors.white,
        filled: true,
      ),
      controller: TextEditingController(
        text: _horarioSelecionado != null
            ? "${_horarioSelecionado!.hour.toString().padLeft(2, '0')}:${_horarioSelecionado!.minute.toString().padLeft(2, '0')}"
            : "",
      ),
      validator: (value) {
        if (_horarioSelecionado == null) {
          return 'O horário é obrigatório';
        }
        return null;
      },
    ),
  ),
),

              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _diaSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Dia',
                  fillColor: Colors.white,
                  filled: true,
                ),
                items: _diasDaSemana.map((String dia) {
                  return DropdownMenuItem<String>(
                    value: dia,
                    child: Text(dia),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _diaSelecionado = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor, selecione um dia';
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
