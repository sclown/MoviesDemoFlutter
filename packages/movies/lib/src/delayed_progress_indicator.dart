//
//  delayed_progress_indicator.dart
//
//  Shared by the grid's load-more footer and the details screen's enrichment,
//  both of which usually finish before a spinner would be worth showing.
//

import 'dart:async';

import 'package:flutter/material.dart';

/// A spinner that appears only once [delay] has passed, so a fast response
/// never produces a flash of one.
class DelayedProgressIndicator extends StatefulWidget {
  const DelayedProgressIndicator({
    required this.identifier,
    this.delay = const Duration(seconds: 1),
    super.key,
  });

  final String identifier;
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
          identifier: widget.identifier,
          child: const Center(child: CircularProgressIndicator()),
        )
      : const SizedBox.shrink();
}
