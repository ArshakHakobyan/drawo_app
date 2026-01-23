part of 'painter_bloc.dart';

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

enum PainterStatus { initial, drawing, saving, saved, deleted, error }

class PainterState extends Equatable {
  final List<DrawnLine> lines;
  final DrawnLine? currentLine;
  final Color selectedColor;
  final double strokeWidth;
  final bool isEraser;
  final ui.Image? backgroundImage;
  final PainterStatus status;
  final String? errorMessage;

  const PainterState({
    this.lines = const [],
    this.currentLine,
    this.selectedColor = Colors.black,
    this.strokeWidth = 5.0,
    this.isEraser = false,
    this.backgroundImage,
    this.status = PainterStatus.initial,
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
    status,
    errorMessage,
  ];

  PainterState copyWith({
    List<DrawnLine>? lines,
    DrawnLine? currentLine,
    bool clearCurrentLine = false,
    Color? selectedColor,
    double? strokeWidth,
    bool? isEraser,
    ui.Image? backgroundImage,
    PainterStatus? status,
    String? errorMessage,
  }) {
    return PainterState(
      lines: lines ?? this.lines,
      currentLine: clearCurrentLine ? null : (currentLine ?? this.currentLine),
      selectedColor: selectedColor ?? this.selectedColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      isEraser: isEraser ?? this.isEraser,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
