import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/repositories/user_repository_impl.dart';
import '../providers/profile_provider.dart';

class IdVerificationScreen extends ConsumerStatefulWidget {
  const IdVerificationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<IdVerificationScreen> createState() => _IdVerificationScreenState();
}

class _IdVerificationScreenState extends ConsumerState<IdVerificationScreen> {
  String? _selectedIdType;
  File? _idFrontFile;
  File? _idBackFile;
  File? _selfieFile;
  bool _isLoading = false;

  final List<String> _idTypes = [
    'South African ID Smart Card',
    'South African ID Book (Green)',
    'Passport',
    'Driver\'s License',
  ];

  Future<void> _pickImage(String type) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: type == 'selfie' ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        if (type == 'front') _idFrontFile = File(pickedFile.path);
        if (type == 'back') _idBackFile = File(pickedFile.path);
        if (type == 'selfie') _selfieFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submit() async {
    if (_selectedIdType == null || _idFrontFile == null || _selfieFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required steps')),
      );
      return;
    }

    if (_selectedIdType == 'South African ID Smart Card' && _idBackFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Smart Card requires back side image')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(userRepositoryProvider);
      
      // 1. Upload images
      final frontUrl = await repo.uploadVerificationDoc(
        bytes: await _idFrontFile!.readAsBytes(),
        fileName: 'id_front.jpg',
      );

      String? backUrl;
      if (_idBackFile != null) {
        backUrl = await repo.uploadVerificationDoc(
          bytes: await _idBackFile!.readAsBytes(),
          fileName: 'id_back.jpg',
        );
      }

      final selfieUrl = await repo.uploadVerificationDoc(
        bytes: await _selfieFile!.readAsBytes(),
        fileName: 'selfie.jpg',
      );

      // 2. Submit request
      await repo.submitVerification(
        idType: _selectedIdType!,
        idFrontUrl: frontUrl,
        idBackUrl: backUrl,
        selfieUrl: selfieUrl,
      );

      // 3. Refresh profile
      ref.invalidate(profileProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification submitted! Our team will review it within 24-48 hours.')),
        );
        context.pop(); // Back to Verification Center
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        title: const Text('Identity Verification'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Step 1: Select ID Type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedIdType,
              dropdownColor: AppColors.surface,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Choose document type',
              ),
              items: _idTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
              onChanged: (val) => setState(() => _selectedIdType = val),
            ),
            const SizedBox(height: 32),

            const Text(
              'Step 2: Upload Documents',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            _buildUploadCard(
              title: 'Front of Document',
              file: _idFrontFile,
              onTap: () => _pickImage('front'),
            ),
            if (_selectedIdType == 'South African ID Smart Card') ...[
              const SizedBox(height: 16),
              _buildUploadCard(
                title: 'Back of Document',
                file: _idBackFile,
                onTap: () => _pickImage('back'),
              ),
            ],
            const SizedBox(height: 32),

            const Text(
              'Step 3: Liveness Check',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Take a clear selfie holding your document next to your face (optional but recommended) or just a clear face shot.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            _buildUploadCard(
              title: 'Take a Selfie',
              file: _selfieFile,
              onTap: () => _pickImage('selfie'),
              isCamera: true,
            ),

            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                  ? const CircularProgressIndicator(color: AppColors.darkBg)
                  : const Text('Submit for Review'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadCard({
    required String title,
    required File? file,
    required VoidCallback onTap,
    bool isCamera = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor, style: BorderStyle.solid),
        ),
        child: file != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(file, fit: BoxFit.cover),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isCamera ? Icons.camera_alt_outlined : Icons.add_photo_alternate_outlined, color: AppColors.primary),
                const SizedBox(height: 8),
                Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              ],
            ),
      ),
    );
  }
}
