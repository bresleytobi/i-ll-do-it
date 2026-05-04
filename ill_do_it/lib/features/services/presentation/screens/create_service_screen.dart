import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/supabase_service.dart';
import '../providers/services_provider.dart';

class CreateServiceScreen extends ConsumerStatefulWidget {
  const CreateServiceScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateServiceScreen> createState() => _CreateServiceScreenState();
}

class _CreateServiceScreenState extends ConsumerState<CreateServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _deliveryTimeController;
  String _selectedCategory = 'Graphic Design';

  final List<String> _categories = [
    'Graphic Design',
    'Web Development',
    'Tutoring',
    'Video Editing',
    'CV Writing',
    'Photography',
    'Social Media Help',
    'AI Services',
    'Music & Audio',
    'Tech Support',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _priceController = TextEditingController();
    _deliveryTimeController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _deliveryTimeController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (_formKey.currentState!.validate()) {
      final currentUser = ref.read(supabaseServiceProvider).currentUser;
      if (currentUser == null) return;

      final data = {
        'user_id': currentUser.id,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'price': double.parse(_priceController.text),
        'delivery_time': int.parse(_deliveryTimeController.text),
        'is_active': true,
      };

      await ref.read(serviceNotifierProvider.notifier).createService(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(serviceNotifierProvider);

    ref.listen<ServiceState>(serviceNotifierProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      } else if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service created successfully!')),
        );
        context.pop();
        ref.read(serviceNotifierProvider.notifier).reset();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        title: const Text('Create Service'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Service Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'e.g., I will design a professional logo',
                  labelText: 'Service Title',
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Describe what you offer in detail...',
                  labelText: 'Description',
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                ),
                dropdownColor: AppColors.surface,
                items: _categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat, style: const TextStyle(color: AppColors.textPrimary)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Price & Delivery Time
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: '0.00',
                        labelText: 'Price (R)',
                        prefixText: 'R ',
                      ),
                      validator: (value) =>
                          value == null || double.tryParse(value) == null
                              ? 'Invalid price'
                              : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _deliveryTimeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: '3',
                        labelText: 'Delivery (Days)',
                      ),
                      validator: (value) =>
                          value == null || int.tryParse(value) == null
                              ? 'Invalid days'
                              : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Create Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : _handleCreate,
                  child: state.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Publish Service'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
