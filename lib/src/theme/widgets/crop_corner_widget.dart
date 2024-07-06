import 'package:flutter/widgets.dart';

// MARK: - TopLeft Corner Indicator

class TopLeftCornerPainter extends CustomPainter {
  const TopLeftCornerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.fill;

    const weight = 2.0;

    // Vertical rectangle with angled end
    Path verticalPath = Path()
      ..moveTo(-weight, -weight)
      ..lineTo(-weight, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, -weight)
      ..close();

    // Horizontal rectangle with angled end
    Path horizontalPath = Path()
      ..moveTo(-weight, -weight)
      ..lineTo(size.width, -weight)
      ..lineTo(size.width, 0)
      ..lineTo(-weight, 0)
      ..close();

    canvas.drawPath(verticalPath, paint);
    canvas.drawPath(horizontalPath, paint);
  }

  @override
  bool shouldRepaint(TopLeftCornerPainter oldDelegate) => false;
}

class TopLeftCornerIndicator extends PreferredSize {
  const TopLeftCornerIndicator({
    super.key,
  }) : super(
    preferredSize: const Size(16, 16),
    child: const CustomPaint(
      size: Size(16, 16),
      painter: TopLeftCornerPainter(),
    ),
  );
}

// MARK: - TopRight Corner Indicator

class TopRightCornerPainter extends CustomPainter {
  const TopRightCornerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.fill;

    const weight = 2.0;

    // Vertical rectangle with angled end
    Path verticalPath = Path()
      ..moveTo(size.width + weight, -weight)
      ..lineTo(size.width + weight, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, -weight)
      ..close();

    // Horizontal rectangle with angled end
    Path horizontalPath = Path()
      ..moveTo(0, -weight)
      ..lineTo(size.width + weight, -weight)
      ..lineTo(size.width + weight, 0)
      ..lineTo(0, 0)
      ..close();

    canvas.drawPath(verticalPath, paint);
    canvas.drawPath(horizontalPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TopRightCornerIndicator extends PreferredSize {
  const TopRightCornerIndicator({
    super.key,
  }) : super(
    preferredSize: const Size(16, 16),
    child: const CustomPaint(
      size: Size(16, 16),
      painter: TopRightCornerPainter(),
    ),
  );
}

// MARK: - BottomLeft Corner Indicator

class BottomLeftCornerPainter extends CustomPainter {
  const BottomLeftCornerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.fill;

    const weight = 2.0;

    // Vertical rectangle with angled end
    Path verticalPath = Path()
      ..moveTo(-weight, 0)
      ..lineTo(-weight, size.height + weight)
      ..lineTo(0, size.height + weight)
      ..lineTo(0, 0)
      ..close();

    // Horizontal rectangle with angled end
    Path horizontalPath = Path()
      ..moveTo(-weight, size.height + weight)
      ..lineTo(size.width, size.height + weight)
      ..lineTo(size.width, size.height)
      ..lineTo(-weight, size.height)
      ..close();

    canvas.drawPath(verticalPath, paint);
    canvas.drawPath(horizontalPath, paint);
  }

  @override
  bool shouldRepaint(BottomLeftCornerPainter oldDelegate) => false;
}

class BottomLeftCornerIndicator extends PreferredSize {
  const BottomLeftCornerIndicator({
    super.key,
  }) : super(
    preferredSize: const Size(16, 16),
    child: const CustomPaint(
      size: Size(16, 16),
      painter: BottomLeftCornerPainter(),
    ),
  );
}

// MARK: - BottomRight Corner Indicator

class BottomRightCornerPainter extends CustomPainter {
  const BottomRightCornerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.fill;

    const weight = 2.0;

    // Vertical rectangle with angled end
    Path verticalPath = Path()
      ..moveTo(size.width + weight, 0)
      ..lineTo(size.width + weight, size.height + weight)
      ..lineTo(size.width, size.height + weight)
      ..lineTo(size.width, 0)
      ..close();

    // Horizontal rectangle with angled end
    Path horizontalPath = Path()
      ..moveTo(0, size.height + weight)
      ..lineTo(size.width + weight, size.height + weight)
      ..lineTo(size.width + weight, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(verticalPath, paint);
    canvas.drawPath(horizontalPath, paint);
  }

  @override
  bool shouldRepaint(BottomRightCornerPainter oldDelegate) => false;
}

class BottomRightCornerIndicator extends PreferredSize {
  const BottomRightCornerIndicator({
    super.key
  }) : super(
    preferredSize: const Size(16, 16),
    child: const CustomPaint(
      size: Size(16, 16),
      painter: BottomRightCornerPainter(),
    ),
  );
}
