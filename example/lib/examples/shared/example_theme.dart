// MIT License
//
// Copyright (c) 2020 sooxie

import 'package:flutter/material.dart';

const Color kExampleInk = Color(0xFF182230);
const Color kExampleMuted = Color(0xFF667085);
const Color kExampleLine = Color(0xFFE4E7EC);
const Color kExampleSurface = Color(0xFFF6F8FB);
const Color kExamplePrimary = Color(0xFF2563EB);
const Color kExampleTeal = Color(0xFF0F766E);
const Color kExampleAmber = Color(0xFFB45309);
const Color kExampleRose = Color(0xFFE11D48);

Color exampleOpacity(Color color, double opacity) {
  final value = opacity < 0
      ? 0.0
      : opacity > 1
          ? 1.0
          : opacity;
  return color.withAlpha((value * 255).round());
}

class ExampleScaffold extends StatelessWidget {
  const ExampleScaffold({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.actions = const <Widget>[],
  }) : super(key: key);

  final String title;
  final String subtitle;
  final Widget child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: kExampleSurface,
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
            child: Text(
              subtitle,
              style: textTheme.bodyMedium?.copyWith(
                color: kExampleMuted,
                height: 1.35,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kExampleLine),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
