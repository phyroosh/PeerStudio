import 'package:flutter/material.dart';

class SmoothLineChart extends StatelessWidget {
  final List<double> data;
  final Color color;
  final double height;
  final double width;

  const SmoothLineChart({
    super.key,
    required this.data,
    required this.color,
    this.height = 100,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return SizedBox(height: height, width: width);
    
    return SizedBox(
      height: height,
      width: width,
      child: CustomPaint(
        painter: _SmoothLinePainter(data: data, color: color),
      ),
    );
  }
}

class _SmoothLinePainter extends CustomPainter {
  final List<double> data;
  final Color color;

  _SmoothLinePainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final maxVal = data.reduce((curr, next) => curr > next ? curr : next);
    final minVal = data.reduce((curr, next) => curr < next ? curr : next);
    final range = maxVal - minVal == 0 ? 1.0 : maxVal - minVal;

    final path = Path();
    final xStep = size.width / (data.length - 1 > 0 ? data.length - 1 : 1);

    // Initial point
    path.moveTo(0, size.height - ((data[0] - minVal) / range) * size.height);

    for (var i = 1; i < data.length; i++) {
      final x = i * xStep;
      final y = size.height - ((data[i] - minVal) / range) * size.height;
      
      final prevX = (i - 1) * xStep;
      final prevY = size.height - ((data[i - 1] - minVal) / range) * size.height;
      
      final controlPointX = prevX + (x - prevX) / 2;
      
      path.cubicTo(
        controlPointX, prevY,
        controlPointX, y,
        x, y,
      );
    }

    // Draw gradient fill
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final gradientPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.5),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, gradientPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SmoothLinePainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.color != color;
  }
}
