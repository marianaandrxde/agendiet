import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

class EditMedicScreen extends StatefulWidget {
  final Map<String, dynamic> medicacao;

  const EditMedicScreen({super.key, required this.medicacao});

  @override
  _EditMedicScreenState createState() => _EditMedicScreenState();
}

class _EditMedicScreenState extends State<EditMedicScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nomeController;
  late TextEditingController _intervaloController;
  late TextEditingController _dataInicioController;
  late TextEditingController _dataFimController;
  late TextEditingController _horarioInicioController;
  bool _dosagemUnica = false;
  bool _isSaving = false;

  // InputFormatter para permitir apenas números
  final TextInputFormatter _intervaloFormatter = FilteringTextInputFormatter.digitsOnly;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.medicacao['nome']);
    _intervaloController = TextEditingController(text: widget.medicacao['intervalo']);
    _dataInicioController = TextEditingController(text: widget.medicacao['data_inicio']);
    _dataFimController = TextEditingController(text: widget.medicacao['data_fim']);
    _horarioInicioController = TextEditingController(text: widget.medicacao['horario_inicio']);
    _dosagemUnica = widget.medicacao['dosagem_unica'] ?? false;
  }

  Future<void> _selecionarHorario(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _horarioInicioController.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  // Função para selecionar a data
  Future<void> _selecionarData(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.toLocal()}".split(' ')[0];  // Formata a data para YYYY-MM-DD
      });
    }
  }

  Future<void> _updateMedic() async {
    final id = widget.medicacao['id_medicacao'];
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro: ID da medicação não encontrado')),
      );
      return;
    }

    final url = Uri.parse('http://10.0.2.2:8000/medicacoes/update/$id');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': _nomeController.text,
        'dosagem_unica': _dosagemUnica,
        'intervalo': _intervaloController.text,
        'data_inicio': _dataInicioController.text,
        'data_fim': _dataFimController.text,
        'horario_inicio': _horarioInicioController.text,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medicação atualizada com sucesso!')),
      );
      Navigator.pop(context, "updated");
    } else {
      print('Erro ao atualizar medicação: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${response.statusCode}')),
      );
    }
  }

  Future<void> _deleteMedic() async {
    final id = widget.medicacao['id'];
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
      Navigator.pop(context, "deleted");
    } else {
      print('Erro ao excluir medicação: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${response.statusCode}')),
      );
    }
  }

  void _saveMedic() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });
      _updateMedic();
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
          'Editar Medicação',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteMedic(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              // Nome do medicamento
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  hintText: 'Digite o nome do medicamento',
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
              // Dosagem Única
              SwitchListTile(
                title: const Text('Dosagem Única'),
                value: _dosagemUnica,
                onChanged: (bool value) {
                  setState(() {
                    _dosagemUnica = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Intervalo - agora com restrição para aceitar apenas números
              TextFormField(
                controller: _intervaloController,
                decoration: const InputDecoration(
                  labelText: 'Intervalo (em horas)',
                  hintText: 'Digite o intervalo de doses',
                  fillColor: Colors.white,
                  filled: true,
                ),
                inputFormatters: [_intervaloFormatter],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'O intervalo é obrigatório';
                  } else if (int.tryParse(value) == null) {
                    return 'Informe um número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Data de Início com DatePicker
              GestureDetector(
                onTap: () => _selecionarData(context, _dataInicioController),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _dataInicioController,
                    decoration: const InputDecoration(
                      labelText: 'Data de Início',
                      hintText: 'Escolha a data de início (YYYY-MM-DD)',
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'A data de início é obrigatória';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Data de Fim com DatePicker
              GestureDetector(
                onTap: () => _selecionarData(context, _dataFimController),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _dataFimController,
                    decoration: const InputDecoration(
                      labelText: 'Data de Fim',
                      hintText: 'Escolha a data de fim (YYYY-MM-DD)',
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'A data de fim é obrigatória';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Horário de Início
              GestureDetector(
                onTap: () => _selecionarHorario(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _horarioInicioController,
                    decoration: const InputDecoration(
                      labelText: 'Horário de Início',
                      hintText: 'Escolha o horário de início (HH:MM)',
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'O horário de início é obrigatório';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Botão de salvar
              _isSaving
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveMedic,
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
