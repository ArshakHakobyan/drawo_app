import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drawo_app/presentation/drawing/bloc/drawing_bloc.dart';

class DrawingCanvas extends StatelessWidget {
  const DrawingCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DrawingBloc, DrawingState>(
      buildWhen: (previous, current) =>
          previous.lines != current.lines ||
          previous.currentLine != current.currentLine ||
          previous.backgroundImage != current.backgroundImage,
      builder: (context, state) {
        return GestureDetector(
          onPanStart: (details) => context.read<DrawingBloc>().add(
            StartDrawing(details.localPosition),
          ),
          onPanUpdate: (details) => context.read<DrawingBloc>().add(
            UpdateDrawing(details.localPosition),
          ),
          onPanEnd: (_) => context.read<DrawingBloc>().add(EndDrawing()),
          child: CustomPaint(
            painter: CanvasDrawing(
              lines: state.lines,
              currentLine: state.currentLine,
              backgroundImage: state.backgroundImage,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }
}

class CanvasDrawing extends CustomPainter {
  final List<DrawnLine> lines;
  final DrawnLine? currentLine;
  final ui.Image? backgroundImage;

  CanvasDrawing({required this.lines, this.currentLine, this.backgroundImage});

  @override
  void paint(Canvas canvas, Size size) {
    // Fill with white background so saved image is not transparent
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white,
    );

    if (backgroundImage != null) {
      _drawBackgroundImage(canvas, size);
    }

    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Use a layer for eraser support (BlendMode.clear)
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    for (final line in lines) {
      _drawLine(canvas, line, paint);
    }

    if (currentLine != null) {
      _drawLine(canvas, currentLine!, paint);
    }

    canvas.restore();
  }

  void _drawLine(Canvas canvas, DrawnLine line, Paint paint) {
    paint.strokeWidth = line.strokeWidth;
    if (line.isEraser) {
      paint.blendMode = BlendMode.clear;
      paint.color = Colors.black; // Color doesn't matter with BlendMode.clear
    } else {
      paint.blendMode = BlendMode.srcOver;
      paint.color = line.color;
    }

    if (line.path.isEmpty) return;
    if (line.path.length == 1) {
      canvas.drawCircle(
        line.path.first,
        line.strokeWidth / 2,
        paint..style = PaintingStyle.fill,
      );
      paint.style = PaintingStyle.stroke;
      return;
    }

    final path = Path();
    path.moveTo(line.path.first.dx, line.path.first.dy);
    for (int i = 1; i < line.path.length; i++) {
      path.lineTo(line.path[i].dx, line.path[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  void _drawBackgroundImage(Canvas canvas, Size size) {
    final double scale = _getScale(
      size,
      Size(
        backgroundImage!.width.toDouble(),
        backgroundImage!.height.toDouble(),
      ),
    );
    final double w = backgroundImage!.width * scale;
    final double h = backgroundImage!.height * scale;
    final double dx = (size.width - w) / 2;
    final double dy = (size.height - h) / 2;

    canvas.drawImageRect(
      backgroundImage!,
      Rect.fromLTWH(
        0,
        0,
        backgroundImage!.width.toDouble(),
        backgroundImage!.height.toDouble(),
      ),
      Rect.fromLTWH(dx, dy, w, h),
      Paint(),
    );
  }

  double _getScale(Size container, Size img) {
    final double sx = container.width / img.width;
    final double sy = container.height / img.height;
    return sx < sy ? sx : sy;
  }

  @override
  bool shouldRepaint(covariant CanvasDrawing oldDelegate) {
    return oldDelegate.lines != lines ||
        oldDelegate.currentLine != currentLine ||
        oldDelegate.backgroundImage != backgroundImage;
  }
}
