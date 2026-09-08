import 'package:flutter/material.dart';
import '../../data/models/child_model.dart';
import 'add_child_screen.dart';

class AddChildStep2Screen extends StatelessWidget {
  final bool isDirectEdit;
  final ChildModel? child;

  const AddChildStep2Screen({
    super.key,
    this.isDirectEdit = false,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AddChildScreen(childToEdit: child);
  }
}
