import 'package:flutter/material.dart';
import '../models/ai_models.dart';
import '../theme/app_theme.dart';
import 'bouncy_button.dart';

class ModelAccordionItem extends StatelessWidget {
  final AIModel model;
  final bool isSelected;
  final VoidCallback onSelect;

  const ModelAccordionItem({
    super.key,
    required this.model,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return BouncyButton(
      onPressed: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.electricCyan.withValues(alpha: 0.1) : AppTheme.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.electricCyan : AppTheme.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? AppTheme.electricCyan : Colors.white30,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    model.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppTheme.electricCyan : Colors.white,
                    ),
                  ),
                ),
                if (model.isBestInClass)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.neonAmethyst.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Best in Class', style: TextStyle(color: AppTheme.neonAmethyst, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(height: 16),
              const Divider(color: AppTheme.border),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStat('Context Window', '128k', Icons.memory),
                  _buildStat('Speed', 'Fast', Icons.speed),
                  _buildStat('Cost', '\$0.01/1K', Icons.attach_money),
                ],
              ),
              const SizedBox(height: 16),
              // Simulated latency bar chart
              const Text('Avg Latency (ms)', style: TextStyle(fontSize: 12, color: Colors.white54)),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildLatencyBar(120, 40),
                  _buildLatencyBar(150, 60),
                  _buildLatencyBar(90, 80),
                  _buildLatencyBar(110, 100),
                  _buildLatencyBar(85, 120),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.white54),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white54)),
      ],
    );
  }

  Widget _buildLatencyBar(double latency, double height) {
    return Container(
      width: 16,
      height: height,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: AppTheme.electricCyan.withValues(alpha: 0.5),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      ),
    );
  }
}
