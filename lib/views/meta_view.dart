import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:agendiet/views/add_meta_view.dart';
import 'package:agendiet/domain/entities/meta_peso.dart';

class EstabelecerMetaView extends StatefulWidget {
  final int userId; // Passar o ID do usuário ao navegar

  EstabelecerMetaView({super.key, required this.userId});

  @override
  _EstabelecerMetaViewState createState() => _EstabelecerMetaViewState();
}

class _EstabelecerMetaViewState extends State<EstabelecerMetaView> {
  List<MetaPeso> metas = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchMetaPeso();
  }

  // Função para buscar as metas de peso do usuário
  Future<void> _fetchMetaPeso() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/metas-peso/get/${widget.userId}'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        setState(() {
          metas = data.map((metaJson) => MetaPeso.fromJson(metaJson)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Não há metas de peso definidas para este usuário.';
          isLoading = false;
        });
      }
    } else {
      setState(() {
        errorMessage = 'Erro ao carregar as metas de peso.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double containerWidth = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Estabeleça Suas Metas',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  if (errorMessage.isNotEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          errorMessage,
                          style: const TextStyle(color: Colors.red, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  if (metas.isNotEmpty) ...[
                    for (var meta in metas) ...[
                      Center(
                        child: Container(
                          width: containerWidth,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Estabeleça metas de peso e alcance-as',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Image.asset('images/img.png', height: 80),
                              const SizedBox(height: 16),
                              const Text(
                                'Nós acompanharemos sua jornada',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Container(
                          width: containerWidth,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Minha Meta',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '${meta.pesoPretendido} kg',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Até o dia',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${DateTime.parse(meta.dataLimite).day}/${DateTime.parse(meta.dataLimite).month}/${DateTime.parse(meta.dataLimite).year}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddMetaView(userId: widget.userId),
            ),
          );
        },
        backgroundColor: Colors.green.shade400,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
