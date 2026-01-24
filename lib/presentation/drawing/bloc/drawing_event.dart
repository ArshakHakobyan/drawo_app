part of 'drawing_bloc.dart';

abstract class DrawingEvent extends Equatable {
  const DrawingEvent();
  @override
  List<Object?> get props => [];
}

class StartDrawing extends DrawingEvent {
  final Offset offset;
  const StartDrawing(this.offset);
}

class UpdateDrawing extends DrawingEvent {
  final Offset offset;
  const UpdateDrawing(this.offset);
}

class EndDrawing extends DrawingEvent {}

class ChangeColor extends DrawingEvent {
  final Color color;
  const ChangeColor(this.color);
}

class ChangeStrokeWidth extends DrawingEvent {
  final double width;
  const ChangeStrokeWidth(this.width);
}

class ToggleEraser extends DrawingEvent {
  final bool isEraser;
  const ToggleEraser(this.isEraser);
}

class ClearCanvas extends DrawingEvent {}

class InitializeDrawing extends DrawingEvent {
  final String? imageUrl;
  const InitializeDrawing({this.imageUrl});
}

class SetBackgroundImage extends DrawingEvent {
  final ui.Image image;
  const SetBackgroundImage(this.image);
}

class LoadImageFromBytes extends DrawingEvent {
  final Uint8List bytes;
  const LoadImageFromBytes(this.bytes);
}

class SaveImageRequested extends DrawingEvent {
  final Uint8List imageBytes;
  final String? title;
  final String? existingDocId;
  final String? oldStoragePath;
  final int? width;
  final int? height;

  const SaveImageRequested({
    required this.imageBytes,
    this.title,
    this.existingDocId,
    this.oldStoragePath,
    this.width,
    this.height,
  });
}

class SaveToGalleryRequested extends DrawingEvent {
  final Uint8List imageBytes;
  const SaveToGalleryRequested(this.imageBytes);
}

class ShareImageRequested extends DrawingEvent {
  final Uint8List imageBytes;
  final String shareText;
  final Rect? sharePositionOrigin;
  const ShareImageRequested(
    this.imageBytes,
    this.shareText, {
    this.sharePositionOrigin,
  });
}

class DeleteImageRequested extends DrawingEvent {
  final String docId;
  final String storagePath;
  const DeleteImageRequested(this.docId, this.storagePath);
}
