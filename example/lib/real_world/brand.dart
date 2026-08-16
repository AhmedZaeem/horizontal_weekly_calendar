import 'package:flutter/material.dart';

/// The package mark: a week track cut out of a solid surface, with one day
/// rising out of it.
///
/// The mark is built from a single square and two subtractions rather than an
/// arrangement of floating parts, so it keeps a solid silhouette, survives
/// being scaled down to a favicon, and works on any background — the cut-outs
/// simply show whatever is behind it.
class CalendarBrandMark extends StatelessWidget {
  const CalendarBrandMark({
    super.key,
    this.size = 56,
    this.accent = const Color(0xFF7C6BFF),
    this.highlight = const Color(0xFF4FD1E0),
    this.foreground = Colors.white,
  });

  /// Edge length of the square the mark is drawn into.
  final double size;

  /// Trailing colour of the surface gradient.
  final Color accent;

  /// Leading colour of the surface gradient.
  final Color highlight;

  /// Colour of the raised day.
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _MarkPainter(
          accent: accent,
          highlight: highlight,
          foreground: foreground,
        ),
      ),
    );
  }
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter({
    required this.accent,
    required this.highlight,
    required this.foreground,
  });

  final Color accent;
  final Color highlight;
  final Color foreground;

  @override
  void paint(Canvas canvas, Size size) {
    // Expressed against a 100-unit square and scaled, so the proportions and
    // optical spacing hold at every rendered size.
    final u = size.width / 100;
    double x(double v) => v * u;
    final bounds = Offset.zero & size;

    // The subtractions have to composite against the mark itself rather than
    // the canvas, so the whole glyph is painted into its own layer.
    canvas.saveLayer(bounds, Paint());

    final surface = RRect.fromLTRBR(
      x(2),
      x(2),
      x(98),
      x(98),
      Radius.circular(x(26)),
    );
    canvas.drawRRect(
      surface,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [highlight, accent],
        ).createShader(surface.outerRect),
    );

    final clear = Paint()..blendMode = BlendMode.clear;
    final surfacePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [highlight, accent],
      ).createShader(surface.outerRect);

    // The week track, cut straight through the surface.
    canvas.drawRRect(
      RRect.fromLTRBR(x(13), x(45), x(87), x(61), Radius.circular(x(8))),
      clear,
    );

    // Day divisions put back into the track, so it reads as a row of dates
    // rather than as one continuous bar.
    for (final divider in [25.4, 37.7, 62.3, 74.6]) {
      canvas.drawRect(
        Rect.fromLTRB(x(divider - 1.6), x(45), x(divider + 1.6), x(61)),
        surfacePaint,
      );
    }

    // The event dot the calendar puts beneath a day that has something on it,
    // also cut rather than drawn, so the mark keeps exactly two colours.
    canvas.drawCircle(Offset(x(50), x(72)), x(4.2), clear);

    // The selected day, rising out of the track and breaking its top edge.
    canvas.drawRRect(
      RRect.fromLTRBR(x(41), x(31), x(59), x(61), Radius.circular(x(6))),
      Paint()..color = foreground,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MarkPainter oldDelegate) =>
      oldDelegate.accent != accent ||
      oldDelegate.highlight != highlight ||
      oldDelegate.foreground != foreground;
}
