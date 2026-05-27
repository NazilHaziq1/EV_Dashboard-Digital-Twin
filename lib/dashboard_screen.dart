import 'package:flutter/material.dart';
import 'mock_ev_service.dart';
import 'firebase_ev_service.dart';
import 'widgets/digital_twin.dart';
import 'widgets/telemetry_card.dart';
import 'widgets/range_map.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseEvService _evService = FirebaseEvService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'EV Digital Twin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<EvTelemetry>(
        stream: _evService.telemetryStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final telemetry = snapshot.data!;
          bool isOverheating = telemetry.temperature > 45.0;

          return ListView(
            children: [
              if (isOverheating) _buildWarningBanner(),
              SizedBox(
                height: 350,
                child: _buildDigitalTwinArea(isOverheating),
              ),
              const SizedBox(height: 8),
              SizedBox(height: 360, child: _buildTelemetryCards(telemetry)),
              const SizedBox(height: 8),
              SizedBox(
                height: 350,
                child: RangeMap(predictedRange: telemetry.predictedRange),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWarningBanner() {
    return Container(
      width: double.infinity,
      color: Colors.redAccent,
      padding: const EdgeInsets.all(12.0),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.white),
          SizedBox(width: 8),
          Text(
            'CRITICAL: Battery Overheating!',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDigitalTwinArea(bool isOverheating) {
    return DigitalTwinGraphic(isOverheating: isOverheating);
  }

  Widget _buildTelemetryCards(EvTelemetry telemetry) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: TelemetryCard(
                    title: 'Battery SOH',
                    value: telemetry.soh.toStringAsFixed(1),
                    unit: '%',
                    icon: Icons.health_and_safety,
                    color: Colors.greenAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TelemetryCard(
                    title: 'Charge Level',
                    value: telemetry.percentage.toStringAsFixed(1),
                    unit: '%',
                    icon: Icons.battery_charging_full,
                    color: telemetry.percentage < 20
                        ? Colors.redAccent
                        : Colors.lightBlueAccent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: TelemetryCard(
                    title: 'Predicted Range',
                    value: telemetry.predictedRange.toStringAsFixed(0),
                    unit: 'km',
                    icon: Icons.map,
                    color: Colors.purpleAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TelemetryCard(
                    title: 'Actual Range',
                    value: telemetry.actualRange.toStringAsFixed(0),
                    unit: 'km',
                    icon: Icons.directions_car,
                    color: Colors.orangeAccent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: TelemetryCard(
                    title: 'Battery Temp',
                    value: telemetry.temperature.toStringAsFixed(1),
                    unit: '°C',
                    icon: Icons.thermostat,
                    color: telemetry.temperature > 40
                        ? Colors.redAccent
                        : Colors.orangeAccent,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: SizedBox.shrink(), // Empty space to keep layout balanced
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
