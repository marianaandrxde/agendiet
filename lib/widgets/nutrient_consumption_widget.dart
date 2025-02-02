import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class NutrientConsumptionWidget extends StatelessWidget {
  final double pesoAtual;
  final double metaPeso;

  const NutrientConsumptionWidget({super.key, required this.pesoAtual, required this.metaPeso});

  @override
  Widget build(BuildContext context) {

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        width: MediaQuery.of(context).size.width * 0.8,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Proteínas',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                 LinearPercentIndicator(
                    width: 75.0,
                    lineHeight: 5.0,
                    percent: 0.3,
                    progressColor: Colors.blue,
                  ),
              ],
            ),
            const SizedBox(width: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Carboidratos',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                LinearPercentIndicator(
                    width: 75.0,
                    lineHeight: 5.0,
                    percent: 0.5,
                    progressColor: Colors.red,
                  ),
                const SizedBox(height: 4),
                
              ],
            ),
            const SizedBox(width: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Lipídios',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                 LinearPercentIndicator(
                    width: 75.0,
                    lineHeight: 5.0,
                    percent: 0.9,
                    progressColor: Colors.yellow,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
