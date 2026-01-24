import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';
import 'package:drawo_app/data/services/gallery_service.dart';

part 'drawing_event.dart';
part 'drawing_state.dart';

class DrawingBloc extends Bloc<DrawingEvent, DrawingState> {
  final GalleryService _imageRepository;

  DrawingBloc({required GalleryService imageRepository})
    : _imageRepository = imageRepository,
      super(const DrawingState()) {
    on<StartDrawing>(_onStartDrawing);
    on<UpdateDrawing>(_onUpdateDrawing);
    on<EndDrawing>(_onEndDrawing);
    on<ChangeColor>(_onChangeColor);
    on<ChangeStrokeWidth>(_onChangeStrokeWidth);
    on<ToggleEraser>(_onToggleEraser);
    on<ClearCanvas>(_onClearCanvas);
    on<InitializeDrawing>(_onInitializeDrawing);
    on<SetBackgroundImage>(_onSetBackgroundImage);
    on<LoadImageFromBytes>(_onLoadImageFromBytes);
    on<SaveImageRequested>(_onSaveImageRequested);
    on<SaveToGalleryRequested>(_onSaveToGalleryRequested);
    on<ShareImageRequested>(_onShareImageRequested);
    on<DeleteImageRequested>(_onDeleteImageRequested);
  }

  // Setup canvas and colors
  void _onInitializeDrawing(
    InitializeDrawing event,
    Emitter<DrawingState> emit,
  ) {
    final colors = _generateColors();
    emit(state.copyWith(availableColors: colors));

    if (event.imageUrl != null) {
      _loadInitialImage(event.imageUrl!, emit);
    }
  }

  // Load image from URL to canvas
  Future<void> _loadInitialImage(String url, Emitter<DrawingState> emit) async {
    try {
      final ImageProvider provider = NetworkImage(url);
      final ImageStream stream = provider.resolve(ImageConfiguration.empty);
      final completer = Completer<ui.Image>();
      late ImageStreamListener listener;
      listener = ImageStreamListener(
        (ImageInfo info, bool _) {
          completer.complete(info.image);
          stream.removeListener(listener);
        },
        onError: (exception, stackTrace) {
          completer.completeError(exception, stackTrace);
          stream.removeListener(listener);
        },
      );
      stream.addListener(listener);

      final image = await completer.future;
      add(SetBackgroundImage(image));
    } catch (e) {
      debugPrint('Error loading initial background image: $e');
    }
  }

  // Generate color picker palette
  List<Color> _generateColors() {
    List<Color> colors = [];
    for (int i = 0; i < 12; i++) {
      int v = 255 - ((i * 255) / 11).round();
      colors.add(Color.fromARGB(255, v, v, v));
    }
    for (int r = 0; r < 8; r++) {
      double lightness = 0.15 + (0.7 * r / 7);
      for (int c = 0; c < 12; c++) {
        double hue = (220.0 + (c * 30.0)) % 360.0;
        colors.add(HSLColor.fromAHSL(1.0, hue, 0.9, lightness).toColor());
      }
    }
    return colors;
  }

  // Start a new line
  void _onStartDrawing(StartDrawing event, Emitter<DrawingState> emit) {
    final newLine = DrawnLine(
      path: [event.offset],
      color: state.isEraser ? Colors.transparent : state.selectedColor,
      strokeWidth: state.strokeWidth,
      isEraser: state.isEraser,
    );
    emit(state.copyWith(currentLine: newLine));
  }

  // Draw points as user moves
  void _onUpdateDrawing(UpdateDrawing event, Emitter<DrawingState> emit) {
    if (state.currentLine != null) {
      final updatedPath = List<Offset>.from(state.currentLine!.path)
        ..add(event.offset);
      emit(
        state.copyWith(
          currentLine: state.currentLine!.copyWith(path: updatedPath),
        ),
      );
    }
  }

  // Finish the current line
  void _onEndDrawing(EndDrawing event, Emitter<DrawingState> emit) {
    if (state.currentLine != null) {
      final updatedLines = List<DrawnLine>.from(state.lines)
        ..add(state.currentLine!);
      emit(state.copyWith(lines: updatedLines, clearCurrentLine: true));
    }
  }

