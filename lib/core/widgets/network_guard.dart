import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import 'package:foodiy/core/widgets/no_internet_screen.dart';

class NetworkGuard extends StatefulWidget {
  final Widget child;

  const NetworkGuard({super.key, required this.child});

  @override
  State<NetworkGuard> createState() => _NetworkGuardState();
}

class _NetworkGuardState extends State<NetworkGuard> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _hasInternet = true;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _subscription =
        _connectivity.onConnectivityChanged.listen((results) {
      final hasInternet = results.isNotEmpty &&
          results.first != ConnectivityResult.none;
      if (mounted) {
        setState(() {
          _hasInternet = hasInternet;
        });
      }
    });
  }

  Future<void> _initConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    final hasInternet =
        results.isNotEmpty && results.first != ConnectivityResult.none;
    if (mounted) {
      setState(() {
        _hasInternet = hasInternet;
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasInternet) {
      return NoInternetView(
        onRetry: _initConnectivity,
      );
    }
    return widget.child;
  }
}
