part of 'gallery_bloc.dart';

enum GalleryStatus { initial, loading, loaded, error }

class GalleryState extends Equatable {
  final GalleryStatus status;
  final List<DrawingModel> images;
  final String? errorMessage;

  const GalleryState({
    this.status = GalleryStatus.initial,
    this.images = const [],
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, images, errorMessage];

  GalleryState copyWith({
    GalleryStatus? status,
    List<DrawingModel>? images,
    String? errorMessage,
  }) {
    return GalleryState(
      status: status ?? this.status,
      images: images ?? this.images,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
