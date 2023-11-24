import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

// Model EventModel dan fungsi toMap
class EventModel {
  String? id;
  String judul;
  String keterangan;
  String tanggal;
  bool is_like;
  String pembicara;

  EventModel({
    this.id,
    required this.judul,
    required this.keterangan,
    required this.tanggal,
    required this.is_like,
    required this.pembicara,
  });

  Map<String, dynamic> toMap() {
    return {
      'Judul': judul,
      'Keterangan': keterangan,
      'Pembicara': pembicara,
      'is_like': is_like,
      'tanggal': tanggal,
    };
  }

  EventModel.fromDocSnapshot(DocumentSnapshot<Map<String, dynamic>> doc)
      : id = doc.id,
        judul = doc.data()?['Judul'],
        keterangan = doc.data()?['Keterangan'],
        pembicara = doc.data()?['Pembicara'],
        is_like = doc.data()?['is_like'],
        tanggal = doc.data()?['tanggal'];
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHome(),
    );
  }
}

class MyHome extends StatefulWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  List<EventModel> details = [];

  @override
  void initState() {
    readData();
    super.initState();
  }

  // ... Bagian-bagian lainnya sama seperti sebelumnya

  Future<void> addData() async {
    TextEditingController judulController = TextEditingController();
    TextEditingController keteranganController = TextEditingController();
    TextEditingController tanggalController = TextEditingController();
    TextEditingController pembicaraController = TextEditingController();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tambah Item Baru'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: judulController,
                  decoration: const InputDecoration(labelText: 'Judul'),
                ),
                TextFormField(
                  controller: keteranganController,
                  decoration: const InputDecoration(labelText: 'Keterangan'),
                ),
                TextFormField(
                  controller: tanggalController,
                  decoration: const InputDecoration(labelText: 'Tanggal'),
                ),
                TextFormField(
                  controller: pembicaraController,
                  decoration: const InputDecoration(labelText: 'Pembicara'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Tambah'),
              onPressed: () async {
                EventModel newEvent = EventModel(
                  judul: judulController.text,
                  keterangan: keteranganController.text,
                  tanggal: tanggalController.text,
                  pembicara: pembicaraController.text,
                  is_like: false, // Default value for 'is_like'
                );

                await addNewItem(newEvent);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> addNewItem(EventModel event) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db.collection("event_detail").add(event.toMap());

    setState(() {
      details.add(event);
    });
  }

  // ... Bagian-bagian lainnya sama seperti sebelumnya

  @override
  Widget build(BuildContext context) {
    // ... Bagian build() sama seperti sebelumnya
  }
}
