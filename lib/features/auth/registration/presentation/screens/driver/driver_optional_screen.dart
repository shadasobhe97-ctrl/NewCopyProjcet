import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../logic/register_cubit.dart';
import '../../../logic/register_state.dart';

class DriverOptionalScreen extends StatefulWidget {
  const DriverOptionalScreen({super.key});

  @override
  State<DriverOptionalScreen> createState() => _DriverOptionalScreenState();
}

class _DriverOptionalScreenState extends State<DriverOptionalScreen> {
  File? _imageFile;
  final _altPhoneController = TextEditingController();

  void _submit() {
    final cubit = context.read<RegisterCubit>();
    cubit.avatarFile = _imageFile;
    cubit.alternativePhone = _altPhoneController.text.trim().isEmpty ? null : _altPhoneController.text.trim();
    cubit.registerDriverFirstStage(); // استدعاء الدالة 1 محاكاة السيرفر
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: BlocConsumer<RegisterCubit, RegisterState>(
        listener: (context, state) {
          if (state is DriverRegisterFirstStageSuccess) {
            Navigator.pushNamed(context, '/driverOtp');
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text("الصورة والهاتف البديل", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.right),
                const SizedBox(height: 40),
                Center(
                  child: GestureDetector(
                    onTap: () async {
                      final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 60);
                      if (file != null) setState(() => _imageFile = File(file.path));
                    },
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                      child: _imageFile == null ? const Icon(Icons.camera_alt, size: 40) : null,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _altPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: "رقم هاتف احتياطي (اختياري)"),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: state is DriverRegisterFirstStageLoading ? null : _submit,
                  child: state is DriverRegisterFirstStageLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text("إنشاء الحساب المبدئي"),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}