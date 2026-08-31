//
//  delayed_progress_indicator.dart
//

import 'dart:async';

import 'package:flutter/material.dart';

class DelayedProgressIndicator extends StatefulWidget {
  const DelayedProgressIndicator({
    this.delay = const Duration(seconds: 1),
    super.key,
  });

  final Duration delay;

  @override
  State<DelayedProgressIndicator> createState() =>
      _DelayedProgressIndicatorState();
}

class _DelayedProgressIndicatorState extends State<DelayedProgressIndicator> {
  Timer? _timer;
  var _visible = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _visible
      ? Semantics(
          identifier: 'nextPageSpinner',
          child: Center(child: CircularProgressIndicator()),
        )
      : const SizedBox.shrink();
}
