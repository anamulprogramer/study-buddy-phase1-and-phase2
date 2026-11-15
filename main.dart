// PHASE 2 - Provider state, CRUD, validation, local storage
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final theme = ThemeProvider(), auth = AuthProvider(), tasks = TaskProvider();
  await Future.wait([theme.load(), auth.load(), tasks.load()]);
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: theme),
      ChangeNotifierProvider.value(value: auth),
      ChangeNotifierProvider.value(value: tasks),
    ],
    child: const StudyBuddyApp(),
  ));
}

class StudyBuddyApp extends StatelessWidget {
  const StudyBuddyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'StudyBuddy',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        themeMode: context.watch<ThemeProvider>().mode,
        home: const Gate(),
      );
}
