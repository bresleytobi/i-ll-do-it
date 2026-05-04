import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/supabase_service.dart';
import '../providers/jobs_provider.dart';

class CreateJobScreen extends ConsumerStatefulWidget {
  const CreateJobScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends ConsumerState<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _budgetController;
  DateTime? _selectedDeadline;
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
    _budgetController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _selectDeadline(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.darkBg,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDeadline) {
      setState(() {
        _selectedDeadline = picked;
      });
    }
  }

  Future<void> _handleCreate() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDeadline == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a deadline')),
        );
        return;
      }

      final currentUser = ref.read(supabaseServiceProvider).currentUser;
      if (currentUser == null) return;

      final data = {
        'client_id': currentUser.id,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'budget': double.parse(_budgetController.text),
        'deadline': _selectedDeadline!.toIso8601String(),
        'status': 'open',
      };

      await ref.read(jobNotifierProvider.notifier).createJob(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(jobNotifierProvider);

    ref.listen<JobState>(jobNotifierProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      } else if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job posted successfully!')),
        );
        context.pop();
        ref.read(jobNotifierProvider.notifier).reset();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        title: const Text('Post a Job'),
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
                'Job Details',
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
                  hintText: 'e.g., Need a logo for my bakery',
                  labelText: 'Job Title',
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
                  hintText: 'Describe what you need done...',
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

              // Budget & Deadline
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _budgetController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: '0.00',
                        labelText: 'Budget (R)',
                        prefixText: 'R ',
                      ),
                      validator: (value) =>
                          value == null || double.tryParse(value) == null
                              ? 'Invalid budget'
                              : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDeadline(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Deadline',
                        ),
                        child: Text(
                          _selectedDeadline == null
                              ? 'Select Date'
                              : DateFormat('MMM dd, yyyy').format(_selectedDeadline!),
                          style: TextStyle(
                            color: _selectedDeadline == null
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Post Button
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
                      : const Text('Post Job'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
