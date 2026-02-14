import 'package:flutter/material.dart';

class AddCategoryDialog extends StatefulWidget {
  const AddCategoryDialog({super.key});

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Category'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Category name',
            hintText: 'Enter category name',
          ),
          textCapitalization: TextCapitalization.sentences,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a name';
            }
            return null;
          },
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(_controller.text.trim());
    }
  }
}
