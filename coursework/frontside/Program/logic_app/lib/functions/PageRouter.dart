import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logic_app/pages/DatabasePage.dart';
import 'package:logic_app/pages/HomePage.dart';
import 'package:logic_app/pages/QuizPage.dart';
import 'package:logic_app/pages/SignInPage.dart';
import 'package:logic_app/pages/SettingsPage.dart';
import 'package:logic_app/pages/StatisticsPage.dart';

final GoRouter router_config = GoRouter(routes: [
  GoRoute(
      name: 'quiz',
      path: '/quiz',
      pageBuilder: (context, state) {
        return const MaterialPage(child: QuizPage());
      }),
  GoRoute(
      name: 'homepage',
      path: '/homepage',
      pageBuilder: (context, state) {
        return const MaterialPage(child: HomePage());
      }),
  GoRoute(
      name: 'statistics',
      path: '/statistics',
      pageBuilder: (context, state) {
        return const MaterialPage(child: StatisticsPage());
      }),
  GoRoute(
      name: 'settings',
      path: '/settings',
      pageBuilder: (context, state) {
        return const MaterialPage(child: SettingsPage());
      }),
  GoRoute(
      name: 'signin',
      path: '/',
      pageBuilder: (context, state) {
        return const MaterialPage(child: SignInPage());
      }),
  GoRoute(
      name: 'database',
      path: '/settings/database',
      pageBuilder: (context, state) {
        return const MaterialPage(child: DatabasePage());
      }),
]);
