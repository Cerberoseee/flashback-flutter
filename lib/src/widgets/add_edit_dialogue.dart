import 'package:flutter/material.dart';

class AddEditWidget extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController, descriptionController;

  const AddEditWidget({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.descriptionController,
  });

  @override
  State<StatefulWidget> createState() => _AddEditState();
}

class _AddEditState extends State<AddEditWidget> {
  late GlobalKey<FormState> _formKey;
  late TextEditingController _topicNameController, _topicDescController;

  @override
  void initState() {
    super.initState();
    _formKey = widget.formKey;
    _topicNameController = widget.nameController;
    _topicDescController = widget.descriptionController;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Topic name",
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
          const SizedBox(height: 4),
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter folder name';
              }
              return null;
            },
            controller: _topicNameController,
            decoration: const InputDecoration(
              labelStyle: TextStyle(
                color: Colors.white,
              ),
              border: OutlineInputBorder(),
              hintText: 'Enter name',
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Topic description (Optional)",
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: _topicDescController,
            decoration: const InputDecoration(
              labelStyle: TextStyle(
                color: Colors.white,
              ),
              border: OutlineInputBorder(),
              hintText: 'Enter description (optional)',
            ),
            maxLines: 4,
            minLines: 4,
          ),
        ],
      ),
    );
  }
}
