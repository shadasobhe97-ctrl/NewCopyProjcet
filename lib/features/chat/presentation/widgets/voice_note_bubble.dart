import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:kids_transport/core/theme/text_styles.dart';

class VoiceNoteBubble extends StatefulWidget {
  final String audioUrl;
  final int? durationSeconds;
  final bool isMe;
  final bool isDark;

  const VoiceNoteBubble({
    super.key,
    required this.audioUrl,
    this.durationSeconds,
    required this.isMe,
    this.isDark = false,
  });

  @override
  State<VoiceNoteBubble> createState() => _VoiceNoteBubbleState();
}

class _VoiceNoteBubbleState extends State<VoiceNoteBubble> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;

  @override
  void initState() {
    super.initState();
    if (widget.durationSeconds != null && widget.durationSeconds! > 0) {
      _duration = Duration(seconds: widget.durationSeconds!);
    }

    _playerStateSubscription = _player.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _positionSubscription = _player.onPositionChanged.listen((pos) {
      if (mounted) {
        setState(() {
          _position = pos;
        });
      }
    });

    _durationSubscription = _player.onDurationChanged.listen((dur) {
      if (mounted) {
        setState(() {
          _duration = dur;
        });
      }
    });
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    try {
      if (_isPlaying) {
        await _player.pause();
      } else {
        await _player.play(UrlSource(widget.audioUrl));
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AudioPlayer error: $e');
      }
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final double maxSec =
        _duration.inSeconds > 0 ? _duration.inSeconds.toDouble() : 1.0;
    final double currentSec =
        _position.inSeconds.toDouble().clamp(0.0, maxSec);

    final primaryColor = Theme.of(context).colorScheme.primary;

    final Color accentColor = widget.isDark
        ? const Color(0xFF38BDF8)
        : primaryColor;
    final Color inactiveTrackColor = widget.isDark
        ? const Color(0xFF475569)
        : const Color(0xFFCBD5E1);
    final Color durationTextColor = widget.isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    return Container(
      width: 210.w,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(
              _isPlaying
                  ? Icons.pause_circle_filled_rounded
                  : Icons.play_circle_fill_rounded,
              size: 34.r,
              color: accentColor,
            ),
            onPressed: _togglePlay,
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SliderTheme(
                  data: SliderThemeData(
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5.r),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 8.r),
                    trackHeight: 3.h,
                    activeTrackColor: accentColor,
                    inactiveTrackColor: inactiveTrackColor,
                    thumbColor: accentColor,
                  ),
                  child: Slider(
                    value: currentSec,
                    max: maxSec,
                    onChanged: (val) {
                      _player.seek(Duration(seconds: val.toInt()));
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Text(
                    _formatDuration(
                        _position.inSeconds > 0 ? _position : _duration),
                    style: AppTextStyles.style(
                      fontSize: 10.sp,
                      color: durationTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
