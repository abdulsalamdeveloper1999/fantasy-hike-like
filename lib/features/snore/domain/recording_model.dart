import 'package:equatable/equatable.dart';

class RecordingModel extends Equatable {
  final String id;
  final String path;
  final DateTime timestamp;
  final Duration duration;
  final bool isFavorite;

  const RecordingModel({
    required this.id,
    required this.path,
    required this.timestamp,
    required this.duration,
    this.isFavorite = false,
  });

  RecordingModel copyWith({
    String? path,
    DateTime? timestamp,
    Duration? duration,
    bool? isFavorite,
  }) {
    return RecordingModel(
      id: id,
      path: path ?? this.path,
      timestamp: timestamp ?? this.timestamp,
      duration: duration ?? this.duration,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [id, path, timestamp, duration, isFavorite];
}
