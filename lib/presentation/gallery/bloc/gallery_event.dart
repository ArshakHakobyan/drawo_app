part of 'gallery_bloc.dart';

abstract class GalleryEvent extends Equatable {
  const GalleryEvent();
  @override
  List<Object?> get props => [];
}

class LoadGallery extends GalleryEvent {}

class GalleryUpdated extends GalleryEvent {
  final List<DrawingModel> images;
  const GalleryUpdated(this.images);
  @override
  List<Object?> get props => [images];
}

class DeleteImage extends GalleryEvent {
  final DrawingModel image;
  const DeleteImage(this.image);
  @override
  List<Object?> get props => [image];
}
