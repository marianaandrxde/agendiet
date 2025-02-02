import 'package:flutter/material.dart';
import 'package:arc_progress_bar_new/arc_progress_bar_new.dart';

class ProgressSquareWidget extends StatelessWidget {
  final double pesoAtual;
  final double metaPeso; 

  const ProgressSquareWidget({super.key, required this.pesoAtual, required this.metaPeso});

  @override
  Widget build(BuildContext context) {
    double progresso = (pesoAtual / metaPeso).clamp(0.0, 1.0); 
    double pesoRestante = metaPeso - pesoAtual;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        width: MediaQuery.of(context).size.width * 0.8, 
        height: 150, 
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(16), 
        ),
        child: Stack(
          alignment: Alignment.topCenter, 
          children: [
            ArcProgressBar(
              percentage: progresso * 100, 
              arcThickness: 15,
              innerPadding: 48,
              strokeCap: StrokeCap.round,
              handleSize: 10,
              backgroundColor: Colors.black12,
              foregroundColor: Colors.white
            ),
            Positioned(
              bottom: 20, 
              child: Column(
                children: [
                  Text(
                    '${pesoRestante.toStringAsFixed(1)} kg', 
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'restantes', 
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
