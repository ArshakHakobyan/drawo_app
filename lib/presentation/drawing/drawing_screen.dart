import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:drawo_app/core/resources/media_assets.dart';
import 'package:drawo_app/core/style/palette.dart';
import 'package:drawo_app/core/service_locator.dart' as service_locator;
import 'package:drawo_app/data/models/drawing_model.dart';
import 'package:drawo_app/presentation/drawing/bloc/drawing_bloc.dart';
import 'package:drawo_app/presentation/gallery/widgets/main_background.dart';
import 'package:drawo_app/core/languages/app_localizations.dart';
import 'package:drawo_app/presentation/common/components/common_header.dart';
import 'package:drawo_app/presentation/common/components/header_icon_button.dart';
import 'package:drawo_app/presentation/drawing/widgets/color_picker_popover.dart';
import 'package:drawo_app/presentation/drawing/widgets/drawing_canvas.dart';
import 'package:drawo_app/presentation/drawing/widgets/toolbar_action.dart';
import 'package:drawo_app/main.dart';

class DrawingScreen extends StatelessWidget {
  final DrawingModel? drawing;
  const DrawingScreen({super.key, this.drawing});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => service_locator.sl<DrawingBloc>(),
      child: _DrawingView(drawing: drawing),
    );
  }
}

class _DrawingView extends StatefulWidget {
  final DrawingModel? drawing;
  const _DrawingView({this.drawing});

  @override
  State<_DrawingView> createState() => _DrawingViewState();
}

