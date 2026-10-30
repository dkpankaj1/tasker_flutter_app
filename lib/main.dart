import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasker/database/database_helper.dart';
import 'package:tasker/providers/task_provider.dart';
import 'package:tasker/repositories/task_repository.dart';
import 'package:tasker/routes/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final AppRouter appRoute = AppRouter();
    return ChangeNotifierProvider(
      create: (context) {
        final repository = TaskRepository(DatabaseHelper.instance);

        return TaskProvider(repository)..loadTasks();
      },
      child: MaterialApp.router(
        title: 'Task App',
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
        debugShowCheckedModeBanner: false,
        routerConfig: appRoute.router,
      ),
    );
  }
}
