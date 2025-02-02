import 'dart:convert'; // Para manipulação do JSON
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UpdateWeightScreen extends StatefulWidget {
  final int userId; // ID do usuário

  const UpdateWeightScreen({super.key, required this.userId});

  @override
  _UpdateWeightScreenState createState() => _UpdateWeightScreenState();
}

class _UpdateWeightScreenState extends State<UpdateWeightScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _pesoController = TextEditingController();
  DateTime? _dataSelecionada;

  // Função que envia o peso para a API
  Future<void> _saveWeight() async {
    if (_formKey.currentState!.validate()) {
      if (_dataSelecionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione uma data.')),
        );
        return;
      }

      // Dados a serem enviados para a API
      final weightData = {
        'peso': double.parse(_pesoController.text),
        'data': _dataSelecionada.toString().split(' ')[0], // Apenas a data, sem hora
      };

      try {
        // Enviar a requisição para a API
        final response = await http.post(
          Uri.parse('http://10.0.2.2:8000/pesos/registrar/${widget.userId}'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(weightData),
        );

        if (response.statusCode == 200) {
          // Se a resposta for positiva, mostra uma mensagem de sucesso
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Peso registrado com sucesso!')),
          );
          Navigator.pop(context); // Voltar para a tela anterior
        } else {
          // Se a resposta for diferente de 200, mostra um erro
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: ${response.body}')),
          );
        }
      } catch (e) {
        // Em caso de erro na requisição
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro de rede: $e')),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green, 
              onPrimary: Colors.white, 
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.green, 
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _dataSelecionada = pickedDate;
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
          'Atualizar Peso',
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
                controller: _pesoController,
                decoration: const InputDecoration(
                  labelText: 'Peso',
                  hintText: 'Digite seu peso',
                  fillColor: Colors.white,
                  filled: true,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'O peso é obrigatório';
                  }
                  final peso = double.tryParse(value);
                  if (peso == null || peso <= 0) {
                    return 'Digite um peso válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Data'),
                subtitle: Text(
                  _dataSelecionada == null
                      ? 'Selecione uma data'
                      : '${_dataSelecionada!.day}/${_dataSelecionada!.month}/${_dataSelecionada!.year}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveWeight,
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