class _DrawingViewState extends State<_DrawingView> {
  final GlobalKey _canvasKey = GlobalKey();
  final GlobalKey _colorPickerKey = GlobalKey();
  final GlobalKey _shareButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DrawingBloc>().add(
        InitializeDrawing(imageUrl: widget.drawing?.url),
      );
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      if (mounted) {
        context.read<DrawingBloc>().add(LoadImageFromBytes(bytes));
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
        context.read<DrawingBloc>().add(
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

      if (byteData != null && mounted) {
        final bytes = byteData.buffer.asUint8List();
        final l10n = AppLocalizations.of(context);

        // Calculate share button position for iPad support
        final RenderBox? box =
            _shareButtonKey.currentContext?.findRenderObject() as RenderBox?;
        final Rect? sharePositionOrigin = box != null
            ? box.localToGlobal(Offset.zero) & box.size
            : null;

        context.read<DrawingBloc>().add(
          ShareImageRequested(
            bytes,
            l10n?.shareText ?? 'Check out my drawing!',
            sharePositionOrigin: sharePositionOrigin,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error sharing canvas: $e');
    }
  }

  Future<void> _saveToGallery() async {
    try {
      final boundary =
          _canvasKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null && mounted) {
        final bytes = byteData.buffer.asUint8List();

        context.read<DrawingBloc>().add(SaveToGalleryRequested(bytes));
      }
    } catch (e) {
      debugPrint('Error saving to gallery: $e');
    }
  }

  void _showColorPicker() {
    final drawingBloc = context.read<DrawingBloc>();
    final colors = drawingBloc.state.availableColors;

    // Get the render object of the color picker button
    final RenderBox? button =
        _colorPickerKey.currentContext?.findRenderObject() as RenderBox?;
    final Offset buttonPosition =
        button?.localToGlobal(Offset.zero) ?? Offset.zero;
    final Size buttonSize = button?.size ?? Size.zero;

    // Calculate popover position
    final screenWidth = MediaQuery.of(context).size.width;
    const double dialogWidth = 300;
    const double arrowCenterFromPopoverRight = 31.0;

    final buttonCenterX = buttonPosition.dx + (buttonSize.width / 2);
    final buttonCenterFromRight = screenWidth - buttonCenterX;

    final popoverRight = (buttonCenterFromRight - arrowCenterFromPopoverRight)
        .clamp(10.0, screenWidth - dialogWidth - 10);
    final popoverTop = buttonPosition.dy + buttonSize.height - 200;

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
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
              top: popoverTop,
              right: popoverRight,
              child: SizedBox(
                width: dialogWidth,
                child: Material(
                  color: Colors.transparent,
                  child: ColorPickerPopover(
                    colors: colors,
                    selectedColor: drawingBloc.state.selectedColor,
                    onColorChanged: (color) {
                      drawingBloc.add(ChangeColor(color));
                      Navigator.of(dialogContext).pop();
                    },
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
    return BlocConsumer<DrawingBloc, DrawingState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        final l10n = AppLocalizations.of(context);
        if (state.status == DrawingStatus.saved) {
          showNotification(
            l10n?.imageSaved ?? 'Image Saved',
            l10n?.imageSavedDesc ??
                'Your drawing has been successfully saved to Firebase.',
          );
          Navigator.pop(context);
        } else if (state.status == DrawingStatus.updated) {
          showNotification(
            l10n?.imageUpdated ?? 'Image Updated',
            l10n?.imageUpdatedDesc ??
                'The artwork has been successfully updated.',
          );
          Navigator.pop(context);
        } else if (state.status == DrawingStatus.savedToGallery) {
          showNotification(
            l10n?.savedToGallery ?? 'Saved to Gallery',
            l10n?.savedToGalleryDesc ?? 'Your drawing is now in your photos.',
          );
        } else if (state.status == DrawingStatus.deleted) {
          showNotification(
            l10n?.imageDeleted ?? 'Image Deleted',
            l10n?.imageDeletedDesc ?? 'The artwork has been removed.',
          );
          Navigator.pop(context);
        } else if (state.status == DrawingStatus.error) {
          Fluttertoast.showToast(
            msg: state.errorMessage ?? 'An error occurred',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Palette.red.withValues(alpha: 0.8),
            textColor: Palette.white,
            fontSize: 14.0,
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
                  _buildCanvasArea(),
                ],
              ),
              _buildSavingOverlay(state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCanvasArea() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
        child: Container(
          decoration: BoxDecoration(
            color: Palette.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Palette.accentBlue, width: 3),
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
              child: const DrawingCanvas(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSavingOverlay(DrawingState state) {
    if (state.status != DrawingStatus.saving) return const SizedBox.shrink();
    return Container(
      color: Colors.black26,
      child: const Center(
        child: CircularProgressIndicator(color: Palette.primary),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 350; // iPhone SE is 320px wide

    return CommonHeader(
      title: widget.drawing != null ? l10n.edit : l10n.newImage,
      sideWidth: isCompact
          ? 100
          : 120, // Give more room if needed or keep balanced
      leading: HeaderIconButton(
        asset: MediaAssets.backIcon,
        color: Palette.white,
        onTap: () => Navigator.pop(context),
      ),
      actions: [
        HeaderIconButton(
          key: _shareButtonKey,
          icon: Icons.share,
          color: Palette.white,
          onTap: _shareCanvas,
        ),
        SizedBox(width: isCompact ? 4 : 8),
        HeaderIconButton(
          asset: MediaAssets.doneIcon,
          color: Palette.white,
          onTap: _saveCanvas,
        ),
      ],
    );
  }

  Widget _buildToolbar(BuildContext context, DrawingState state) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 375; // iPhone SE, 7, 8 are small

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Size Label
          const Text(
            'Size',
            style: TextStyle(
              color: Palette.whiter,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          // Flexible Slider
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: isCompact ? 8 : 10,
                thumbShape: RoundSliderThumbShape(
                  enabledThumbRadius: isCompact ? 10 : 12,
                ),
                overlayShape: RoundSliderOverlayShape(
                  overlayRadius: isCompact ? 20 : 24,
                ),
                activeTrackColor: Palette.primary,
                inactiveTrackColor: Palette.grey.withValues(alpha: 0.3),
                thumbColor: Palette.white,
              ),
              child: Slider(
                value: state.strokeWidth,
                min: 1,
                max: 30,
                onChanged: (val) =>
                    context.read<DrawingBloc>().add(ChangeStrokeWidth(val)),
              ),
            ),
          ),
          SizedBox(width: isCompact ? 4 : 8),
          // Actions on the right
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.drawing != null) ...[
                ToolbarAction(
                  iconData: Icons.delete_outline_rounded,
                  color: Palette.red,
                  onTap: () {
                    context.read<DrawingBloc>().add(
                      DeleteImageRequested(
                        widget.drawing!.id,
                        widget.drawing!.storagePath,
                      ),
                    );
                  },
                ),
                SizedBox(width: isCompact ? 4 : 8),
              ],
              ToolbarAction(
                icon: MediaAssets.downloadIcon,
                onTap: _saveToGallery,
              ),
              SizedBox(width: isCompact ? 4 : 8),
              ToolbarAction(icon: MediaAssets.galleryIcon, onTap: _pickImage),
              SizedBox(width: isCompact ? 4 : 8),
              ToolbarAction(
                icon: MediaAssets.panIcon,
                onTap: () =>
                    context.read<DrawingBloc>().add(const ToggleEraser(false)),
                isActive: !state.isEraser,
              ),
              SizedBox(width: isCompact ? 4 : 8),
              ToolbarAction(
                icon: MediaAssets.eraserIcon,
                onTap: () =>
                    context.read<DrawingBloc>().add(const ToggleEraser(true)),
                isActive: state.isEraser,
              ),
              SizedBox(width: isCompact ? 4 : 8),
              ToolbarAction(
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
