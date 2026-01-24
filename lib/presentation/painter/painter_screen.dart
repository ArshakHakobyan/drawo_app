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
import 'package:drawo_app/presentation/gallery/widgets/main_background.dart';
import 'package:drawo_app/core/languages/app_localizations.dart';
import 'package:drawo_app/presentation/common/components/common_header.dart';
import 'package:drawo_app/presentation/common/components/header_icon_button.dart';

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
  final GlobalKey _colorPickerKey = GlobalKey();

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

  List<Color> _generateColors() {
    List<Color> colors = [];
    // Row 1: Grayscale (White to Black)
    for (int i = 0; i < 12; i++) {
      int v = 255 - ((i * 255) / 11).round();
      colors.add(Color.fromARGB(255, v, v, v));
    }

    // Rows 2-9: Colors (8 rows)
    for (int r = 0; r < 8; r++) {
      // Lightness from 0.15 (dark) to 0.85 (light)
      double lightness = 0.15 + (0.7 * r / 7);
      for (int c = 0; c < 12; c++) {
        // Hue starting from ~220 (Blue) and rotating
        double hue = (220.0 + (c * 30.0)) % 360.0;
        colors.add(HSLColor.fromAHSL(1.0, hue, 0.9, lightness).toColor());
      }
    }
    return colors;
  }

  void _showColorPicker() {
    final painterBloc = context.read<PainterBloc>();
    final colors = _generateColors();
    const int crossAxisCount = 12;

    // Get the render object of the color picker button
    final RenderBox? button =
        _colorPickerKey.currentContext?.findRenderObject() as RenderBox?;
    final Offset buttonPosition =
        button?.localToGlobal(Offset.zero) ?? Offset.zero;
    final Size buttonSize = button?.size ?? Size.zero;

    // Assuming a standard width and some right margin
    const double dialogWidth = 300;
    // Calculate left position to align the arrow nicely with the button center
    // Arrow is roughly at right: 28 inside the dialog.
    // Dialog content is constrained.
    // Let's try to position the dialog such that its top-right area is near the button.

    showDialog(
      context: context,
      barrierColor: Colors.transparent, // No dark overlay
      builder: (dialogContext) {
        return Stack(
          children: [
            // Close on tap outside
            GestureDetector(
              onTap: () => Navigator.of(dialogContext).pop(),
              behavior: HitTestBehavior.translucent,
              child: const SizedBox.expand(),
            ),
            Positioned(
              top: buttonPosition.dy - buttonSize.height,
              right:
                  MediaQuery.of(context).size.width -
                  (buttonPosition.dx + buttonSize.width) -
                  10, // Align right edge relative to button
              child: SizedBox(
                width: dialogWidth,
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(
                          'Color Picker',
                          style: TextStyle(
                            color: Palette.whiter,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.topRight,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5E5E5),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 0,
                                    mainAxisSpacing: 0,
                                    childAspectRatio: 1.0,
                                  ),
                              itemCount: colors.length,
                              itemBuilder: (context, index) {
                                final color = colors[index];
                                final isSelected =
                                    painterBloc.state.selectedColor.value ==
                                    color.value;
                                return GestureDetector(
                                  onTap: () {
                                    painterBloc.add(ChangeColor(color));
                                    Navigator.of(dialogContext).pop();
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: color,
                                      border: isSelected
                                          ? Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            )
                                          : null,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            top: -6,
                            right: 24, // Roughly aligns with button center
                            child: Transform.rotate(
                              angle: 45 * 3.14159 / 180,
                              child: Container(
                                width: 14,
                                height: 14,
                                color: const Color(0xFFE5E5E5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
              const MainBackground(),
              Column(
                children: [
                  _buildHeader(context),
                  _buildToolbar(context, state),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFF4A90E2),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(21),
                          child: RepaintBoundary(
                            key: _canvasKey,
                            child: const _DrawingCanvas(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (state.status == PainterStatus.saving)
                Container(
                  color: Colors.black26,
                  child: const Center(
                    child: CircularProgressIndicator(color: Palette.primary),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return CommonHeader(
      title: widget.drawing != null ? l10n.edit : l10n.newImage,
      leading: HeaderIconButton(
        asset: MediaAssets.backIcon,
        color: Palette.white,
        onTap: () => Navigator.pop(context),
      ),
      actions: [
        HeaderIconButton(
          icon: Icons.share,
          color: Palette.white,
          onTap: _shareCanvas,
        ),
        const SizedBox(width: 8),
        HeaderIconButton(
          asset: MediaAssets.doneIcon,
          color: Palette.white,
          onTap: _saveCanvas,
        ),
      ],
    );
  }

  Widget _buildToolbar(BuildContext context, PainterState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Size Slider on the left
          const Text(
            'Size',
            style: TextStyle(
              color: Palette.whiter,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            flex: 2,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 10,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
                activeTrackColor: Palette.primary,
                inactiveTrackColor: Palette.grey.withValues(alpha: 0.3),
                thumbColor: Palette.white,
              ),
              child: Slider(
                value: state.strokeWidth,
                min: 1,
                max: 30,
                onChanged: (val) =>
                    context.read<PainterBloc>().add(ChangeStrokeWidth(val)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Actions on the right
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.drawing != null) ...[
                _ToolbarAction(
                  iconData: Icons.delete_outline_rounded,
                  color: Palette.red,
                  onTap: () {
                    context.read<PainterBloc>().add(
                      DeleteImageRequested(
                        widget.drawing!.id,
                        widget.drawing!.storagePath,
                      ),
                    );
                  },
                ),
              ],
              const SizedBox(width: 8),
              _ToolbarAction(
                icon: MediaAssets.downloadIcon,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Saving to gallery...')),
                  );
                },
              ),
              const SizedBox(width: 8),
              _ToolbarAction(icon: MediaAssets.galleryIcon, onTap: _pickImage),
              const SizedBox(width: 8),
              _ToolbarAction(
                icon: MediaAssets.panIcon,
                onTap: () =>
                    context.read<PainterBloc>().add(const ToggleEraser(false)),
                isActive: !state.isEraser,
              ),
              const SizedBox(width: 8),
              _ToolbarAction(
                icon: MediaAssets.eraserIcon,
                onTap: () =>
                    context.read<PainterBloc>().add(const ToggleEraser(true)),
                isActive: state.isEraser,
              ),
              const SizedBox(width: 8),
              _ToolbarAction(
                key: _colorPickerKey,
                icon: MediaAssets.pickerIcon,
                onTap: _showColorPicker,
                color: state.selectedColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToolbarAction extends StatelessWidget {
  final String? icon;
  final IconData? iconData;
  final VoidCallback onTap;
  final bool isActive;
  final Color? color;

  const _ToolbarAction({
    super.key,
    this.icon,
    this.iconData,
    required this.onTap,
    this.isActive = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isActive
              ? Palette.primary.withValues(alpha: 0.3)
              : Palette.darkGrey.withValues(alpha: 0.6),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: iconData != null
              ? Icon(iconData, color: color ?? Palette.white, size: 24)
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      icon!,
                      height: 24,
                      color: (color != null && icon != MediaAssets.pickerIcon)
                          ? color
                          : Palette.white,
                    ),
                    if (icon == MediaAssets.pickerIcon && color != null)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(color: Palette.white, width: 1),
                          ),
                        ),
                      ),
                  ],
                ),
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
