import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/bouncy_button.dart';
import '../widgets/smooth_line_chart.dart';

class AiStrategyCenterPage extends StatelessWidget {
  const AiStrategyCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Strategy Center', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Channel Growth Projection', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  const Text('AI predicted subscriber growth over the next 30 days based on recent performance.', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 24),
                  SmoothLineChart(
                    data: const [100, 120, 110, 150, 200, 250, 220, 300],
                    color: AppTheme.electricCyan,
                    height: 150,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: BouncyButton(
                    onPressed: () {},
                    child: GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(Icons.lightbulb_outline, size: 40, color: AppTheme.neonAmethyst),
                          const SizedBox(height: 16),
                          const Text('Content Ideas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: BouncyButton(
                    onPressed: () {},
                    child: GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(Icons.trending_up, size: 40, color: AppTheme.electricCyan),
                          const SizedBox(height: 16),
                          const Text('Trend Analysis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
