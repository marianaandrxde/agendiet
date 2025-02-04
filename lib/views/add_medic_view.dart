import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

class AddMedicScreen extends StatefulWidget {
  final int userId;

  const AddMedicScreen({super.key, required this.userId});

  @override
  _AddMedicScreenState createState() => _AddMedicScreenState();
}

class _AddMedicScreenState extends State<AddMedicScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  bool _dosagemUnica = false;
  final TextEditingController _intervaloController = TextEditingController();
  String _horarioInicio = "";
  DateTime? _dataInicio;
  DateTime? _dataFim;
  bool _isSaving = false;

  // InputFormatter para permitir apenas números
  final TextInputFormatter _intervaloFormatter = FilteringTextInputFormatter.digitsOnly;

  Future<void> _selecionarData(BuildContext context, bool isInicio) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isInicio) {
          _dataInicio = picked;
        } else {
          _dataFim = picked;
        }
      });
    }
  }

  Future<void> _selecionarHorario(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _horarioInicio = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _salvarMedicacao() async {
    if (_formKey.currentState!.validate() && _dataInicio != null && _dataFim != null) {
      setState(() {
        _isSaving = true;
      });

      final medicacao = {
        "nome": _nomeController.text,
        "dosagem_unica": _dosagemUnica,
        "intervalo": _intervaloController.text,
        "data_inicio": _dataInicio!.toIso8601String().split('T')[0],
        "data_fim": _dataFim!.toIso8601String().split('T')[0],
        "horario_inicio": _horarioInicio
      };

      final response = await http.post(
        Uri.parse("http://10.0.2.2:8000/medicacoes/registrar/${widget.userId}"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(medicacao),
      );

      setState(() {
        _isSaving = false;
      });

      if (response.statusCode == 200) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao salvar medicação: ${response.body}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Adicionar Medicação"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Nome do medicamento
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: "Nome do medicamento",
                  prefixIcon: Icon(Icons.medical_services),
                ),
                validator: (value) => value!.isEmpty ? "Informe o nome do medicamento" : null,
              ),
              
              // Dosagem Única
              SwitchListTile(
                title: const Text("Dosagem única"),
                value: _dosagemUnica,
                onChanged: (value) {
                  setState(() {
                    _dosagemUnica = value;
                  });
                },
              ),

              // Intervalo - agora com restrição para aceitar apenas números
              TextFormField(
                controller: _intervaloController,
                decoration: const InputDecoration(
                  labelText: "Intervalo (em horas)",
                  prefixIcon: Icon(Icons.access_time),
                ),
                inputFormatters: [_intervaloFormatter],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Informe o intervalo de doses";
                  }
                  return null;
                },
              ),

              // Data de Início
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_dataInicio == null ? "Data início: Não selecionada" : "Início: ${_dataInicio!.toLocal()}".split(' ')[0]),
                  ElevatedButton(
                    onPressed: () => _selecionarData(context, true),
                    child: const Text("Selecionar"),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Data de Fim
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_dataFim == null ? "Data fim: Não selecionada" : "Fim: ${_dataFim!.toLocal()}".split(' ')[0]),
                  ElevatedButton(
                    onPressed: () => _selecionarData(context, false),
                    child: const Text("Selecionar"),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Botão de salvar
              _isSaving
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _salvarMedicacao,
                      child: const Text("Salvar"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}