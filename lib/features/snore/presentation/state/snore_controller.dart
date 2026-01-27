import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:step_journey/features/snore/domain/recording_model.dart';

class SnoreController extends ChangeNotifier {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  List<RecordingModel> _recordings = [];
  List<RecordingModel> get recordings => _recordings;

  bool _isRecording = false;
  bool get isRecording => _isRecording;

  String? _currentlyPlayingId;
  String? get currentlyPlayingId => _currentlyPlayingId;

  Duration _currentPosition = Duration.zero;
  Duration get currentPosition => _currentPosition;

  Duration _currentDuration = Duration.zero;
  Duration get currentDuration => _currentDuration;

  Duration get totalActiveDuration =>
      _recordings.fold(Duration.zero, (total, item) => total + item.duration);

  Duration get totalSnoreDuration => Duration(
    milliseconds: (totalActiveDuration.inMilliseconds * 0.12).toInt(),
  ); // Estimated 12% for demo

  double? _manualSnoreScore;

  double get snoreScore {
    if (_manualSnoreScore != null) return _manualSnoreScore!;
    if (_recordings.isEmpty) return 0;
    // Mock score calculation: base 10 + recordings + weighted duration
    double score =
        10.0 + (_recordings.length * 2) + (totalActiveDuration.inSeconds / 30);
    return score.clamp(0, 100);
  }

  void updateSnoreScore(double score) {
    _manualSnoreScore = score;
    notifyListeners();
  }

  String _sleepNote = '';
  String get sleepNote => _sleepNote;

  void updateSleepNote(String note) {
    _sleepNote = note;
    notifyListeners();
  }

  SnoreController() {
    _player.onPlayerComplete.listen((_) {
      debugPrint('Playback completed for: $_currentlyPlayingId');
      _currentlyPlayingId = null;
      _currentPosition = Duration.zero;
      notifyListeners();
    });

    _player.onPositionChanged.listen((pos) {
      _currentPosition = pos;
      notifyListeners();
    });

    _player.onDurationChanged.listen((dur) {
      _currentDuration = dur;
      notifyListeners();
    });

    _player.onLog.listen((msg) {
      debugPrint('AudioPlayer Log: $msg');
    });

    _player.onPlayerStateChanged.listen((state) {
      debugPrint('AudioPlayer State Changed: $state');
    });
  }

  DateTime? _startRecordingTime;

  Future<void> startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final path = p.join(
          directory.path,
          'recording_${DateTime.now().millisecondsSinceEpoch}.m4a',
        );

        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            sampleRate: 44100,
            numChannels: 1,
          ),
          path: path,
        );
        debugPrint('Started recording at: $path');
        _startRecordingTime = DateTime.now();
        _isRecording = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
    }
  }

  void addManualRecording(DateTime timestamp, Duration duration) {
    final recording = RecordingModel(
      id: DateTime.now().toIso8601String(),
      path: 'manual_entry', // Placeholder for manual entries
      timestamp: timestamp,
      duration: duration,
    );
    _recordings.insert(0, recording);
    _recordings.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    notifyListeners();
  }

  Future<void> stopRecording() async {
    try {
      if (_startRecordingTime != null) {
        final elapsed = DateTime.now().difference(_startRecordingTime!);
        if (elapsed < const Duration(seconds: 1)) {
          await Future.delayed(const Duration(seconds: 1) - elapsed);
        }
      }

      final path = await _recorder.stop();
      final stopTime = DateTime.now();
      _isRecording = false;

      if (path != null && _startRecordingTime != null) {
        final duration = stopTime.difference(_startRecordingTime!);
        debugPrint(
          'Stopped recording. Path: $path, Duration: ${duration.inSeconds}s',
        );

        final file = File(path);
        if (await file.exists()) {
          final size = await file.length();
          debugPrint('File size: $size bytes');
        } else {
          debugPrint('Recording file does not exist!');
        }

        final recording = RecordingModel(
          id: DateTime.now().toIso8601String(),
          path: path,
          timestamp: DateTime.now(),
          duration: duration,
        );
        _recordings.insert(0, recording);
      }
      _startRecordingTime = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error stopping recording: $e');
    }
  }

  Future<void> playRecording(RecordingModel recording) async {
    debugPrint('Attempting to play: ${recording.path}');
    try {
      if (_currentlyPlayingId == recording.id) {
        debugPrint('Stopping playback manually');
        await _player.stop();
        _currentlyPlayingId = null;
        _currentPosition = Duration.zero;
      } else {
        final file = File(recording.path);
        if (await file.exists()) {
          final size = await file.length();
          debugPrint('File exists. Size: $size bytes. Starting playback...');

          await _player.stop();
          _currentPosition = Duration.zero;
          _currentDuration = recording.duration;

          await _player.setSource(DeviceFileSource(recording.path));
          await _player.resume();

          _currentlyPlayingId = recording.id;
        } else {
          debugPrint('ERROR: File NOT found at path: ${recording.path}');
        }
      }
    } catch (e, stack) {
      debugPrint('CRITICAL ERROR during playback: $e');
      debugPrint('Stack trace: $stack');
      _currentlyPlayingId = null;
    }
    notifyListeners();
  }

  void deleteRecording(String id) {
    _recordings.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  void toggleFavorite(String id) {
    final index = _recordings.indexWhere((r) => r.id == id);
    if (index != -1) {
      _recordings[index] = _recordings[index].copyWith(
        isFavorite: !_recordings[index].isFavorite,
      );
      notifyListeners();
    }
  }

  void updateTimestamp(String id, DateTime newTimestamp) {
    final index = _recordings.indexWhere((r) => r.id == id);
    if (index != -1) {
      _recordings[index] = _recordings[index].copyWith(timestamp: newTimestamp);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }
}
