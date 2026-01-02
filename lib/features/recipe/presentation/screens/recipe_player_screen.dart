import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:foodiy/features/recipe/domain/recipe_step.dart';
import 'package:foodiy/features/settings/application/settings_service.dart';

class RecipePlayerArgs {
  final String title;
  final String imageUrl;
  final List<RecipeStep> steps;
  final String languageCode;
  final String? recipeId;
  final int? initialStepIndex;
  final bool? initialIsPlaying;
  final int? initialTimerEndEpochMs;
  final int? initialPausedRemainingMs;

  const RecipePlayerArgs({
    required this.title,
    required this.imageUrl,
    required this.steps,
    this.languageCode = 'he',
    this.recipeId,
    this.initialStepIndex,
    this.initialIsPlaying,
    this.initialTimerEndEpochMs,
    this.initialPausedRemainingMs,
  });
}

class RecipePlayerScreen extends StatefulWidget {
  const RecipePlayerScreen({super.key, required this.args});

  final RecipePlayerArgs args;

  @override
  State<RecipePlayerScreen> createState() => _RecipePlayerScreenState();
}

class _RecipePlayerScreenState extends State<RecipePlayerScreen>
    with WidgetsBindingObserver {
  int currentStepIndex = 0;
  Timer? _timer;
  bool _isPlaying = false;
  int _remainingMs = 0;
  int? _timerEndEpochMs;
  bool _handsFree = false;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isCompleted = false;

  List<RecipeStep> get _steps => widget.args.steps;

  RecipeStep get _currentStep {
    if (_steps.isEmpty) {
      return const RecipeStep(text: 'Step 1', durationSeconds: 0);
    }
    if (currentStepIndex >= _steps.length) {
      currentStepIndex = 0;
    }
    return _steps[currentStepIndex];
  }
  int? get _currentDuration => _currentStep.durationSeconds;
  int get _currentDurationMs => (_currentDuration ?? 0) * 1000;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _speech = stt.SpeechToText();
    _restoreInitialState();
  }

  @override
  void dispose() {
    _speech.stop();
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _restoreInitialState() {
    final initialStep = widget.args.initialStepIndex ?? 0;
    setState(() {
      currentStepIndex = initialStep.clamp(0, _steps.length - 1);
    });
    _isPlaying = widget.args.initialIsPlaying ?? false;
    _timerEndEpochMs = widget.args.initialTimerEndEpochMs;
    final pausedMs = widget.args.initialPausedRemainingMs;
    if (_isPlaying && _timerEndEpochMs != null) {
      _remainingMs = _calculateRemainingMs();
      if (_remainingMs <= 0) {
        _handleStepFinished();
        return;
      }
      _startTicker();
    } else if (pausedMs != null) {
      _remainingMs = pausedMs;
      _isPlaying = false;
    } else {
      _remainingMs = _currentDurationMs;
      _isPlaying = false;
    }
  }

  int _calculateRemainingMs() {
    if (_timerEndEpochMs == null) return _remainingMs;
    final now = DateTime.now().millisecondsSinceEpoch;
    final diff = _timerEndEpochMs! - now;
    return diff > 0 ? diff : 0;
  }

  void _startTicker() {
    _timer?.cancel();
    if (!_isPlaying || _timerEndEpochMs == null) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
  }

  void _onTick() {
    if (!_isPlaying || _timerEndEpochMs == null) return;
    final remaining = _calculateRemainingMs();
    if (remaining <= 0) {
      _remainingMs = 0;
      _handleStepFinished();
    } else {
      setState(() {
        _remainingMs = remaining;
      });
    }
  }

  void _stopTicker() {
    _timer?.cancel();
    _timer = null;
  }

  void _resumeTickerIfNeeded() {
    if (!_isPlaying || _timerEndEpochMs == null) return;
    final remaining = _calculateRemainingMs();
    if (remaining <= 0) {
      _remainingMs = 0;
      _handleStepFinished();
      return;
    }
    setState(() {
      _remainingMs = remaining;
    });
    if (_timer == null) {
      _startTicker();
    }
  }

  void _startTimer() {
    if (_steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This recipe has no steps to play')),
      );
      return;
    }
    if (currentStepIndex >= _steps.length) {
      currentStepIndex = 0;
    }
    if (_currentDuration == null) return;
    _stopTicker();
    if (_remainingMs <= 0) {
      _remainingMs = _currentDurationMs;
    }
    _timerEndEpochMs = DateTime.now().millisecondsSinceEpoch + _remainingMs;
    _isPlaying = true;
    _startTicker();
    setState(() {});
  }

  void _pauseTimer() {
    _remainingMs = _calculateRemainingMs();
    _stopTicker();
    _timerEndEpochMs = null;
    _isPlaying = false;
    setState(() {});
  }

  void _handleStepFinished() {
    final settings = SettingsService.instance;
    if (settings.playTimerSound) {
      SystemSound.play(SystemSoundType.alert);
    }

    _stopTicker();
    _timerEndEpochMs = null;
    if (currentStepIndex < widget.args.steps.length - 1) {
      setState(() {
        currentStepIndex++;
        _remainingMs = _currentDurationMs;
        _isPlaying = false;
        _isCompleted = false;
      });
      if (_handsFree && _currentDuration != null) {
        _startTimer();
      }
    } else {
      setState(() {
        _isPlaying = false;
        _remainingMs = 0;
        _isCompleted = true;
      });
    }
  }

  void _resetTimerForCurrentStep() {
    _stopTicker();
    _timerEndEpochMs = null;
    _remainingMs = _currentDurationMs;
    _isPlaying = false;
    _isCompleted = false;
    setState(() {});
  }

  String _formatRemainingTime() {
    final totalSeconds = (_remainingMs / 1000).ceil();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  void nextStep() {
    if (currentStepIndex < widget.args.steps.length - 1) {
      setState(() => currentStepIndex++);
      _resetTimerForCurrentStep();
    }
  }

  void prevStep() {
    if (currentStepIndex > 0) {
      setState(() => currentStepIndex--);
      _resetTimerForCurrentStep();
    }
  }

  Future<void> _startListening() async {
    if (!_handsFree) return;
    final available = await _speech.initialize();
    if (!available) return;
    setState(() => _isListening = true);
    _speech.listen(onResult: (result) {
      final text = result.recognizedWords.toLowerCase();
      if (text.contains('next')) {
        _onNextStepPressed();
      } else if (text.contains('back') || text.contains('previous')) {
        _onPreviousStepPressed();
      } else if (text.contains('pause')) {
        if (_isPlaying) _pauseTimer();
      } else if (text.contains('play')) {
        if (!_isPlaying && _currentDuration != null) _startTimer();
      }
    });
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _resumeTickerIfNeeded();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final steps = widget.args.steps;
    final total = _currentDurationMs;
    final double progress =
        (total > 0 && _remainingMs >= 0) ? 1 - (_remainingMs / total) : 0;

    TextDirection _directionFromLanguage(String code) {
      const rtlLanguages = ['he', 'ar', 'fa', 'ur'];
      return rtlLanguages.contains(code.toLowerCase())
          ? TextDirection.rtl
          : TextDirection.ltr;
    }

    return Directionality(
      textDirection: _directionFromLanguage(widget.args.languageCode),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.args.title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                Navigator.of(context).maybePop();
              }
            },
          ),
          actions: [
            IconButton(
              icon: Icon(_handsFree ? Icons.hearing : Icons.hearing_disabled),
              onPressed: () {
                setState(() => _handsFree = !_handsFree);
              },
              tooltip: 'Hands-free mode',
            ),
            IconButton(
              icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
              onPressed: _handsFree
                  ? () {
                      if (_isListening) {
                        _stopListening();
                      } else {
                        _startListening();
                      }
                    }
                  : null,
              tooltip: 'Voice control',
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  'Step ${currentStepIndex + 1} of ${steps.length}',
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
              if (_handsFree)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Hands-free mode ON',
                    style: theme.textTheme.labelMedium,
                  ),
                ),
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      _currentStep.text,
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              if (_currentDuration != null) ...[
                const SizedBox(height: 16),
                Center(
                  child: SizedBox(
                    width: 160,
                    height: 160,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 160,
                          height: 160,
                          child: CircularProgressIndicator(
                            strokeWidth: 6,
                            value: progress.clamp(0, 1),
                            valueColor:
                                AlwaysStoppedAnimation(theme.colorScheme.primary),
                            backgroundColor: Colors.white,
                          ),
                        ),
                        Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 12,
                                offset: Offset(0, 6),
                              ),
                            ],
                            border: Border.all(
                              color: theme.colorScheme.primary,
                              width: 3,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _formatRemainingTime(),
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.only(bottom: 24, top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildRoundControlButton(
                      icon: Icons.skip_previous,
                      onPressed: currentStepIndex > 0
                          ? () {
                              debugPrint('RecipePlayer: Back pressed');
                              _onPreviousStepPressed();
                              debugPrint(
                                  'Player: Back new index=$currentStepIndex');
                            }
                          : null,
                    ),
                    const SizedBox(width: 24),
                    _buildRoundControlButton(
                      icon: _isPlaying ? Icons.pause : Icons.play_arrow,
                      onPressed: _currentDuration == null
                          ? null
                          : () {
                              debugPrint('RecipePlayer: Play pressed');
                              if (_isPlaying) {
                                _pauseTimer();
                              } else {
                                _startTimer();
                              }
                            },
                      isPrimary: true,
                    ),
                    const SizedBox(width: 24),
                    _buildRoundControlButton(
                      icon: Icons.skip_next,
                      onPressed: currentStepIndex < steps.length - 1
                          ? () {
                              debugPrint('RecipePlayer: Next pressed');
                              _onNextStepPressed();
                              debugPrint(
                                  'Player: Next new index=$currentStepIndex');
                            }
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onNextStepPressed() {
    if (_steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This recipe has no steps to play')),
      );
      return;
    }
    if (currentStepIndex < _steps.length - 1) {
      setState(() => currentStepIndex++);
      _resetTimerForCurrentStep();
    }
  }

  void _onPreviousStepPressed() {
    if (_steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This recipe has no steps to play')),
      );
      return;
    }
    if (currentStepIndex > 0) {
      setState(() => currentStepIndex--);
      _resetTimerForCurrentStep();
    }
  }

  Widget _buildRoundControlButton({
    required IconData icon,
    required VoidCallback? onPressed,
    bool isPrimary = false,
  }) {
    final theme = Theme.of(context);
    final enabled = onPressed != null;
    return InkWell(
      onTap: enabled ? onPressed : null,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: isPrimary ? 72 : 56,
        height: isPrimary ? 72 : 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled
              ? (isPrimary ? theme.colorScheme.primary : Colors.white)
              : Colors.grey.shade300,
          boxShadow: [
            if (enabled)
              const BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
          ],
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Icon(
          icon,
          color: enabled
              ? (isPrimary ? Colors.white : Colors.black87)
              : Colors.grey.shade500,
          size: isPrimary ? 32 : 26,
        ),
      ),
    );
  }
}
