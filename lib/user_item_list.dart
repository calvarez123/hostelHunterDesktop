import 'package:flutter/material.dart';

class UserItemList extends StatelessWidget {
  final String id;
  final String name;
  bool isPremium;
  final Function(bool?)? onPremiumChanged;

  UserItemList({
    required this.id,
    required this.name,
    this.isPremium = false,
    this.onPremiumChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text(id, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          Text(name),
          const SizedBox(width: 10),
          Checkbox(
            value: isPremium,
            onChanged: onPremiumChanged,
          ),
        ],
      ),
    );
  }
}