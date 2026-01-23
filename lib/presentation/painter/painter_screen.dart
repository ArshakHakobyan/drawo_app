import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:drawo_app/presentation/painter/bloc/painter_bloc.dart';
import 'package:drawo_app/core/service_locator.dart' as service_locator;

class PainterScreen extends StatefulWidget {
  const PainterScreen({super.key});

  @override
  State<PainterScreen> createState() => _PainterScreenState();
}

class _PainterScreenState extends State<PainterScreen> {
  final GlobalKey _canvasKey = GlobalKey();

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frameInfo = await codec.getNextFrame();
      if (mounted) {
        context.read<PainterBloc>().add(SetBackgroundImage(frameInfo.image));
      }
    }
  }

  Future<void> _saveCanvas(BuildContext context) async {
    try {
      final boundary =
          _canvasKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null && mounted) {
        final bytes = byteData.buffer.asUint8List();
        context.read<PainterBloc>().add(SaveImageRequested(bytes));
      }
    } catch (e) {
      debugPrint('Error saving canvas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => service_locator.sl<PainterBloc>(),
      child: BlocConsumer<PainterBloc, PainterState>(
        listener: (context, state) {
          if (state.status == PainterStatus.saved) {
            Navigator.pop(context);
          } else if (state.status == PainterStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Save failed')),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('New Drawing'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.photo_library),
                  onPressed: () => _pickImage(context),
                ),
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: state.status == PainterStatus.saving
                      ? null
                      : () => _saveCanvas(context),
                ),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: RepaintBoundary(
                    key: _canvasKey,
                    child: DrawingCanvas(),
                  ),
                ),
                _buildToolbar(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, PainterState state) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(
              Icons.edit,
              color: !state.isEraser ? state.selectedColor : Colors.grey,
            ),
            onPressed: () =>
                context.read<PainterBloc>().add(const ToggleEraser(false)),
          ),
          IconButton(
            icon: Icon(
              Icons.cleaning_services,
              color: state.isEraser ? Colors.blue : Colors.grey,
            ),
            onPressed: () =>
                context.read<PainterBloc>().add(const ToggleEraser(true)),
          ),
          IconButton(
            icon: const Icon(Icons.palette),
            onPressed: () => _showColorPicker(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => context.read<PainterBloc>().add(ClearCanvas()),
          ),
        ],
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    final colors = [
      Colors.black,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
    ];
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 16,
          children: colors
              .map(
                (c) => GestureDetector(
                  onTap: () {
                    context.read<PainterBloc>().add(ChangeColor(c));
                    Navigator.pop(context);
                  },
                  child: CircleAvatar(backgroundColor: c),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class DrawingCanvas extends StatelessWidget {
  const DrawingCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PainterBloc, PainterState>(
      builder: (context, state) {
        return GestureDetector(
          onPanStart: (details) => context.read<PainterBloc>().add(
            StartDrawing(details.localPosition),
          ),
          onPanUpdate: (details) => context.read<PainterBloc>().add(
            UpdateDrawing(details.localPosition),
          ),
          onPanEnd: (_) => context.read<PainterBloc>().add(EndDrawing()),
          child: CustomPaint(
            painter: DrawingPainter(
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

class DrawingPainter extends CustomPainter {
  final List<DrawnLine> lines;
  final DrawnLine? currentLine;
  final ui.Image? backgroundImage;

  DrawingPainter({required this.lines, this.currentLine, this.backgroundImage});

  @override
  void paint(Canvas canvas, Size size) {
    if (backgroundImage != null) {
      _drawBackgroundImage(canvas, size);
    }

    final layerBounds = Offset.zero & size;
    canvas.saveLayer(layerBounds, Paint());

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final line in lines) {
      _drawStroke(canvas, line, paint);
    }

    if (currentLine != null) {
      _drawStroke(canvas, currentLine!, paint);
    }

    canvas.restore();
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

  void _drawStroke(Canvas canvas, DrawnLine line, Paint paint) {
    paint.color = line.isEraser ? Colors.transparent : line.color;
    paint.strokeWidth = line.strokeWidth;
    paint.blendMode = line.isEraser ? BlendMode.clear : BlendMode.srcOver;

    if (line.path.length < 2) return;

    final path = Path();
    path.moveTo(line.path.first.dx, line.path.first.dy);
    for (int i = 1; i < line.path.length; i++) {
      path.lineTo(line.path[i].dx, line.path[i].dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) => true;
}
