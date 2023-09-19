import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logic_app/providers/Providers.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
          automaticallyImplyLeading: false,
        ),
        body: SettingsList(
          sections: [
            SettingsSection(title: const Text("Common"), tiles: <SettingsTile>[
              SettingsTile(title: const Text("User Account")),
              SettingsTile.switchTile(
                title: const Text("Dark mode"),
                initialValue: ref.watch(darkModeProvider).initialValue,
                onToggle: (value) {
                  ref.watch(darkModeProvider).onTap(value); //每次按下toggle之后会自动改变value的值
                },
              ),
              SettingsTile(title: const Text("Contact us")),
              SettingsTile.navigation(
                title: const Text("Database"),
                onPressed: (value) async {
                  context.pushNamed("database");
                },
              )
            ]),
          ],
        ));
  }
}
