import 'package:flutter/material.dart';

import 'examples/examples_registry.dart';
import 'examples/shared/example_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'list_treeview examples',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: kExamplePrimary),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: kExampleInk,
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            foregroundColor: kExampleMuted,
            hoverColor: exampleOpacity(kExamplePrimary, 0.08),
          ),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

/// Lists every example; tapping one pushes its detail page.
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: kExampleSurface,
      appBar: AppBar(title: const Text('list_treeview')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kExampleInk,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: exampleOpacity(Colors.white, 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.account_tree, color: Colors.white),
                ),
                const SizedBox(height: 18),
                Text(
                  'Flutter tree view examples',
                  style: textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Explore expansion, selection, mutation, and lazy loading with reusable row UI.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: exampleOpacity(Colors.white, 0.72),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < examplesRegistry.length; i++)
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : 10),
              child: _ExampleCard(entry: examplesRegistry[i], index: i),
            ),
        ],
      ),
    );
  }
}

class _ExampleCard extends StatelessWidget {
  const _ExampleCard({required this.entry, required this.index});

  final ExampleEntry entry;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = <Color>[
      kExamplePrimary,
      kExampleTeal,
      kExampleAmber,
      kExampleRose,
    ];
    final icons = <IconData>[
      Icons.unfold_more,
      Icons.add_circle_outline,
      Icons.check_circle_outline,
      Icons.cloud_sync_outlined,
    ];
    final accent = colors[index % colors.length];
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: entry.builder),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: kExampleLine),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: exampleOpacity(accent, 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icons[index % icons.length], color: accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      entry.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        color: kExampleInk,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: kExampleMuted,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: kExampleMuted),
            ],
          ),
        ),
      ),
    );
  }
}
