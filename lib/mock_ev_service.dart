import 'dart:async';
import 'dart:math';

class EvTelemetry {
  final double soh; // State of Health (0-100)
  final double percentage; // Battery Percentage (0-100)
  final double predictedRange; // km
  final double actualRange; // km
  final double temperature; // Celsius

  EvTelemetry({
    required this.soh,
    required this.percentage,
    required this.predictedRange,
    required this.actualRange,
    required this.temperature,
  });
}

class MockEvService {
  Stream<EvTelemetry> get telemetryStream async* {
    final random = Random();
    
    double currentSoh = 98.2;
    double currentPercentage = 85.0;
    double currentTemperature = 35.0; // Normal operating temp
    
    while (true) {
      await Future.delayed(const Duration(seconds: 1));
      
      // Add slight noise to temperature
      currentTemperature += (random.nextDouble() * 1.5) - 0.75; 
      
      // Randomly spike temperature above 45
      if (random.nextDouble() > 0.96) {
         currentTemperature += 4.0;
      }
      
      // Auto cooling if it goes too extreme
      if (currentTemperature > 52) {
         currentTemperature -= 3.0;
      }
      if (currentTemperature < 30) {
         currentTemperature += 2.0;
      }
      
      // Deplete battery
      currentPercentage -= 0.02;
      currentPercentage = currentPercentage.clamp(0.0, 100.0);
      
      double predictedRange = currentPercentage * 4.5;
      double actualRange = predictedRange * (0.95 + random.nextDouble() * 0.1);
      
      yield EvTelemetry(
        soh: currentSoh,
        percentage: currentPercentage,
        predictedRange: predictedRange,
        actualRange: actualRange,
        temperature: currentTemperature,
      );
    }
  }
}
