import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_anime_list_gemini/models/bookmark_container_model.dart';
import 'package:my_anime_list_gemini/providers/bookmark_provider.dart';
import 'package:provider/provider.dart';
// Import providers and models
// import '../providers/bookmark_provider.dart'; // Path might need adjustment
// import '../models/bookmark_container_model.dart'; // Path might need adjustment

class AddEditBookmarkContainerScreen extends StatefulWidget {
  final BookmarkContainerModel? container; // Null if adding new

  AddEditBookmarkContainerScreen({this.container});

  @override
  _AddEditBookmarkContainerScreenState createState() => _AddEditBookmarkContainerScreenState();
}

class _AddEditBookmarkContainerScreenState extends State<AddEditBookmarkContainerScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.container?.name ?? '');
    // If editing and there's an existing logo, we don't pre-fill _imageFile
    // as it's for new selections. The existing path is handled by provider.
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source, imageQuality: 70, maxWidth: 500);
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
        });
      }
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil gambar: $e')),
      );
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  leading: Icon(Icons.photo_library_rounded),
                  title: Text('Galeri'),
                  onTap: () {
                    _pickImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  }),
              ListTile(
                leading: Icon(Icons.photo_camera_rounded),
                title: Text('Kamera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final bookmarkProvider = Provider.of<BookmarkProvider>(context, listen: false);

      if (widget.container == null) { // Adding new
        bookmarkProvider.addContainer(name, _imageFile).then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Wadah "$name" berhasil dibuat!')),
          );
          Navigator.of(context).pop();
        }).catchError((error) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal membuat wadah: $error')),
          );
        });
      } else { // Editing existing
        bookmarkProvider.updateContainer(widget.container!.id!, name, _imageFile, widget.container!.logoPath).then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Wadah "$name" berhasil diperbarui!')),
          );
          Navigator.of(context).pop();
        }).catchError((error) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memperbarui wadah: $error')),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.container == null ? 'Buat Wadah Baru' : 'Edit Wadah'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              GestureDetector(
                onTap: () => _showImageSourceActionSheet(context),
                child: Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[600]!, width: 1),
                  ),
                  alignment: Alignment.center,
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(File(_imageFile!.path), width: 150, height: 150, fit: BoxFit.cover))
                      : (widget.container?.logoPath != null && widget.container!.logoPath!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(File(widget.container!.logoPath!), width: 150, height: 150, fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.add_a_photo_rounded, size: 50, color: Colors.white54);
                                },
                              ))
                          : Icon(Icons.add_a_photo_rounded, size: 50, color: Colors.white54)),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Ketuk di atas untuk memilih logo',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Wadah',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: Colors.grey[700],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama wadah tidak boleh kosong';
                  }
                  return null;
                },
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submit,
                child: Text(widget.container == null ? 'Buat Wadah' : 'Simpan Perubahan'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}