// screens/client_details_screen.dart
import 'package:flutter/material.dart';
import '../models/client.dart';
import 'repair_details_screen.dart';

class ClientDetailsScreen extends StatelessWidget {
  final Client client;

  ClientDetailsScreen({required this.client});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(client.name),
      ),
      body: Column(
        children: [
          Text('Phone: ${client.phone}'),
          if (client.photoUrl != null) Image.network(client.photoUrl!),
          ElevatedButton(
            child: Text('Add Repair'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      RepairDetailsScreen(clientId: client.id),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
