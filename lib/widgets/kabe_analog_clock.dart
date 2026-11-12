import 'dart:math' as math;
import 'package:flutter/material.dart';

class KabeAnalogClock extends StatefulWidget {
  final DateTime currentTime;
  final double size;
  final double? qiblaAngle; // Qibla bearing
  final double compassHeading; // Current device heading
  final bool isQiblaMode;
  final bool enableTawaf; // Enable Tawaf animation around Kaaba

  const KabeAnalogClock({
    super.key,
    required this.currentTime,
    this.size = 320,
    this.qiblaAngle,
    this.compassHeading = 0.0,
    this.isQiblaMode = false,
    this.enableTawaf = true,
  });

  @override
  State<KabeAnalogClock> createState() => _KabeAnalogClockState();
}

class _KabeAnalogClockState extends State<KabeAnalogClock>
    with SingleTickerProviderStateMixin {
  late AnimationController _tawafController;

  @override
  void initState() {
    super.initState();
    _tawafController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void dispose() {
    _tawafController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.isQiblaMode
                  ? const Color(0xFFFFD700).withOpacity(0.4)
                  : const Color(0xFFD4AF37).withOpacity(0.28),
              blurRadius: 32,
              spreadRadius: 4,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.75),
              blurRadius: 22,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer golden-beveled frame
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    Color(0xFF2A2010),
                    Color(0xFFD4AF37),
                    Color(0xFF6B5310),
                    Color(0xFF14110B),
                  ],
                  stops: [0.93, 0.96, 0.98, 1.0],
                ),
                border: Border.all(
                  color: widget.isQiblaMode
                      ? const Color(0xFFFFD700)
                      : const Color(0xFFD4AF37),
                  width: 3.5,
                ),
              ),
            ),

            // Kaaba Background Image
            ClipOval(
              child: SizedBox(
                width: widget.size - 16,
                height: widget.size - 16,
                child: Image.asset(
                  'assets/images/kabe_saat.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFF0F141C),
                      child: const Center(
                        child: Icon(Icons.mosque, size: 80, color: Color(0xFFD4AF37)),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Vignette overlay
            ClipOval(
              child: Container(
                width: widget.size - 16,
                height: widget.size - 16,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.20),
                      Colors.black.withOpacity(0.55),
                    ],
                    stops: const [0.45, 0.85, 1.0],
                  ),
                ),
              ),
            ),

            // TAWAF MOVEMENT (Counter-clockwise orbit around Kaaba)
            if (widget.enableTawaf)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _tawafController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: TawafOrbitPainter(
                        animationProgress: _tawafController.value,
                      ),
                    );
                  },
                ),
              ),

            // QIBLA COMPASS: Perfectly straight, centered needle aiming to Kaaba
            if (widget.isQiblaMode && widget.qiblaAngle != null)
              Positioned.fill(
                child: CustomPaint(
                  painter: QiblaStraightPainter(
                    qiblaAngle: widget.qiblaAngle!,
                    deviceHeading: widget.compassHeading,
                  ),
                ),
              ),

            // Analog Clock Hands (Hour, Minute, Second)
            if (!widget.isQiblaMode)
              Positioned.fill(
                child: CustomPaint(
                  painter: ClockHandsPainter(currentTime: widget.currentTime),
                ),
              ),

            // Center Pin / Cap with Golden Jewel
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFFFFF7C2), Color(0xFFD4AF37), Color(0xFF5A4305)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.8),
                    blurRadius: 4,
                    offset: const Offset(1, 2),
                  ),
                ],
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tawaf movement painter (counter-clockwise circumambulation around Kaaba)
class TawafOrbitPainter extends CustomPainter {
  final double animationProgress;

