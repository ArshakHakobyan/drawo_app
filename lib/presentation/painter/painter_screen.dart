import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:drawo_app/core/resources/media_assets.dart';
import 'package:drawo_app/core/style/palette.dart';
import 'package:drawo_app/core/service_locator.dart' as service_locator;
import 'package:drawo_app/data/models/drawing_model.dart';
import 'package:drawo_app/presentation/painter/bloc/painter_bloc.dart';
import 'package:drawo_app/presentation/gallery/widgets/frosted_glass_container.dart';
import 'package:drawo_app/presentation/gallery/widgets/main_background.dart';
import 'package:drawo_app/core/languages/app_localizations.dart';

class PainterScreen extends StatelessWidget {
  final DrawingModel? drawing;
  const PainterScreen({super.key, this.drawing});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => service_locator.sl<PainterBloc>(),
      child: _PainterView(drawing: drawing),
    );
  }
}

class _PainterView extends StatefulWidget {
  final DrawingModel? drawing;
  const _PainterView({this.drawing});

  @override
  State<_PainterView> createState() => _PainterViewState();
}

class _PainterViewState extends State<_PainterView> {
  final GlobalKey _canvasKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.drawing != null) {
        _loadImageFromUrl(widget.drawing!.url);
      }
    });
  }

  Future<void> _loadImageFromUrl(String url) async {
    try {
      final ImageProvider provider = NetworkImage(url);
      final ImageStream stream = provider.resolve(ImageConfiguration.empty);
      stream.addListener(
        ImageStreamListener((ImageInfo info, bool _) {
          if (mounted) {
            context.read<PainterBloc>().add(SetBackgroundImage(info.image));
          }
        }),
      );
    } catch (e) {
      debugPrint('Error loading background image: $e');
    }
  }

  Future<void> _pickImage() async {
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

  Future<void> _saveCanvas() async {
    try {
      final boundary =
          _canvasKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null && mounted) {
        final bytes = byteData.buffer.asUint8List();
        context.read<PainterBloc>().add(
          SaveImageRequested(
            imageBytes: bytes,
            existingDocId: widget.drawing?.id,
            oldStoragePath: widget.drawing?.storagePath,
            width: image.width,
            height: image.height,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving canvas: $e');
    }
  }

  Future<void> _shareCanvas() async {
    try {
      final boundary =
          _canvasKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final bytes = byteData.buffer.asUint8List();
        await Share.shareXFiles([
          XFile.fromData(bytes, name: 'drawing.png', mimeType: 'image/png'),
        ], text: 'Check out my drawing!');
      }
    } catch (e) {
      debugPrint('Error sharing canvas: $e');
    }
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          backgroundColor: Palette.darkGrey,
          titleTextStyle: const TextStyle(color: Palette.white, fontSize: 18),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: this.context.read<PainterBloc>().state.selectedColor,
              onColorChanged: (color) {
                this.context.read<PainterBloc>().add(ChangeColor(color));
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Done',
                style: TextStyle(color: Palette.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PainterBloc, PainterState>(
      listener: (context, state) {
        if (state.status == PainterStatus.saved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Drawing saved successfully!')),
          );
          Navigator.pop(context);
        } else if (state.status == PainterStatus.deleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Drawing deleted successfully!')),
          );
          Navigator.pop(context);
        } else if (state.status == PainterStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Error saving drawing'),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            children: [
              MainBackground(),
              Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: RepaintBoundary(
                                key: _canvasKey,
                                child: Container(
                                  color: Colors.white,
                                  child: const _DrawingCanvas(),
                                ),
                              ),
                            ),
                          ),
                        ),
                        _buildToolbar(context, state),
                        if (state.status == PainterStatus.saving)
                          Container(
                            color: Colors.black26,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Palette.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      height: 102,
      child: FrostedGlassContainer(
        height: 102,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Image.asset(MediaAssets.backIcon, height: 24),
                ),
                Text(
                  widget.drawing != null ? l10n.edit : l10n.newImage,
                  style: const TextStyle(
                    color: Palette.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    if (widget.drawing != null) ...[
                      GestureDetector(
                        onTap: () {
                          context.read<PainterBloc>().add(
                            DeleteImageRequested(
                              widget.drawing!.id,
                              widget.drawing!.storagePath,
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.delete_outline,
                          color: Palette.red,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    GestureDetector(
                      onTap: _shareCanvas,
                      child: const Icon(
                        Icons.share,
                        color: Palette.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: _saveCanvas,
                      child: Image.asset(MediaAssets.doneIcon, height: 24),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, PainterState state) {
    return Positioned(
      bottom: 40,
      left: 20,
      right: 20,
      child: SizedBox(
        height: 80,
        child: FrostedGlassContainer(
          height: 80,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ToolbarAction(
                icon: MediaAssets.pickerIcon,
                onTap: _showColorPicker,
                color: state.selectedColor,
              ),
              _ToolbarAction(
                icon: MediaAssets.panIcon,
                onTap: () =>
                    context.read<PainterBloc>().add(const ToggleEraser(false)),
                isActive: !state.isEraser,
              ),
              _ToolbarAction(
                icon: MediaAssets.eraserIcon,
                onTap: () =>
                    context.read<PainterBloc>().add(const ToggleEraser(true)),
                isActive: state.isEraser,
              ),
              _ToolbarAction(icon: MediaAssets.galleryIcon, onTap: _pickImage),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Size',
                      style: TextStyle(color: Palette.whiter, fontSize: 10),
                    ),
                    SizedBox(
                      width: 100,
                      child: Slider(
                        value: state.strokeWidth,
                        min: 1,
                        max: 30,
                        activeColor: Palette.primary,
                        inactiveColor: Palette.grey,
                        onChanged: (val) => context.read<PainterBloc>().add(
                          ChangeStrokeWidth(val),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolbarAction extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;
  final bool isActive;
  final Color? color;

  const _ToolbarAction({
    required this.icon,
    required this.onTap,
    this.isActive = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isActive
              ? Palette.primary.withOpacity(0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: color != null
              ? Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Palette.white, width: 2),
                  ),
                )
              : Image.asset(icon, height: 24, color: Palette.white),
        ),
      ),
    );
  }
}

class _DrawingCanvas extends StatelessWidget {
  const _DrawingCanvas();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PainterBloc, PainterState>(
      buildWhen: (previous, current) =>
          previous.lines != current.lines ||
          previous.currentLine != current.currentLine ||
          previous.backgroundImage != current.backgroundImage,
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
            painter: _CanvasPainter(
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

class _CanvasPainter extends CustomPainter {
  final List<DrawnLine> lines;
  final DrawnLine? currentLine;
  final ui.Image? backgroundImage;

  _CanvasPainter({required this.lines, this.currentLine, this.backgroundImage});

  @override
  void paint(Canvas canvas, Size size) {
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
  bool shouldRepaint(covariant _CanvasPainter oldDelegate) {
    return oldDelegate.lines != lines ||
        oldDelegate.currentLine != currentLine ||
        oldDelegate.backgroundImage != backgroundImage;
  }
}
