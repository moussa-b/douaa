import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/douaa.dart';
import '../models/sub_category.dart';
import '../providers/sub_category_provider.dart';
import '../providers/douaa_provider.dart';
import '../database/database_helper.dart';

class DouaaFormScreen extends ConsumerStatefulWidget {
  final int categoryId;
  final Douaa? douaa; // null = create mode, non-null = edit mode

  const DouaaFormScreen({
    super.key,
    required this.categoryId,
    this.douaa,
  });

  @override
  ConsumerState<DouaaFormScreen> createState() => _DouaaFormScreenState();
}

class _DouaaFormScreenState extends ConsumerState<DouaaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _arabicController;
  late final TextEditingController _frenchController;
  late final TextEditingController _referenceController;
  late final TextEditingController _tagsController;

  int? _selectedSubCategoryId;
  bool _saving = false;

  bool get _isEditing => widget.douaa != null;

  @override
  void initState() {
    super.initState();
    _arabicController = TextEditingController(text: widget.douaa?.douaaAr ?? '');
    _frenchController = TextEditingController(text: widget.douaa?.douaaFr ?? '');
    _referenceController =
        TextEditingController(text: widget.douaa?.reference ?? '');
    _tagsController = TextEditingController(text: widget.douaa?.tags ?? '');
    _selectedSubCategoryId = widget.douaa?.subCategoryId;
  }

  @override
  void dispose() {
    _arabicController.dispose();
    _frenchController.dispose();
    _referenceController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subCategoriesAsync =
        ref.watch(subCategoryListProvider(widget.categoryId));

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier l\'invocation' : 'Nouvelle invocation'),
        actions: [
          TextButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: const Text('Enregistrer'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Sub-category dropdown
            subCategoriesAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text('Erreur lors du chargement des sous-catégories : $error'),
              data: (subCategories) => _buildSubCategoryField(subCategories),
            ),

            const SizedBox(height: 16),

            // Arabic text (RTL, required)
            Directionality(
              textDirection: TextDirection.rtl,
              child: TextFormField(
                controller: _arabicController,
                decoration: const InputDecoration(
                  labelText: 'Texte arabe *',
                  hintText: 'Saisir l\'invocation en arabe',
                  alignLabelWithHint: true,
                ),
                textDirection: TextDirection.rtl,
                maxLines: 5,
                minLines: 3,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.8,
                  fontFamily: 'ScheherazadeNew',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le texte arabe est obligatoire';
                  }
                  return null;
                },
              ),
            ),

            const SizedBox(height: 16),

            // French translation
            TextFormField(
              controller: _frenchController,
              decoration: const InputDecoration(
                labelText: 'Traduction française',
                hintText: 'Saisir la traduction en français',
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              minLines: 2,
            ),

            const SizedBox(height: 16),

            // Reference
            TextFormField(
              controller: _referenceController,
              decoration: const InputDecoration(
                labelText: 'Référence',
                hintText: 'ex. Boukhari, Mouslim, Coran 2:255',
              ),
            ),

            const SizedBox(height: 16),

            // Tags
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Étiquettes',
                hintText: 'ex. matin, soir, prière',
              ),
            ),

            if (_isEditing) ...[
              const SizedBox(height: 48),
              OutlinedButton.icon(
                onPressed: _saving ? null : _showDeleteDouaaDialog,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Supprimer cette invocation'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                  side: BorderSide(color: Theme.of(context).colorScheme.error),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 32),
            ] else
              const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSubCategoryField(List<SubCategory> subCategories) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: DropdownButtonFormField<int?>(
            value: _selectedSubCategoryId,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Sous-catégorie',
            ),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('Aucune'),
              ),
              ...subCategories.map(
                (sc) => DropdownMenuItem<int?>(
                  value: sc.id,
                  child: Text(sc.name),
                ),
              ),
            ],
            onChanged: (value) {
              setState(() => _selectedSubCategoryId = value);
            },
          ),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: IconButton.filled(
            onPressed: () => _showAddSubCategoryDialog(),
            icon: const Icon(Icons.add),
            tooltip: 'Nouvelle sous-catégorie',
          ),
        ),
      ],
    );
  }

  Future<void> _showDeleteDouaaDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return AlertDialog(
          title: const Text('Supprimer l\'invocation'),
          content: const Text(
            'Supprimer cette invocation ? Cette action est irréversible.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
    if (confirm == true && mounted) {
      await ref
          .read(douaaListProvider(widget.categoryId).notifier)
          .deleteDouaa(widget.douaa!.id!);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  Future<void> _showAddSubCategoryDialog() async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => const _AddSubCategoryDialog(),
    );

    if (name != null && name.isNotEmpty) {
      final id = await ref
          .read(subCategoryListProvider(widget.categoryId).notifier)
          .addSubCategory(name);
      setState(() => _selectedSubCategoryId = id);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final db = DatabaseHelper();
      final douaa = Douaa(
        id: widget.douaa?.id,
        categoryId: widget.categoryId,
        subCategoryId: _selectedSubCategoryId,
        douaaAr: _arabicController.text.trim(),
        douaaFr: _frenchController.text.trim().isEmpty
            ? null
            : _frenchController.text.trim(),
        reference: _referenceController.text.trim().isEmpty
            ? null
            : _referenceController.text.trim(),
        tags: _tagsController.text.trim().isEmpty
            ? null
            : _tagsController.text.trim(),
        isFavorite: widget.douaa?.isFavorite ?? false,
      );

      if (_isEditing) {
        await db.updateDouaa(douaa);
      } else {
        await db.insertDouaa(douaa);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'enregistrement : $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}

class _AddSubCategoryDialog extends StatefulWidget {
  const _AddSubCategoryDialog();

  @override
  State<_AddSubCategoryDialog> createState() => _AddSubCategoryDialogState();
}

class _AddSubCategoryDialogState extends State<_AddSubCategoryDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouvelle sous-catégorie'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Nom de la sous-catégorie',
          hintText: 'Saisir le nom de la sous-catégorie',
        ),
        textCapitalization: TextCapitalization.sentences,
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            Navigator.of(context).pop(value.trim());
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () {
            final text = _controller.text.trim();
            if (text.isNotEmpty) {
              Navigator.of(context).pop(text);
            }
          },
          child: const Text('Ajouter'),
        ),
      ],
    );
  }
}
