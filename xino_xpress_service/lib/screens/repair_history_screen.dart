import 'package:flutter/material.dart';
import 'package:xino_xpress_service/services/database_service.dart';
import '../models/repair.dart';
//import '../services/database_service.dart';
import '../widgets/repair_list_item.dart';

class RepairHistoryScreen extends StatelessWidget {
  final String clientId;

  RepairHistoryScreen({required this.clientId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Repair History'),
      ),
      body: StreamBuilder<List<Repair>>(
        stream: DatabaseService().getRepairs(clientId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView(
            children: snapshot.data!
                .map((repair) => RepairListItem(repair: repair))
                .toList(),
          );
        },
      ),
    );
  }
}
