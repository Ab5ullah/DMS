import 'package:flutter/material.dart';
import '../models/tooth_treatment_model.dart';

class DentalChartWidget extends StatefulWidget {
  final int patientId;
  final Map<int, ToothStatus> toothStatuses;
  final Function(int toothNumber) onToothTap;

  const DentalChartWidget({
    super.key,
    required this.patientId,
    required this.toothStatuses,
    required this.onToothTap,
  });

  @override
  State<DentalChartWidget> createState() => _DentalChartWidgetState();
}

class _DentalChartWidgetState extends State<DentalChartWidget> {
  int? hoveredTooth;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          // Legend
          _buildLegend(),
          const SizedBox(height: 24),

          // Upper jaw
          _buildJawLabel('Upper Jaw'),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildQuadrant(1, isUpper: true, isRight: true), // Upper Right: 11-18
              const SizedBox(width: 40),
              _buildQuadrant(2, isUpper: true, isRight: false), // Upper Left: 21-28
            ],
          ),

          const SizedBox(height: 40),

          // Lower jaw
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildQuadrant(4, isUpper: false, isRight: true), // Lower Right: 41-48
              const SizedBox(width: 40),
              _buildQuadrant(3, isUpper: false, isRight: false), // Lower Left: 31-38
            ],
          ),
          const SizedBox(height: 12),
          _buildJawLabel('Lower Jaw'),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _buildLegendItem(ToothStatus.healthy),
        _buildLegendItem(ToothStatus.decay),
        _buildLegendItem(ToothStatus.filled),
        _buildLegendItem(ToothStatus.rct),
        _buildLegendItem(ToothStatus.crown),
        _buildLegendItem(ToothStatus.extracted),
        _buildLegendItem(ToothStatus.planned),
      ],
    );
  }

  Widget _buildLegendItem(ToothStatus status) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: _getColorFromHex(status.colorCode),
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          status.displayName,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  Widget _buildJawLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildQuadrant(int quadrant, {required bool isUpper, required bool isRight}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(8, (index) {
        final position = isRight ? index + 1 : 8 - index;
        final toothNumber = quadrant * 10 + position;
        return _buildTooth(toothNumber);
      }),
    );
  }

  Widget _buildTooth(int toothNumber) {
    final status = widget.toothStatuses[toothNumber] ?? ToothStatus.healthy;
    final isHovered = hoveredTooth == toothNumber;

    return MouseRegion(
      onEnter: (_) => setState(() => hoveredTooth = toothNumber),
      onExit: (_) => setState(() => hoveredTooth = null),
      child: GestureDetector(
        onTap: () => widget.onToothTap(toothNumber),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tooth representation
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isHovered ? 44 : 40,
                height: isHovered ? 54 : 50,
                decoration: BoxDecoration(
                  color: _getColorFromHex(status.colorCode),
                  border: Border.all(
                    color: isHovered ? Colors.blue.shade700 : Colors.grey.shade600,
                    width: isHovered ? 3 : 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isHovered
                      ? [
                          BoxShadow(
                            color: Colors.blue.shade200,
                            blurRadius: 8,
                            spreadRadius: 2,
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    toothNumber.toString(),
                    style: TextStyle(
                      color: _getContrastColor(status),
                      fontWeight: FontWeight.bold,
                      fontSize: isHovered ? 14 : 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // Tooth type label
              if (isHovered)
                Text(
                  ToothTreatment.getToothType(toothNumber),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }

  Color _getContrastColor(ToothStatus status) {
    // Return white text for dark backgrounds, black for light backgrounds
    if (status == ToothStatus.extracted ||
        status == ToothStatus.rct ||
        status == ToothStatus.filled ||
        status == ToothStatus.decay) {
      return Colors.white;
    }
    return Colors.black87;
  }
}
