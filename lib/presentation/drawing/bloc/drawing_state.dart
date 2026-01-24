part of 'drawing_bloc.dart';

class DrawnLine extends Equatable {
  final List<Offset> path;
  final Color color;
  final double strokeWidth;
  final bool isEraser;

  const DrawnLine({
    required this.path,
    required this.color,
    required this.strokeWidth,
    this.isEraser = false,
  });

  @override
  List<Object?> get props => [path, color, strokeWidth, isEraser];

  DrawnLine copyWith({List<Offset>? path}) {
    return DrawnLine(
      path: path ?? this.path,
      color: color,
      strokeWidth: strokeWidth,
      isEraser: isEraser,
    );
  }
}

enum DrawingStatus {
  initial,
  drawing,
  saving,
  saved,
  updated,
  savedToGallery,
  deleted,
  error,
}

class DrawingState extends Equatable {
  final List<DrawnLine> lines;
  final DrawnLine? currentLine;
  final Color selectedColor;
  final double strokeWidth;
  final bool isEraser;
  final ui.Image? backgroundImage;
  final List<Color> availableColors;
  final DrawingStatus status;
  final String? errorMessage;

  const DrawingState({
    this.lines = const [],
    this.currentLine,
    this.selectedColor = Colors.black,
    this.strokeWidth = 5.0,
    this.isEraser = false,
    this.backgroundImage,
    this.availableColors = const [],
    this.status = DrawingStatus.initial,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
    lines,
    currentLine,
    selectedColor,
    strokeWidth,
    isEraser,
    backgroundImage,
    availableColors,
    status,
    errorMessage,
  ];

  DrawingState copyWith({
    List<DrawnLine>? lines,
    DrawnLine? currentLine,
    bool clearCurrentLine = false,
    Color? selectedColor,
    double? strokeWidth,
    bool? isEraser,
    ui.Image? backgroundImage,
    List<Color>? availableColors,
    DrawingStatus? status,
    String? errorMessage,
  }) {
    return DrawingState(
      lines: lines ?? this.lines,
      currentLine: clearCurrentLine ? null : (currentLine ?? this.currentLine),
      selectedColor: selectedColor ?? this.selectedColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      isEraser: isEraser ?? this.isEraser,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      availableColors: availableColors ?? this.availableColors,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
