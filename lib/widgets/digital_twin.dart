import 'package:flutter/material.dart';

class DigitalTwinGraphic extends StatefulWidget {
  final bool isOverheating;

  const DigitalTwinGraphic({super.key, required this.isOverheating});

  @override
  State<DigitalTwinGraphic> createState() => _DigitalTwinGraphicState();
}

class _DigitalTwinGraphicState extends State<DigitalTwinGraphic> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800),
      )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // High quality 3D Tesla Render
          SizedBox(
            width: 320,
            height: 320,
            child: Image.asset(
              'assets/tesla.png',
              fit: BoxFit.contain,
            ),
          ),
          // Battery Pack positioned on the front bonnet
          Transform.translate(
            offset: const Offset(-60, 25), // Adjusted squarely onto the front bonnet
            child: Transform.rotate(
              angle: 0.0, // Upright straight
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  double opacity = widget.isOverheating ? (_pulseController.value * 0.6 + 0.4) : 0.0;
                  return Container(
                    width: 50,
                    height: 60,
                    decoration: BoxDecoration(
                      color: widget.isOverheating 
                          ? Colors.redAccent.withOpacity(opacity) 
                          : Colors.greenAccent.withOpacity(0.15),
                      border: Border.all(
                        color: widget.isOverheating ? Colors.redAccent : Colors.greenAccent.withOpacity(0.5), 
                        width: widget.isOverheating ? 3 : 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: widget.isOverheating ? [
                         BoxShadow(
                           color: Colors.redAccent.withOpacity(opacity),
                           blurRadius: 25 * _pulseController.value,
                           spreadRadius: 8 * _pulseController.value,
                         )
                      ] : [],
                    ),
                    child: Center(
                      child: Icon(
                        widget.isOverheating ? Icons.local_fire_department : Icons.battery_charging_full,
                        color: widget.isOverheating ? Colors.white : Colors.greenAccent.withOpacity(0.8), 
                        size: 24,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }


}
