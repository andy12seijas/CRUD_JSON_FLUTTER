import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRUD Photos App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue, // Color principal azul
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const PhotosScreen(),
    );
  }
}

class PhotosScreen extends StatefulWidget {
  const PhotosScreen({super.key});

  @override
  State<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends State<PhotosScreen> {
  List<dynamic> photos = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  bool isEditing = false;
  int? editingIndex;

  @override
  void initState() {
    super.initState();
    fetchPhotos();
  }

  Future<void> fetchPhotos() async {
    final response = await http
        .get(Uri.parse('https://jsonplaceholder.typicode.com/photos'));
    if (response.statusCode == 200) {
      setState(() {
        photos = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load photos');
    }
  }

  Future<void> _postPhoto() async {
    final response = await http.post(
      Uri.parse('https://jsonplaceholder.typicode.com/photos'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        "albumId": 1,
        "title": _titleController.text,
        "url": _urlController.text,
        "thumbnailUrl": _urlController.text,
      }),
    );

    if (response.statusCode == 201) {
      final newPhoto = json.decode(response.body);
      setState(() {
        photos.insert(0, newPhoto);
      });
    } else {
      throw Exception('Failed to post photo');
    }
  }

  void _addPhoto() {
    _postPhoto();
    _clearForm();
  }

  void _editPhoto(int index) {
    setState(() {
      isEditing = true;
      editingIndex = index;
      _titleController.text = photos[index]['title'];
      _urlController.text = photos[index]['url'];
    });
  }

  void _updatePhoto() {
    setState(() {
      photos[editingIndex!]['title'] = _titleController.text;
      photos[editingIndex!]['url'] = _urlController.text;
      photos[editingIndex!]['thumbnailUrl'] = _urlController.text;
    });
    _clearForm();
  }

  void _deletePhoto(int index) {
    setState(() {
      photos.removeAt(index);
    });
  }

  void _clearForm() {
    _titleController.clear();
    _urlController.clear();
    isEditing = false;
    editingIndex = null;
  }

  void _showFormDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Editar Foto' : 'Añadir Foto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'URL de la imagen',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearForm();
              },
              child:
                  const Text('Cancelar', style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () {
                if (isEditing) {
                  _updatePhoto();
                } else {
                  _addPhoto();
                }
                Navigator.of(context).pop();
              },
              child: Text(
                isEditing ? 'Actualizar' : 'Añadir',
                style: const TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FOTOS', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: photos.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Scrollbar(
              child: ListView.builder(
                itemCount: photos.take(10).length,
                itemBuilder: (context, index) {
                  final photo = photos.take(10).toList()[index];
                  return Card(
                    margin: const EdgeInsets.all(8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ID: ${photo['id']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue[100]!),
                            ),
                            child: Text(
                              photo['title'],
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  _editPhoto(index);
                                  _showFormDialog();
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deletePhoto(index),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showFormDialog,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
