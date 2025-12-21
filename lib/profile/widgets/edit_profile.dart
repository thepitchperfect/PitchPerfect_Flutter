import 'package:flutter/material.dart';
import '../models/profile_models.dart';

class EditProfileModal extends StatefulWidget {
  final Profile user;
  final Function(String name, String email, String pic) onSave;

  const EditProfileModal({super.key, required this.user, required this.onSave});

  @override
  State<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal> {
  final _formKey = GlobalKey<FormState>();
  late String newName;
  late String newEmail;
  late String? newPic;

  @override
  void initState() {
    super.initState();
    newName = widget.user.fullName;
    newEmail = widget.user.email;
    newPic = widget.user.profpict;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      title: const Text(
        "Edit Profile",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: newPic,
                decoration: const InputDecoration(
                  labelText: "Profile Picture URL",
                  border: OutlineInputBorder(),
                  hintText: "http://example.com/image.jpg",
                ),
                onSaved: (val) => newPic = val ?? "",
              ),
              const SizedBox(height: 16),

              TextFormField(
                initialValue: widget.user.username,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFFF3F4F6),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                initialValue: newName,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val!.isEmpty ? "Name cannot be empty" : null,
                onSaved: (val) => newName = val ?? "",
              ),
              const SizedBox(height: 16),

              TextFormField(
                initialValue: newEmail,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val!.isEmpty ? "Email cannot be empty" : null,
                onSaved: (val) => newEmail = val ?? "",
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
        ),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFE8800),
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              
              widget.onSave(newName, newEmail, newPic ?? "");
            }
          },
          child: const Text("Save Edit"),
        ),
      ],
    );
  }
}
