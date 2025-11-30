import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:foodiy/features/recipe/domain/recipe_step.dart';
import 'package:foodiy/features/settings/application/settings_service.dart';

class RecipePlayerArgs {
  final String title;
  final String imageUrl;
  final List<RecipeStep> steps;
  final String languageCode;

  const RecipePlayerArgs({
    required this.title,
    required this.imageUrl,
    required this.steps,
    this.languageCode = 'he',
  });
}

class RecipePlayerScreen extends StatefulWidget {
  const RecipePlayerScreen({super.key, required this.args});

  final RecipePlayerArgs args;

  @override
  State<RecipePlayerScreen> createState() => _RecipePlayerScreenState();
}

class _RecipePlayerScreenState extends State<RecipePlayerScreen> {
  int currentStepIndex = 0;
  Timer? _timer;
  bool _isPlaying = false;
  int _remainingSeconds = 0;

  RecipeStep get _currentStep => widget.args.steps[currentStepIndex];
  int? get _currentDuration => _currentStep.durationSeconds;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _currentDuration ?? 0;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_currentDuration == null) return;
    _timer?.cancel();
    if (_remainingSeconds <= 0) {
      _remainingSeconds = _currentDuration!;
    }
    _isPlaying = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _handleStepFinished();
      }
    });
    setState(() {});
  }

  void _pauseTimer() {
    _timer?.cancel();
    _isPlaying = false;
    setState(() {});
  }

  void _handleStepFinished() {
    final settings = SettingsService.instance;
    if (settings.playTimerSound) {
      SystemSound.play(SystemSoundType.alert);
    }

    _timer?.cancel();
    if (currentStepIndex < widget.args.steps.length - 1) {
      setState(() {
        currentStepIndex++;
        _remainingSeconds = _currentDuration ?? 0;
        _isPlaying = false;
      });
      if (_currentDuration != null) {
        _startTimer();
      }
    } else {
      setState(() {
        _isPlaying = false;
        _remainingSeconds = 0;
      });
    }
  }

  void _resetTimerForCurrentStep() {
    _timer?.cancel();
    _remainingSeconds = _currentDuration ?? 0;
    _isPlaying = false;
    setState(() {});
  }

  String _formatRemainingTime() {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final steps = widget.args.steps;

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
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    widget.args.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.black12,
                        alignment: Alignment.center,
                        child: const Icon(Icons.image_not_supported),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: Text(
                    _currentStep.text,
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    'Step ${currentStepIndex + 1} of ${steps.length}',
                    style: theme.textTheme.bodySmall,
                  ),
                  if (_currentDuration != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Time left: ${_formatRemainingTime()}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: _onPreviousStepPressed,
                    icon: const Icon(Icons.skip_previous),
                  ),
                  IconButton(
                    onPressed: _currentDuration == null
                        ? null
                        : () {
                            if (_isPlaying) {
                              _pauseTimer();
                            } else {
                              _startTimer();
                            }
                          },
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  ),
                  IconButton(
                    onPressed: _onNextStepPressed,
                    icon: const Icon(Icons.skip_next),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _onNextStepPressed() {
    if (currentStepIndex < widget.args.steps.length - 1) {
      setState(() => currentStepIndex++);
      _resetTimerForCurrentStep();
    }
  }

  void _onPreviousStepPressed() {
    if (currentStepIndex > 0) {
      setState(() => currentStepIndex--);
      _resetTimerForCurrentStep();
    }
  }
}
