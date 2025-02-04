import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditMealScreen extends StatefulWidget {
  final Map<String, dynamic> refeicao;

  const EditMealScreen({super.key, required this.refeicao});

  @override
  _EditMealScreenState createState() => _EditMealScreenState();
}

class _EditMealScreenState extends State<EditMealScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nomeController;
  late TextEditingController _tagController;
  late TextEditingController _descricaoController;
  TimeOfDay? _horarioSelecionado;
  String? _diaSelecionado;
  String? _tagSelecionada;  // Variável para armazenar a tag selecionada

  final List<String> _diasDaSemana = [
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
    'Domingo'
  ];

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

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.refeicao['nome']);
    _tagSelecionada = widget.refeicao['tag'];  // Inicializa com a tag da refeição
    _descricaoController = TextEditingController(text: widget.refeicao['descricao']);
    _horarioSelecionado = _parseHorario(widget.refeicao['horario']);

    // Garantir que o dia selecionado esteja na lista de dias da semana
    if (_diasDaSemana.contains(widget.refeicao['dia'])) {
      _diaSelecionado = widget.refeicao['dia'];
    } else {
      _diaSelecionado = _diasDaSemana.first; // Define um valor padrão
    }
  }

  TimeOfDay? _parseHorario(String? horario) {
    if (horario == null || !horario.contains(':')) return null;
    final partes = horario.split(':');
    final int? horas = int.tryParse(partes[0]);
    final int? minutos = int.tryParse(partes[1]);
    if (horas != null && minutos != null) {
      return TimeOfDay(hour: horas, minute: minutos);
    }
    return null;
  }

  Future<void> _selecionarHorario() async {
    final TimeOfDay? novoHorario = await showTimePicker(
      context: context,
      initialTime: _horarioSelecionado ?? TimeOfDay.now(),
    );

    if (novoHorario != null) {
      setState(() {
        _horarioSelecionado = novoHorario;
      });
    }
  }

  Future<void> _updateMeal() async {
    final id = widget.refeicao['id'];
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro: ID do plano alimentar não encontrado')),
      );
      return;
    }

    final url = Uri.parse('http://10.0.2.2:8000/planos-alimentares/update/$id');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': _nomeController.text,
        'tag': _tagSelecionada,  // Utiliza a tag selecionada
        'horario': _horarioSelecionado != null
            ? '${_horarioSelecionado!.hour.toString().padLeft(2, '0')}:${_horarioSelecionado!.minute.toString().padLeft(2, '0')}'
            : null,
        'dia': _diaSelecionado,
        'descricao': _descricaoController.text,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plano Alimentar atualizado com sucesso!')),
      );
      Navigator.pop(context, "updated");
    } else {
      print('Erro ao atualizar plano alimentar: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${response.statusCode}')),
      );
    }
  }

  void _saveMeal() {
    if (_formKey.currentState!.validate()) {
      _updateMeal();
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
          'Editar Alimento',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
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
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _tagSelecionada,  // Usa a tag selecionada
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
