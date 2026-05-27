import 'package:cloud_firestore/cloud_firestore.dart';
import 'mock_ev_service.dart'; // To reuse EvTelemetry

class FirebaseEvService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<EvTelemetry> get telemetryStream {
    // Assuming a single document for the vehicle telemetry, e.g., 'telemetry/latest'
    return _firestore
        .collection('ev_live')
        .doc('current')
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        // Return a default if not found
        return EvTelemetry(
          soh: 100.0,
          percentage: 0.0,
          predictedRange: 0.0,
          actualRange: 0.0,
          temperature: 0.0,
        );
      }

      final data = snapshot.data()!;
      return EvTelemetry(
        soh: (data['soh'] ?? 0.0).toDouble(),
        percentage: (data['battery_percent'] ?? 0.0).toDouble(),
        predictedRange: (data['predicted_range'] ?? 0.0).toDouble(),
        actualRange: (data['actual_range'] ?? 0.0).toDouble(),
        temperature: (data['temperature'] ?? 30.0).toDouble(),
      );
    });
  }
}
