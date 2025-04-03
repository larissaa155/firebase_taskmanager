import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() {
  runApp(InventoryApp());
}

class InventoryApp extends StatelessWidget {
  const InventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory Management App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: InventoryHomePage(),
    );
  }
}

class InventoryHomePage extends StatefulWidget {
  const InventoryHomePage({super.key});

  @override
  _InventoryHomePageState createState() => _InventoryHomePageState();
}

class _InventoryHomePageState extends State<InventoryHomePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  final CollectionReference inventory =
      FirebaseFirestore.instance.collection('inventory');

  void _addItem() {
    if (_nameController.text.isNotEmpty && _quantityController.text.isNotEmpty) {
      inventory.add({
        'name': _nameController.text,
        'quantity': int.parse(_quantityController.text),
      });
      _nameController.clear();
      _quantityController.clear();
    }
  }

  void _updateItem(String id, String name, int quantity) {
    _nameController.text = name;
    _quantityController.text = quantity.toString();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Item'),
        content: Column(
          children: [
            TextField(controller: _nameController, decoration: InputDecoration(hintText: 'Name')),
            TextField(controller: _quantityController, decoration: InputDecoration(hintText: 'Quantity')),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              inventory.doc(id).update({
                'name': _nameController.text,
                'quantity': int.parse(_quantityController.text),
              });
              _nameController.clear();
              _quantityController.clear();
              Navigator.pop(context);
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void _deleteItem(String id) {
    inventory.doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inventory Management')),
      body: StreamBuilder(
        stream: inventory.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return ListTile(
                title: Text(doc['name']),
                subtitle: Text('Quantity: ${doc['quantity']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _updateItem(doc.id, doc['name'], doc['quantity']),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteItem(doc.id),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        child: Icon(Icons.add),
      ),
    );
  }
}
