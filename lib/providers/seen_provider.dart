// ignore_for_file: prefer_typing_uninitialized_variables, overridden_fields

import 'package:lamatdating/providers/seen_state.dart';
import 'package:lamatdating/views/tabs/chat/chat_scr/widg/bubble.dart';
import 'package:flutter/widgets.dart';

class SeenProvider extends StatefulWidget {
  const SeenProvider({super.key, this.timestamp, this.data, this.child});
  final SeenState? data;
  final Bubble? child;
  final String? timestamp;
  static of(BuildContext context) {
    _SeenInheritedProvider? p = context.dependOnInheritedWidgetOfExactType(
        aspect: _SeenInheritedProvider);
    return p!.data;
  }

  @override
  State<StatefulWidget> createState() => _SeenProviderState();
}

class _SeenProviderState extends State<SeenProvider> {
  @override
  initState() {
    super.initState();
    widget.data!.addListener(didValueChange);
  }

  didValueChange() {
    if (mounted) setState(() {});
  }

  @override
  dispose() {
    widget.data!.removeListener(didValueChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SeenInheritedProvider(
      data: widget.data,
      child: widget.child ?? const SizedBox(),
    );
  }
}

class _SeenInheritedProvider extends InheritedWidget {
  _SeenInheritedProvider({required this.data, required this.child})
      : _dataValue = data.value,
        super(child: child);
  final data;
  @override
  final Widget child;
  final _dataValue;
  @override
  bool updateShouldNotify(_SeenInheritedProvider oldWidget) {
    return _dataValue != oldWidget._dataValue;
  }
}
