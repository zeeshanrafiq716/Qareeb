import 'package:flutter/material.dart';

/// Person Outline Icon (width: 16, height: 16, border: 1px solid #566663)
class PersonOutlineIconWidget extends StatelessWidget {
  final Color color;
  const PersonOutlineIconWidget({
    super.key,
    this.color = const Color(0xFF566663),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(16.0, 16.0),
      painter: _PersonOutlinePainter(color: color),
    );
  }
}

class _PersonOutlinePainter extends CustomPainter {
  final Color color;
  const _PersonOutlinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double cx = size.width / 2.0;

    // Head circle outline (radius 3.0 at cx, 4.2)
    canvas.drawCircle(Offset(cx, 4.2), 3.0, paint);

    // Torso curved outline
    final bodyPath = Path()
      ..moveTo(1.5, size.height - 1.2)
      ..cubicTo(1.5, 9.8, cx - 3.2, 8.8, cx, 8.8)
      ..cubicTo(cx + 3.2, 8.8, size.width - 1.5, 9.8, size.width - 1.5, size.height - 1.2)
      ..lineTo(1.5, size.height - 1.2);

    canvas.drawPath(bodyPath, paint);
  }

  @override
  bool shouldRepaint(covariant _PersonOutlinePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// ID Card Outline Icon (width: 16, height: 16, border: 1px solid #566663)
class IdCardOutlineIconWidget extends StatelessWidget {
  final Color color;
  const IdCardOutlineIconWidget({
    super.key,
    this.color = const Color(0xFF566663),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(16.0, 16.0),
      painter: _IdCardOutlinePainter(color: color),
    );
  }
}

class _IdCardOutlinePainter extends CustomPainter {
  final Color color;
  const _IdCardOutlinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Card outer border
    final cardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.8, 2.2, size.width - 1.6, size.height - 4.4),
      const Radius.circular(2.5),
    );
    canvas.drawRRect(cardRect, paint);

    // Left photo / avatar circle
    canvas.drawCircle(Offset(4.5, size.height / 2.0), 1.6, paint);

    // Right horizontal lines
    canvas.drawLine(
      Offset(8.5, size.height / 2.0 - 2.0),
      Offset(size.width - 3.2, size.height / 2.0 - 2.0),
      paint,
    );
    canvas.drawLine(
      Offset(8.5, size.height / 2.0 + 2.0),
      Offset(size.width - 3.2, size.height / 2.0 + 2.0),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _IdCardOutlinePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Calendar Outline Icon (width: 16, height: 16, border: 1px solid #566663)
class CalendarOutlineIconWidget extends StatelessWidget {
  final Color color;
  const CalendarOutlineIconWidget({
    super.key,
    this.color = const Color(0xFF566663),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(16.0, 16.0),
      painter: _CalendarOutlinePainter(color: color),
    );
  }
}

class _CalendarOutlinePainter extends CustomPainter {
  final Color color;
  const _CalendarOutlinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Calendar outer body
    final calRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(1.2, 3.2, size.width - 2.4, size.height - 4.4),
      const Radius.circular(2.5),
    );
    canvas.drawRRect(calRect, paint);

    // Top horizontal separator line
    canvas.drawLine(
      Offset(1.2, 7.2),
      Offset(size.width - 1.2, 7.2),
      paint,
    );

    // Two top hooks / rings
    canvas.drawLine(const Offset(4.8, 1.2), const Offset(4.8, 3.2), paint);
    canvas.drawLine(Offset(size.width - 4.8, 1.2), Offset(size.width - 4.8, 3.2), paint);
  }

  @override
  bool shouldRepaint(covariant _CalendarOutlinePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Phone Receiver Outline Icon (width: 16, height: 16, border: 1px solid #566663)
class PhoneOutlineIconWidget extends StatelessWidget {
  final Color color;
  const PhoneOutlineIconWidget({
    super.key,
    this.color = const Color(0xFF566663),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(16.0, 16.0),
      painter: _PhoneOutlinePainter(color: color),
    );
  }
}

class _PhoneOutlinePainter extends CustomPainter {
  final Color color;
  const _PhoneOutlinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / 24.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.save();
    canvas.scale(scale, scale);

    // Standard phone handset outline path
    final path = Path()
      ..moveTo(22.0, 16.92)
      ..lineTo(22.0, 20.0)
      ..cubicTo(22.0, 21.1, 21.09, 22.0, 19.99, 22.0)
      ..cubicTo(10.05, 22.0, 2.0, 13.95, 2.0, 4.01)
      ..cubicTo(2.0, 2.91, 2.9, 2.0, 4.0, 2.0)
      ..lineTo(7.08, 2.0)
      ..cubicTo(7.7, 2.0, 8.23, 2.42, 8.37, 3.02)
      ..lineTo(9.12, 6.22)
      ..cubicTo(9.26, 6.81, 9.07, 7.42, 8.64, 7.82)
      ..lineTo(6.94, 9.52)
      ..cubicTo(8.53, 12.64, 11.08, 15.19, 14.2, 16.78)
      ..lineTo(15.9, 15.08)
      ..cubicTo(16.3, 14.65, 16.91, 14.46, 17.5, 14.6)
      ..lineTo(20.7, 15.35)
      ..cubicTo(21.3, 15.49, 21.72, 16.02, 22.0, 16.92)
      ..close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PhoneOutlinePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// WhatsApp Outline Icon (width: 16, height: 16, border: 1px solid #566663)
class WhatsAppOutlineIconWidget extends StatelessWidget {
  final Color color;
  const WhatsAppOutlineIconWidget({
    super.key,
    this.color = const Color(0xFF566663),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(16.0, 16.0),
      painter: _WhatsAppOutlinePainter(color: color),
    );
  }
}

class _WhatsAppOutlinePainter extends CustomPainter {
  final Color color;
  const _WhatsAppOutlinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / 24.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final handsetStroke = Paint()
      ..color = color
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.save();
    canvas.scale(scale, scale);

    // 1. Speech bubble outline
    final bubblePath = Path()
      ..moveTo(12.0, 2.5)
      ..cubicTo(6.75, 2.5, 2.5, 6.75, 2.5, 12.0)
      ..cubicTo(2.5, 13.75, 2.95, 15.4, 3.75, 16.85)
      ..lineTo(2.5, 21.5)
      ..lineTo(7.35, 20.25)
      ..cubicTo(8.75, 21.05, 10.35, 21.5, 12.0, 21.5)
      ..cubicTo(17.25, 21.5, 21.5, 17.25, 21.5, 12.0)
      ..cubicTo(21.5, 6.75, 17.25, 2.5, 12.0, 2.5)
      ..close();

    canvas.drawPath(bubblePath, paint);

    // 2. Handset phone outline inside
    final handsetPath = Path()
      ..moveTo(8.5, 7.5)
      ..cubicTo(8.3, 7.5, 8.0, 7.6, 7.8, 7.8)
      ..cubicTo(7.6, 8.1, 7.0, 8.7, 7.0, 9.9)
      ..cubicTo(7.0, 11.1, 7.9, 12.3, 8.0, 12.5)
      ..cubicTo(8.2, 12.6, 9.8, 15.1, 12.2, 16.1)
      ..cubicTo(14.2, 17.0, 14.6, 16.8, 15.1, 16.8)
      ..cubicTo(15.5, 16.7, 16.5, 16.2, 16.7, 15.6)
      ..cubicTo(16.9, 15.0, 16.9, 14.5, 16.8, 14.4)
      ..cubicTo(16.8, 14.3, 16.6, 14.2, 16.4, 14.1)
      ..cubicTo(16.1, 14.0, 14.9, 13.4, 14.7, 13.3)
      ..cubicTo(14.5, 13.2, 14.3, 13.2, 14.1, 13.4)
      ..cubicTo(13.9, 13.7, 13.5, 14.2, 13.3, 14.4)
      ..cubicTo(13.2, 14.6, 13.0, 14.6, 12.8, 14.5)
      ..cubicTo(12.5, 14.3, 11.7, 14.1, 10.8, 13.2)
      ..cubicTo(10.0, 12.5, 9.5, 11.7, 9.4, 11.5)
      ..cubicTo(9.3, 11.2, 9.4, 11.1, 9.5, 11.0)
      ..cubicTo(9.6, 10.9, 9.8, 10.7, 9.9, 10.5)
      ..cubicTo(10.0, 10.4, 10.1, 10.3, 10.2, 10.1)
      ..cubicTo(10.2, 10.0, 10.2, 9.8, 10.1, 9.7)
      ..cubicTo(10.1, 9.6, 9.6, 8.4, 9.4, 7.9)
      ..cubicTo(9.2, 7.4, 9.0, 7.5, 8.8, 7.5)
      ..close();

    canvas.drawPath(handsetPath, handsetStroke);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WhatsAppOutlinePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Truck / Towing Vehicle Outline Icon (width: 16, height: 16, border: 1px solid #566663)
class TruckOutlineIconWidget extends StatelessWidget {
  final Color color;
  const TruckOutlineIconWidget({
    super.key,
    this.color = const Color(0xFF566663),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(16.0, 16.0),
      painter: _TruckOutlinePainter(color: color),
    );
  }
}

class _TruckOutlinePainter extends CustomPainter {
  final Color color;
  const _TruckOutlinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.15
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15;

    // Truck body outline
    final body = Path()
      ..moveTo(1.2, 4.0)
      ..lineTo(9.0, 4.0)
      ..lineTo(11.2, 4.0)
      ..lineTo(13.5, 7.2)
      ..lineTo(14.8, 7.2)
      ..cubicTo(15.2, 7.2, 15.2, 7.6, 15.2, 8.0)
      ..lineTo(15.2, 11.2)
      ..lineTo(13.2, 11.2)
      // Front wheel cutout
      ..arcToPoint(
        const Offset(10.0, 11.2),
        radius: const Radius.circular(1.6),
        clockwise: false,
      )
      ..lineTo(5.0, 11.2)
      // Rear wheel cutout
      ..arcToPoint(
        const Offset(1.8, 11.2),
        radius: const Radius.circular(1.6),
        clockwise: false,
      )
      ..lineTo(1.2, 11.2)
      ..close();

    canvas.drawPath(body, paint);

    // Cab separator line
    canvas.drawLine(const Offset(9.0, 4.0), const Offset(9.0, 11.2), paint);

    // Windshield window
    final window = Path()
      ..moveTo(9.8, 5.2)
      ..lineTo(11.0, 5.2)
      ..lineTo(12.3, 7.2)
      ..lineTo(9.8, 7.2)
      ..close();
    canvas.drawPath(window, paint);

    // Rear wheel
    canvas.drawCircle(const Offset(3.4, 11.8), 1.2, fillPaint);
    // Front wheel
    canvas.drawCircle(const Offset(11.6, 11.8), 1.2, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _TruckOutlinePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// License Plate Outline Icon (width: 16, height: 16, border: 1px solid #566663)
class LicensePlateOutlineIconWidget extends StatelessWidget {
  final Color color;
  const LicensePlateOutlineIconWidget({
    super.key,
    this.color = const Color(0xFF566663),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(16.0, 16.0),
      painter: _LicensePlateOutlinePainter(color: color),
    );
  }
}

class _LicensePlateOutlinePainter extends CustomPainter {
  final Color color;
  const _LicensePlateOutlinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.15
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Outer plate rounded rectangle
    final plateRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(1.2, 3.5, size.width - 2.4, 9.0),
      const Radius.circular(2.0),
    );
    canvas.drawRRect(plateRect, paint);

    // Inner dashes [- -]
    canvas.drawLine(
      const Offset(3.8, 8.0),
      const Offset(6.6, 8.0),
      paint,
    );
    canvas.drawLine(
      const Offset(9.4, 8.0),
      const Offset(12.2, 8.0),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _LicensePlateOutlinePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Artist Palette / Vehicle Color Outline Icon (width: 16, height: 16, border: 1px solid #566663)
class PaletteOutlineIconWidget extends StatelessWidget {
  final Color color;
  const PaletteOutlineIconWidget({
    super.key,
    this.color = const Color(0xFF566663),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(16.0, 16.0),
      painter: _PaletteOutlinePainter(color: color),
    );
  }
}

class _PaletteOutlinePainter extends CustomPainter {
  final Color color;
  const _PaletteOutlinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.15
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Organic palette bean shape
    final path = Path()
      ..moveTo(8.0, 1.8)
      ..cubicTo(4.0, 1.8, 1.2, 4.5, 1.2, 8.0)
      ..cubicTo(1.2, 11.5, 3.5, 14.2, 7.0, 14.2)
      ..cubicTo(9.0, 14.2, 10.2, 13.5, 11.0, 12.5)
      ..cubicTo(11.8, 11.5, 12.8, 11.5, 13.5, 12.0)
      ..cubicTo(14.5, 12.6, 14.8, 11.0, 14.8, 9.5)
      ..cubicTo(14.8, 5.0, 12.0, 1.8, 8.0, 1.8)
      ..close();

    canvas.drawPath(path, paint);

    // Thumb hole
    canvas.drawCircle(const Offset(11.2, 9.8), 1.1, paint);

    // 4 Color spots
    canvas.drawCircle(const Offset(4.2, 5.6), 0.7, paint);
    canvas.drawCircle(const Offset(7.2, 4.2), 0.7, paint);
    canvas.drawCircle(const Offset(10.2, 4.6), 0.7, paint);
    canvas.drawCircle(const Offset(4.6, 9.0), 0.7, paint);
  }

  @override
  bool shouldRepaint(covariant _PaletteOutlinePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Dropdown Chevron Downward Icon (width: 14, height: 8 / 16x16)
class DropdownChevronWidget extends StatelessWidget {
  final Color color;
  const DropdownChevronWidget({
    super.key,
    this.color = const Color(0xFF566663),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(14.0, 8.0),
      painter: _DropdownChevronPainter(color: color),
    );
  }
}

class _DropdownChevronPainter extends CustomPainter {
  final Color color;
  const _DropdownChevronPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(1.0, 1.5)
      ..lineTo(size.width / 2.0, size.height - 1.5)
      ..lineTo(size.width - 1.0, 1.5);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _DropdownChevronPainter oldDelegate) =>
      oldDelegate.color != color;
}
