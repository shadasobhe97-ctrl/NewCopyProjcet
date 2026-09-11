import 'package:flutter/material.dart';
import '../../data/models/child_model.dart';
import 'add_child_screen.dart';

class AddChildStep1Screen extends StatelessWidget {
  final ChildModel? child;
  const AddChildStep1Screen({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return AddChildScreen(childToEdit: child);
  }
}
