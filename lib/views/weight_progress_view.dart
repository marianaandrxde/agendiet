import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

class ProgressView extends StatefulWidget {
  final int userId;
  
  const ProgressView({super.key, required this.userId});

  @override
  _ProgressViewState createState() => _ProgressViewState();
}

class _ProgressViewState extends State<ProgressView> {
  List<double> pesos = [];
  List<String> datas = [];
  double? metaPeso;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      // Buscar pesos
      final responsePesos = await http.get(
        Uri.parse('http://10.0.2.2:8000/pesos/get/${widget.userId}')
      );
      
      // Buscar metas de peso
      final responseMeta = await http.get(
        Uri.parse('http://10.0.2.2:8000/metas-peso/get/${widget.userId}')
      );

      if (responsePesos.statusCode == 200 && responseMeta.statusCode == 200) {
        final List<dynamic> pesosData = jsonDecode(responsePesos.body);
        final List<dynamic> metasData = jsonDecode(responseMeta.body);
      if (pesosData.isNotEmpty) {
        setState(() {
          pesos = pesosData.map((p) => (p['peso'] as num).toDouble()).toList();
          datas = pesosData.map((p) => p['data'].toString()).toList();
        });
      }

        if (metasData.isNotEmpty) {
          setState(() {
            metaPeso = metasData[0]['peso_pretendido'].toDouble();
          });
        }
      } else {
        setState(() {
          errorMessage = 'Erro ao carregar os dados';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erro na requisição: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progresso de Peso')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Evolução do Peso',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: LineChart(
                          LineChartData(
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    int index = value.toInt();
                                    return index < datas.length
                                        ? Text(datas[index].substring(5)) // Exibe MM-DD
                                        : const Text('');
                                  },
                                  reservedSize: 22,
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 32,
                                  getTitlesWidget: (value, meta) => Text('${value.toInt()} kg'),
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: true),
                            lineBarsData: [
                              LineChartBarData(
                                spots: pesos
                                    .asMap()
                                    .entries
                                    .map((e) => FlSpot(e.key.toDouble(), e.value))
                                    .toList(),
                                isCurved: true,
                                color: Colors.blue,
                                dotData: FlDotData(show: true),
                              ),
                              if (metaPeso != null)
                                LineChartBarData(
                                  spots: List.generate(
                                    pesos.length,
                                    (index) => FlSpot(index.toDouble(), metaPeso!),
                                  ),
                                  isCurved: false,
                                  color: Colors.red,
                                  dashArray: [5, 5],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
