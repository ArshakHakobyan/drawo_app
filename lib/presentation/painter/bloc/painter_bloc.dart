import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:drawo_app/data/services/gallery_service.dart';
import 'package:drawo_app/main.dart';

part 'painter_event.dart';
part 'painter_state.dart';

class PainterBloc extends Bloc<PainterEvent, PainterState> {
  final GalleryService _imageRepository;

  PainterBloc({required GalleryService imageRepository})
    : _imageRepository = imageRepository,
      super(const PainterState()) {
    on<StartDrawing>(_onStartDrawing);
    on<UpdateDrawing>(_onUpdateDrawing);
    on<EndDrawing>(_onEndDrawing);
    on<ChangeColor>(_onChangeColor);
    on<ChangeStrokeWidth>(_onChangeStrokeWidth);
    on<ToggleEraser>(_onToggleEraser);
    on<ClearCanvas>(_onClearCanvas);
    on<SetBackgroundImage>(_onSetBackgroundImage);
    on<SaveImageRequested>(_onSaveImageRequested);
  }

  void _onStartDrawing(StartDrawing event, Emitter<PainterState> emit) {
    final newLine = DrawnLine(
      path: [event.offset],
      color: state.isEraser ? Colors.transparent : state.selectedColor,
      strokeWidth: state.strokeWidth,
      isEraser: state.isEraser,
    );
    emit(state.copyWith(currentLine: newLine));
  }

  void _onUpdateDrawing(UpdateDrawing event, Emitter<PainterState> emit) {
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

  void _onEndDrawing(EndDrawing event, Emitter<PainterState> emit) {
    if (state.currentLine != null) {
      final updatedLines = List<DrawnLine>.from(state.lines)
        ..add(state.currentLine!);
      emit(state.copyWith(lines: updatedLines, clearCurrentLine: true));
    }
  }

  void _onChangeColor(ChangeColor event, Emitter<PainterState> emit) {
    emit(state.copyWith(selectedColor: event.color, isEraser: false));
  }

  void _onChangeStrokeWidth(
    ChangeStrokeWidth event,
    Emitter<PainterState> emit,
  ) {
    emit(state.copyWith(strokeWidth: event.width));
  }

  void _onToggleEraser(ToggleEraser event, Emitter<PainterState> emit) {
    emit(state.copyWith(isEraser: event.isEraser));
  }

  void _onClearCanvas(ClearCanvas event, Emitter<PainterState> emit) {
    emit(state.copyWith(lines: [], backgroundImage: null));
  }

  void _onSetBackgroundImage(
    SetBackgroundImage event,
    Emitter<PainterState> emit,
  ) {
    emit(state.copyWith(backgroundImage: event.image));
  }

  Future<void> _onSaveImageRequested(
    SaveImageRequested event,
    Emitter<PainterState> emit,
  ) async {
    emit(state.copyWith(status: PainterStatus.saving));
    try {
      await _imageRepository.uploadImage(
        bytes: event.imageBytes,
        title: event.title,
      );

      await showNotification(
        'Image Saved',
        'Your drawing has been successfully saved to Firebase.',
      );

      emit(state.copyWith(status: PainterStatus.saved));
    } catch (e) {
      emit(
        state.copyWith(status: PainterStatus.error, errorMessage: e.toString()),
      );
    }
  }
}
