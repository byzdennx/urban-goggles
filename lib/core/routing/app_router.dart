import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/chat/chat_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/tasks/tasks_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (_, state) =>
          const NoTransitionPage(child: ChatScreen()),
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (_, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SettingsScreen(),
        transitionsBuilder: (_, a, __, child) {
          final c = CurvedAnimation(parent: a, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: c,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(c),
              child: child,
            ),
          );
        },
      ),
    ),
    GoRoute(
      path: '/tasks',
      pageBuilder: (_, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const TasksScreen(),
        transitionsBuilder: (_, a, __, child) {
          final c = CurvedAnimation(parent: a, curve: Curves.easeOutCubic);
          return FadeTransition(opacity: c, child: child);
        },
      ),
    ),
  ],
);