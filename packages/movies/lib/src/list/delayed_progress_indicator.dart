//
//  delayed_progress_indicator.dart
//

import 'dart:async';

import 'package:flutter/material.dart';

/// A spinner that only appears once [delay] has passed, so a page that arrives
/// quickly never flashes one. Mount it while the work is in flight and remove
/// it when the work finishes: the timer is cancelled on dispose, and a new
/// mount starts the wait again.
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
      ? const Center(child: CircularProgressIndicator())
      : const SizedBox.shrink();
}
