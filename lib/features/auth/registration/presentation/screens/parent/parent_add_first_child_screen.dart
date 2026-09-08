import 'package:flutter/material.dart';
import 'package:kids_transport/features/parent/children/presentation/screens/add_child_screen.dart';

class ParentAddFirstChildScreen extends StatelessWidget {
  const ParentAddFirstChildScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AddChildScreen(isFirstChildMandatory: true);
  }
}
