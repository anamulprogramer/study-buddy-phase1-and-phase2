// PHASE 1 + 2 - UI screen that uses Provider state
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../models/app_user.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common.dart';

class VerifyScreen extends StatefulWidget {
  final AppUser user;
  const VerifyScreen({super.key, required this.user});
  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  File? _file;
  bool _busy = false;

  Future<void> _pick() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (x == null) return;
    final f = File(x.path);
    if (await f.length() > 5 * 1024 * 1024) {
      if (mounted) snack(context, 'File is larger than 5MB');
      return;
    }
    setState(() => _file = f);
  }

  Future<void> _submit() async {
    if (_file == null) return snack(context, 'Choose your ID card first');
    final auth = context.read<AuthProvider>();
    setState(() => _busy = true);
    try {
      await auth.uploadId(widget.user.uid, _file!);
    } catch (e) {
      if (mounted) snack(context, authError(e));
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AuthBackground(
        showBack: false,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const SizedBox(height: 20),
          const AuthHeader(icon: Icons.badge, title: 'Verify Your Identity', subtitle: 'Upload your Student/Teacher ID'),
          InkWell(
            onTap: _pick,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 190,
              decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary2, width: 2),
                  borderRadius: BorderRadius.circular(20),
                  color: cardColor(context)),
              child: _file != null
                  ? ClipRRect(borderRadius: BorderRadius.circular(18), child: Image.file(_file!, fit: BoxFit.cover, width: double.infinity))
                  : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.cloud_upload, size: 52, color: AppColors.primary),
                      SizedBox(height: 8),
                      Text('Upload ID Card', style: TextStyle(fontWeight: FontWeight.w700)),
                      Text('JPG, PNG (Max 5MB)', style: TextStyle(fontSize: 12)),
                    ]),
            ),
          ),
          const SizedBox(height: 18),
          GradientButton(label: 'Submit', onTap: _submit, loading: _busy),
          TextButton(
              onPressed: () => context.read<AuthProvider>().skipId(widget.user.uid),
              child: const Text('You can skip for now')),
        ]),
      );
}
