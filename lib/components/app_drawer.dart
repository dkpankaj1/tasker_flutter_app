import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.symmetric(vertical: 10),
        children: [
          DrawerHeader(child: Text("Welcome")),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text("Dashboard"),
            onTap: () => context.go('/'),
          ),
          ListTile(
            leading: Icon(Icons.task),
            title: Text("All Tasks"),
            onTap: () => context.go('/tasks'),
          ),
          ListTile(
            leading: Icon(Icons.add),
            title: Text("Create Tasks"),
            onTap: () => context.go('/tasks/create'),
          ),
        ],
      ),
    );
  }
}
