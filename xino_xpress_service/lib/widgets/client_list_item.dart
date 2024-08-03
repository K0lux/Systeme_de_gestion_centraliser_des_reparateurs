import 'package:flutter/material.dart';
import '../models/client.dart';
import '../screens/client_details_screen.dart';

class ClientListItem extends StatelessWidget {
  final Client client;

  ClientListItem({required this.client});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(client.name),
      subtitle: Text(client.issueDescription),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClientDetailsScreen(client: client),
          ),
        );
      },
    );
  }
}
