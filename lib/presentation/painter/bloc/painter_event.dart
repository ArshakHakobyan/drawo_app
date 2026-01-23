part of 'painter_bloc.dart';

abstract class PainterEvent extends Equatable {
  const PainterEvent();
  @override
  List<Object?> get props => [];
}

class StartDrawing extends PainterEvent {
  final Offset offset;
  const StartDrawing(this.offset);
}

class UpdateDrawing extends PainterEvent {
  final Offset offset;
  const UpdateDrawing(this.offset);
}

class EndDrawing extends PainterEvent {}

class ChangeColor extends PainterEvent {
  final Color color;
  const ChangeColor(this.color);
}

class ChangeStrokeWidth extends PainterEvent {
  final double width;
  const ChangeStrokeWidth(this.width);
}

class ToggleEraser extends PainterEvent {
  final bool isEraser;
  const ToggleEraser(this.isEraser);
}

class ClearCanvas extends PainterEvent {}

class SetBackgroundImage extends PainterEvent {
  final ui.Image image;
  const SetBackgroundImage(this.image);
}

class SaveImageRequested extends PainterEvent {
  final Uint8List imageBytes;
  final String? title;
  const SaveImageRequested(this.imageBytes, {this.title});
}