  // Switch pen color
  void _onChangeColor(ChangeColor event, Emitter<DrawingState> emit) {
    emit(state.copyWith(selectedColor: event.color, isEraser: false));
  }

  // Change pen thickness
  void _onChangeStrokeWidth(
    ChangeStrokeWidth event,
    Emitter<DrawingState> emit,
  ) {
    emit(state.copyWith(strokeWidth: event.width));
  }

  // Toggle eraser on/off
  void _onToggleEraser(ToggleEraser event, Emitter<DrawingState> emit) {
    emit(state.copyWith(isEraser: event.isEraser));
  }

  // Clear everything from canvas
  void _onClearCanvas(ClearCanvas event, Emitter<DrawingState> emit) {
    emit(state.copyWith(lines: [], backgroundImage: null));
  }

  // Set background photo
  void _onSetBackgroundImage(
    SetBackgroundImage event,
    Emitter<DrawingState> emit,
  ) {
    emit(state.copyWith(backgroundImage: event.image));
  }

  // Convert bytes to UI image
  Future<void> _onLoadImageFromBytes(
    LoadImageFromBytes event,
    Emitter<DrawingState> emit,
  ) async {
    try {
      final codec = await ui.instantiateImageCodec(event.bytes);
      final frameInfo = await codec.getNextFrame();
      add(SetBackgroundImage(frameInfo.image));
    } catch (e) {
      debugPrint('Error decoding image bytes: $e');
    }
  }

  // Save artwork to Firebase
  Future<void> _onSaveImageRequested(
    SaveImageRequested event,
    Emitter<DrawingState> emit,
  ) async {
    emit(state.copyWith(status: DrawingStatus.saving));
    try {
      if (event.existingDocId != null && event.oldStoragePath != null) {
        await _imageRepository.updateExistingImage(
          docId: event.existingDocId!,
          bytes: event.imageBytes,
          oldStoragePath: event.oldStoragePath!,
          title: event.title,
          width: event.width,
          height: event.height,
        );

        emit(state.copyWith(status: DrawingStatus.updated));
      } else {
        await _imageRepository.uploadImage(
          bytes: event.imageBytes,
          title: event.title,
          width: event.width,
          height: event.height,
        );

        emit(state.copyWith(status: DrawingStatus.saved));
      }
    } catch (e) {
      emit(
        state.copyWith(status: DrawingStatus.error, errorMessage: e.toString()),
      );
    }
  }

  // Save to phone gallery
  Future<void> _onSaveToGalleryRequested(
    SaveToGalleryRequested event,
    Emitter<DrawingState> emit,
  ) async {
    emit(state.copyWith(status: DrawingStatus.saving));
    try {
      await Gal.putImageBytes(event.imageBytes);

      emit(state.copyWith(status: DrawingStatus.savedToGallery));
    } catch (e) {
      emit(
        state.copyWith(status: DrawingStatus.error, errorMessage: e.toString()),
      );
    }
  }

  // Share image with others
  Future<void> _onShareImageRequested(
    ShareImageRequested event,
    Emitter<DrawingState> emit,
  ) async {
    try {
      final params = ShareParams(
        files: [
          XFile.fromData(
            event.imageBytes,
            name: 'drawing.png',
            mimeType: 'image/png',
          ),
        ],
        text: event.shareText,
      );
      await SharePlus.instance.share(params);
    } catch (e) {
      debugPrint('Error sharing image: $e');
    }
  }

  // Delete matching image
  Future<void> _onDeleteImageRequested(
    DeleteImageRequested event,
    Emitter<DrawingState> emit,
  ) async {
    emit(state.copyWith(status: DrawingStatus.saving));
    try {
      await _imageRepository.deleteImage(event.docId, event.storagePath);

      emit(state.copyWith(status: DrawingStatus.deleted));
    } catch (e) {
      emit(
        state.copyWith(status: DrawingStatus.error, errorMessage: e.toString()),
      );
    }
  }
}
