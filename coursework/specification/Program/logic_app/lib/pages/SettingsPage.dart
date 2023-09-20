import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logic_app/providers/Providers.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int timerMaximum = ref.watch(timerMaximumProvider.notifier).state;
    var inputText = ref.watch(inputTextProvider);

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
              SettingsTile(
                title: const Text("Timer Maximum: /s"),
                trailing: SizedBox(
                  width: 60,
                  height: 30,
                  child: TextField(
                    style: const TextStyle(color: Colors.teal),
                    textAlign: TextAlign.center,
                    controller: inputText,
                    keyboardType: TextInputType.number,

                    /// input validation
                    onChanged: (value) {
                      if (value.isEmpty) {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Can't be empty!"),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(context, "Confirm"), child: const Text("Confirm"))
                                ],
                              );
                            });
                      } else if ((int.tryParse(value) == null)) {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Input must be an integer."),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(context, "Confirm"), child: const Text("Confirm"))
                                ],
                              );
                            });
                      } else {
                        ref.read(timerMaximumProvider.notifier).state = int.parse(inputText.text) * 10;
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "${timerMaximum / 10}",
                      hintStyle: const TextStyle(color: Colors.teal),
                      contentPadding: EdgeInsets.zero,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              SettingsTile.navigation(
                title: const Text("Database"),
                onPressed: (value) async {
                  context.pushNamed("database");
                },
              ),
              SettingsTile(
                title: const Text("Contact us"),
                description: const Text("st181247@stud.uni-stuttgart.de"),
                ),
            ]),
          ],
        ));
  }
}
