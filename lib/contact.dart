import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactPage extends StatelessWidget {
  final Contact contact;
  const ContactPage(this.contact, {super.key});

  // Function to delete the contact
  void deleteContact() async {
    await contact.delete();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(contact.displayName)),
    body: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('First name: ${contact.name.first}'),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Last name: ${contact.name.last}'),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
              'Phone number: ${contact.phones.isNotEmpty ? contact.phones.first.number : '(none)'}'),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
              'Email address: ${contact.emails.isNotEmpty ? contact.emails.first.address : '(none)'}'),
        ),
        Center(child: Flexible(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
            ),
            child: const Text(
              'Remove Contact',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () {
              // Delete contact
              deleteContact();
              Navigator.pop(context);
              ScaffoldMessenger.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(const SnackBar(
                  content: Text("Contact deleted"),
                  duration: Duration(seconds: 1, milliseconds: 100)
              ));
            },
          ),
        ),
        )
      ]),
    ));
}

class AddContactPage extends StatefulWidget {
  const AddContactPage({super.key});

  @override
  State<AddContactPage> createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNumController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  File? imageFile;

  Future<void> submitContact() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final contact = Contact()
      ..name.first = firstNameController.text
      ..name.last = lastNameController.text
      ..phones = [Phone(phoneNumController.text)]
      ..emails = [Email(emailController.text)];
    await contact.insert();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Contact')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const CameraExample(),
              const SizedBox(height: 20),
              TextFormField(
                controller: firstNameController,
                decoration: const InputDecoration(
                  labelText: "First Name",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a first name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: lastNameController,
                decoration: const InputDecoration(
                  labelText: "Last Name",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a last name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: phoneNumController,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Center(child: Flexible(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                  ),
                  child: const Text(
                    'Add Contact',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    // Check if all fields are valid
                    if (_formKey.currentState!.validate()) {
                      submitContact();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context)
                          ..removeCurrentSnackBar()
                          ..showSnackBar(const SnackBar(
                          content: Text("Contact added"),
                          duration: Duration(seconds: 1, milliseconds: 100)
                      ));
                    } else {
                      ScaffoldMessenger.of(context)
                          ..removeCurrentSnackBar()
                          ..showSnackBar(const SnackBar(
                          content: Text("Please fill in all fields"),
                          duration: Duration(seconds: 1, milliseconds: 100)
                      ));
                    }
                  },
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

// Adds a camera widget to the form, code block from sample code
class CameraExample extends StatefulWidget {
  const CameraExample({super.key});

  @override
  State<CameraExample> createState() => _CameraExampleState();
}

class _CameraExampleState extends State<CameraExample> {
  Permission permission = Permission.camera;
  PermissionStatus permissionStatus = PermissionStatus.denied;
  File? imageFile;

  @override
  void initState() {
    super.initState();
    _listenForPermissionStatus();
  }

  void _listenForPermissionStatus() async {
    final status = await permission.status;
    setState(() => permissionStatus = status);
  }

  Future<void> _pickImage() async {
    if (permissionStatus.isGranted) {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      setState(() {
        imageFile = image == null ? null : File(image.path);
      });
    } else {
      final status = await permission.request();
      setState(() {
        permissionStatus = status;
      });
      if (status.isGranted) {
        _pickImage();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: imageFile == null
      ? CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey,
          child: IconButton(
            icon: const Icon(Icons.add_a_photo, color: Colors.white),
            onPressed: _pickImage,
          ),
        )
      : CircleAvatar(
          radius: 50,
          backgroundImage: FileImage(imageFile!),
        ),
    );
  }
}