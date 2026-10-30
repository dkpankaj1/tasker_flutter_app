import 'package:go_router/go_router.dart';
import 'package:tasker/screens/dashboard/dashboard.dart';
import 'package:tasker/screens/tasks/create.dart';
import 'package:tasker/screens/tasks/edit.dart';
import 'package:tasker/screens/tasks/list.dart';
import 'package:tasker/screens/tasks/show.dart';

class AppRouter {
  late final GoRouter router = GoRouter(
    initialLocation: "/",
    routes: [
      GoRoute(path: "/", builder: (context, state) => Dashboard()),
      GoRoute(path: "/tasks", builder: (context, state) => TaskList()),
      GoRoute(path: "/tasks/create", builder: (context, state) => TaskCreate()),
      GoRoute(
        path: "/tasks/:id/edit",
        builder: (context, state) => TaskEdit(taskId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: "/tasks/:id/show",
        builder: (context, state) => TaskShow(taskId: int.parse(state.pathParameters['id']!)),
      ),
    ],
  );
}