  TawafOrbitPainter({required this.animationProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.58);
    final baseRadius = size.width * 0.22;

    final ringMultipliers = [0.85, 1.05, 1.25, 1.45];
    final particleCounts = [14, 20, 26, 32];
    final opacities = [0.75, 0.65, 0.50, 0.35];

    for (int r = 0; r < ringMultipliers.length; r++) {
      final ringRadiusX = baseRadius * ringMultipliers[r];
      final ringRadiusY = ringRadiusX * 0.58;
      final count = particleCounts[r];
      final ringOpacity = opacities[r];

      final orbitGuidePaint = Paint()
        ..color = const Color(0xFFFFD700).withOpacity(0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;
      canvas.drawOval(
        Rect.fromCenter(center: center, width: ringRadiusX * 2, height: ringRadiusY * 2),
        orbitGuidePaint,
      );

      final speedFactor = 1.0 - (r * 0.12);
      final baseAngle = -2 * math.pi * animationProgress * speedFactor;

      for (int i = 0; i < count; i++) {
        final particleAngle = baseAngle + (i * 2 * math.pi / count);
        final px = center.dx + ringRadiusX * math.cos(particleAngle);
        final py = center.dy + ringRadiusY * math.sin(particleAngle);

        final depth = (math.sin(particleAngle) + 1.0) / 2.0;
        final pRadius = 1.0 + (depth * 1.6);
        final pAlpha = ((0.3 + depth * 0.7) * ringOpacity).clamp(0.0, 1.0);

        final glowPaint = Paint()
          ..color = const Color(0xFFFFE57F).withOpacity(pAlpha * 0.45)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
        canvas.drawCircle(Offset(px, py), pRadius * 2.2, glowPaint);

        final corePaint = Paint()
          ..color = (i % 3 == 0)
              ? Colors.white.withOpacity(pAlpha)
              : const Color(0xFFFFD700).withOpacity(pAlpha);
        canvas.drawCircle(Offset(px, py), pRadius, corePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant TawafOrbitPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress;
  }
}

/// "ok saatin ortasındaki kabe resmine göre gelsin kıble, kıble düz çıkmıyor"
/// Mathematically straight, perfectly centered Qibla pointer.
/// When the device is oriented toward Mecca, the needle points 100% straight up (12 o'clock)
/// directly aligned with the central Kaaba!
class QiblaStraightPainter extends CustomPainter {
  final double qiblaAngle;
  final double deviceHeading;

  QiblaStraightPainter({
    required this.qiblaAngle,
    required this.deviceHeading,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    final kaabaCenter = Offset(size.width / 2, size.height * 0.58);

    // Difference between Qibla angle and phone heading
    // When phone is facing Qibla, diff = 0 -> points perfectly STRAIGHT UP (12 o'clock)
    final diff = ((qiblaAngle - deviceHeading) + 360) % 360;
    final isAligned = (diff < 3.5 || diff > 356.5);

    // Angle in radians (-pi/2 is straight UP)
    final angleRad = (diff - 90.0) * math.pi / 180.0;

    final themeColor = isAligned ? const Color(0xFF00FF88) : const Color(0xFFFFD700);

    // 1. Central Kaaba Aura / Target Halo
    final kaabaAuraPaint = Paint()
      ..color = themeColor.withOpacity(isAligned ? 0.45 : 0.20)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(kaabaCenter, size.width * 0.15, kaabaAuraPaint);

    final kaabaTargetBorder = Paint()
      ..color = themeColor.withOpacity(isAligned ? 0.9 : 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isAligned ? 2.5 : 1.2;
    canvas.drawCircle(kaabaCenter, size.width * 0.14, kaabaTargetBorder);

    // 2. Outer Dial Calibration Notch at 12 o'clock (Straight Up)
    final notchPaint = Paint()
      ..color = isAligned ? const Color(0xFF00FF88) : Colors.white60
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(center.dx, center.dy - radius - 2),
      Offset(center.dx, center.dy - radius + 12),
      notchPaint,
    );

    // 3. Straight Compass Needle anchored at CENTER (size.width/2, size.height/2)
    // Points along angleRad with exact mathematical symmetry
    final needleLength = radius * 0.85;
    final tip = Offset(
      center.dx + needleLength * math.cos(angleRad),
      center.dy + needleLength * math.sin(angleRad),
    );

    // Tail (opposite side)
    final tailLength = radius * 0.28;
    final tail = Offset(
      center.dx - tailLength * math.cos(angleRad),
      center.dy - tailLength * math.sin(angleRad),
    );

    // Normal vector perpendicular to needle direction
    final normalX = -math.sin(angleRad);
    final normalY = math.cos(angleRad);
    final halfWidth = size.width * 0.038;

    final leftCorner = Offset(
      center.dx + normalX * halfWidth,
      center.dy + normalY * halfWidth,
    );
    final rightCorner = Offset(
      center.dx - normalX * halfWidth,
      center.dy - normalY * halfWidth,
    );

    // Qibla Arrow Body
    final needlePath = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(leftCorner.dx, leftCorner.dy)
      ..lineTo(tail.dx, tail.dy)
      ..lineTo(rightCorner.dx, rightCorner.dy)
      ..close();

    // Shadow
    canvas.drawPath(needlePath.shift(const Offset(2, 3)), Paint()..color = Colors.black45);

    // Draw Left Half (lighter/reflective)
    final leftHalf = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(leftCorner.dx, leftCorner.dy)
      ..lineTo(center.dx, center.dy)
      ..close();
    canvas.drawPath(
      leftHalf,
      Paint()..color = isAligned ? const Color(0xFF55FFAA) : const Color(0xFFFFEE88),
    );

    // Draw Right Half (richer/darker for 3D metallic feel)
    final rightHalf = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(rightCorner.dx, rightCorner.dy)
      ..lineTo(center.dx, center.dy)
      ..close();
    canvas.drawPath(
      rightHalf,
      Paint()..color = isAligned ? const Color(0xFF00CC66) : const Color(0xFFD4AF37),
    );

    // Tail halves
    final tailLeft = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(leftCorner.dx, leftCorner.dy)
      ..lineTo(tail.dx, tail.dy)
      ..close();
    canvas.drawPath(tailLeft, Paint()..color = Colors.white70);

    final tailRight = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(rightCorner.dx, rightCorner.dy)
      ..lineTo(tail.dx, tail.dy)
      ..close();
    canvas.drawPath(tailRight, Paint()..color = Colors.white38);

    // 4. If Aligned: Luminous Green Laser Beam directly through Kaaba and 12 o'clock!
    if (isAligned) {
      final alignBeam = Paint()
        ..color = const Color(0xFF00FF88).withOpacity(0.7)
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(center.dx, center.dy - radius),
        Offset(center.dx, center.dy + radius * 0.7),
        alignBeam,
      );
    }
  }

  @override
  bool shouldRepaint(covariant QiblaStraightPainter oldDelegate) {
    return oldDelegate.qiblaAngle != qiblaAngle ||
        oldDelegate.deviceHeading != deviceHeading;
  }
}

class ClockHandsPainter extends CustomPainter {
  final DateTime currentTime;

  ClockHandsPainter({required this.currentTime});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final seconds = currentTime.second + (currentTime.millisecond / 1000.0);
    final minutes = currentTime.minute + (seconds / 60.0);
    final hours = (currentTime.hour % 12) + (minutes / 60.0);

    final hourAngle = (hours * 30.0 - 90.0) * math.pi / 180.0;
    final minAngle = (minutes * 6.0 - 90.0) * math.pi / 180.0;
    final secAngle = (seconds * 6.0 - 90.0) * math.pi / 180.0;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.55)
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final hourPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round;

    final minPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.8
      ..strokeCap = StrokeCap.round;

    final secPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final hourLength = radius * 0.48;
    final minLength = radius * 0.72;
    final secLength = radius * 0.82;

    final hourOffset = Offset(
      center.dx + hourLength * math.cos(hourAngle),
      center.dy + hourLength * math.sin(hourAngle),
    );
    canvas.drawLine(
      center + const Offset(2, 3),
      hourOffset + const Offset(2, 3),
      shadowPaint..strokeWidth = 6.0,
    );
    canvas.drawLine(center, hourOffset, hourPaint);

    final minOffset = Offset(
      center.dx + minLength * math.cos(minAngle),
      center.dy + minLength * math.sin(minAngle),
    );
    canvas.drawLine(
      center + const Offset(2, 3),
      minOffset + const Offset(2, 3),
      shadowPaint..strokeWidth = 4.5,
    );
    canvas.drawLine(center, minOffset, minPaint);

    final secOffset = Offset(
      center.dx + secLength * math.cos(secAngle),
      center.dy + secLength * math.sin(secAngle),
    );
    final secTail = Offset(
      center.dx - (radius * 0.18) * math.cos(secAngle),
      center.dy - (radius * 0.18) * math.sin(secAngle),
    );
    canvas.drawLine(secTail, secOffset, secPaint);
  }

  @override
  bool shouldRepaint(covariant ClockHandsPainter oldDelegate) {
    return oldDelegate.currentTime != currentTime;
  }
}
