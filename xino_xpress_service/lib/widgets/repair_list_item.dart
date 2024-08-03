import 'package:flutter/material.dart';
import '../models/repair.dart';
import '../utils/helpers.dart';

class RepairListItem extends StatelessWidget {
  final Repair repair;

  RepairListItem({required this.repair});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(repair.description),
      subtitle: Text(
          'Cost: \$${repair.cost} - Date: ${formatDateTime(repair.submissionDate)}'),
    );
  }
}
