import 'dart:ui';

import 'package:descktop/app_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'user_item_list.dart';

class AdminMenu extends StatelessWidget {
  const AdminMenu({super.key});

  @override
  Widget build(BuildContext context) {
    var appData = Provider.of<AppData>(context);

    return (Scaffold(
        appBar: AppBar(
          title: const Text('ImagIA CPP'),
          backgroundColor: Colors.deepPurple,
          elevation: 0,
        ),
        body: ScaffoldMessenger(
            key: GlobalKey<ScaffoldMessengerState>(),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(255, 182, 154, 230),
                    Color.fromARGB(255, 146, 154, 201)
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                      child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Save Changes'),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: 600,
                        height: 500,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListView(
                          children: <Widget>[
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Text("ID"),
                                SizedBox(width: 10),
                                Text("Name"),
                                SizedBox(width: 10),
                                Text("Premium"),
                              ],
                            ),
                            for (var user in appData.users)
                              UserItemList(
                                id: user["id"],
                                name: user['name'],
                                isPremium: user['isPremium'],
                                onPremiumChanged: (value) {
                                  user["isPremium"] = value;
                                  if (appData.changes.contains(user)) {
                                    appData.changes.remove(user);
                                  } else {
                                    appData.changes.add(user);
                                  }
                                  appData.forcenotify();
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                  ))
                ],
              ),
            ))));
  }
}
