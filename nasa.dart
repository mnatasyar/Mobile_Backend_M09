import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fab_circular_menu_plus/fab_circular_menu_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:flutter_firebase_backend/cloud_firestore/firestore_helper.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

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

  Future testData() async {
    await Firebase.initializeApp();
    print('init done');
    FirebaseFirestore db = FirebaseFirestore.instance;
    print('init Firestore Done');

    var data = await db.collection('event_detail').get().then((event) {
      for (var doc in event.docs) {
        print("${doc.id} => ${doc.data()}");
      }
    });
  }

  Future readData() async {
    await Firebase.initializeApp();
    FirebaseFirestore db = FirebaseFirestore.instance;
    var data = await db.collection('event_detail').get();
    setState(() {
      details = data.docs.map((doc) => EventModel.fromDocSnapshot(doc)).toList();
    });
  }

  Future<void> showDeleteConfirmationDialog(String documentId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Apakah Anda yakin ingin menghapus item ini?'),
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
              child: const Text('Hapus'),
              onPressed: () async {
                Navigator.of(context).pop();
                await deleteItem(documentId);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteItem(String documentId) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db.collection("event_detail").doc(documentId).delete();

    setState(() {
      details.removeWhere((element) => element.id == documentId);
    });
  }

  addRand() async {
    await Firebase.initializeApp();
    FirebaseFirestore db = FirebaseFirestore.instance;
    String getRandString(int len) {
      var random = Random.secure();
      var values = List<int>.generate(len, (i) => random.nextInt(255));
      return base64UrlEncode(values);
    }

    EventModel insertData = EventModel(
      judul: getRandString(5),
      keterangan: getRandString(30),
      tanggal: getRandString(10),
      is_like: Random().nextBool(),
      pembicara: getRandString(20),
    );

    await db.collection("event_detail").add(insertData.toMap());

    await readData();
  }

  deleteLast(String documentId) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db.collection("event_detail").doc(documentId).delete();
    setState(() {
      details.removeLast();
    });
  }

  updateEvent(int pos) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db.collection("event_detail").doc(details[pos].id).update({'is_like': !details[pos].is_like});
    setState(() {
      details[pos].is_like = !details[pos].is_like;
    });
  }

  @override
  Widget build(BuildContext context) {
    testData();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cloud Firestore"),
      ),
      body: ListView.builder(
        itemCount: (details != null) ? details.length : 0,
        itemBuilder: (context, position) {
          return ListTile(
            onTap: () {
              showEditDialog(details[position]);
            },
            title: Text(details[position].judul),
            subtitle: Text(
              "${details[position].keterangan}\nHari : ${details[position].tanggal}\nPembicara : ${details[position].pembicara}",
            ),
            trailing: Checkbox(
              onChanged: (bool? value) {
                updateEvent(position);
              },
              value: details[position].is_like,
            ),
          );
        },
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.menu,
        children: [
          SpeedDialChild(
            child: Icon(Icons.add),
            label: 'Tambah',
            onTap: () async {
              await addRand();
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.minimize),
            label: 'Hapus Terakhir',
            onTap: () async {
              if (details.isNotEmpty) {
                await showDeleteConfirmationDialog(details.last.id!);
              }
            },
          ),
        ],
      ),
    );
  }
  Future<void> showEditDialog(EventModel event) async {
    TextEditingController judulController = TextEditingController(text: event.judul);
    TextEditingController keteranganController = TextEditingController(text: event.keterangan);
    TextEditingController tanggalController = TextEditingController(text: event.tanggal);
    TextEditingController pembicaraController = TextEditingController(text: event.pembicara);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Item'),
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
              child: const Text('Hapus'),
              onPressed: () async {
                await deleteItemOnList(event);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Simpan'),
              onPressed: () async {
                event.judul = judulController.text;
                event.keterangan = keteranganController.text;
                event.tanggal = tanggalController.text;
                event.pembicara = pembicaraController.text;

                await updateItem(event);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> updateItem(EventModel event) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db.collection("event_detail").doc(event.id).update(event.toMap());
  }

 List<EventModel> deletedItems = [];

  void restoreItem(EventModel deletedItem) {
    setState(() {
      details.add(deletedItem);
      deletedItems.remove(deletedItem);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Item ${deletedItem.judul} dikembalikan'),
      ),
    );
  }

  Future<void> deleteItemOnList(EventModel event) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db.collection("event_detail").doc(event.id).delete();

    setState(() {
      details.removeWhere((item) => item.id == event.id);
      deletedItems.add(event);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Item ${event.judul} dihapus'),
        action: SnackBarAction(
          label: 'Batalkan',
          onPressed: () {
            restoreItem(event);
          },
        ),
      ),
    );
  }
}
