import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fab_circular_menu_plus/fab_circular_menu_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:flutter_firebase_backend/cloud_firestore/firestore_helper.dart';

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

    // Setelah proses penambahan selesai, baca data lagi dan perbarui tampilan
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
    await db.collection("event_detail").doc(details[pos].id).update({'islike': !details[pos].is_like});
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
          return CheckboxListTile(
            onChanged: (bool? value) {
              updateEvent(position);
            },
            value: details[position].is_like,
            title: Text(details[position].judul),
            subtitle: Text(
              "${details[position].keterangan}\nHari : ${details[position].tanggal}\nPembicara : ${details[position].pembicara}",
            ),
            isThreeLine: false,
          );
        },
      ),
      floatingActionButton: FabCircularMenuPlus(
        children: <Widget>[
          IconButton(
            onPressed: () async {
              await addRand();
            },
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: () async {
              if (details.last.id != null) {
                await deleteLast(details.last.id!);
              }
            },
            icon: const Icon(Icons.minimize),
          )
        ],
      ),
    );
  }
}
