import 'package:flutter/material.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.body,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;
  final Widget? trailing;

  static const _destinations = [
    NavigationDestination(icon: Icon(Icons.home_rounded), label: '首页'),
    NavigationDestination(icon: Icon(Icons.menu_book_rounded), label: '词书'),
    NavigationDestination(icon: Icon(Icons.bolt_rounded), label: '刷词'),
    NavigationDestination(icon: Icon(Icons.insights_rounded), label: '结果'),
    NavigationDestination(icon: Icon(Icons.warning_amber_rounded), label: '错词本'),
  ];

  static const _railDestinations = [
    NavigationRailDestination(icon: Icon(Icons.home_rounded), label: Text('首页')),
    NavigationRailDestination(icon: Icon(Icons.menu_book_rounded), label: Text('词书')),
    NavigationRailDestination(icon: Icon(Icons.bolt_rounded), label: Text('刷词')),
    NavigationRailDestination(icon: Icon(Icons.insights_rounded), label: Text('结果')),
    NavigationRailDestination(icon: Icon(Icons.warning_amber_rounded), label: Text('错词本')),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isCompact = size.width < 900;

    if (isCompact) {
      return Scaffold(
        backgroundColor: const Color(0xFFEAFBF9),
        appBar: AppBar(
          titleSpacing: 16,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                'mobile-fix-v1',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF4E7B76),
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          actions: [
            if (trailing != null)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Center(child: trailing!),
              ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF8BE6F5), Color(0xFFC8F7F3), Color(0xFFEAFBF9)],
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: body,
            ),
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: onDestinationSelected,
          destinations: _destinations,
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: onDestinationSelected,
            backgroundColor: Colors.white.withValues(alpha: 0.55),
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFD15F),
                      borderRadius: BorderRadius.all(Radius.circular(18)),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'A+',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: Color(0xFF315A5E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'mobile-fix-v1',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: const Color(0xFF4E7B76),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(height: 12),
                    trailing!,
                  ],
                ],
              ),
            ),
            destinations: _railDestinations,
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF8BE6F5), Color(0xFFC8F7F3), Color(0xFFEAFBF9)],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: body,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
