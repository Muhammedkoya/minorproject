// ignore_for_file: unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class SearchList extends StatefulWidget {
  const SearchList({super.key});

  @override
  State<SearchList> createState() => _SearchState();
}

class _SearchState extends State<SearchList> {
  final CollectionReference player =
      FirebaseFirestore.instance.collection('player');

  final CollectionReference team =
      FirebaseFirestore.instance.collection('team');

  String name = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 12, 105, 181),
        title: Card(
          child: TextField(
            decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search), hintText: 'Search'),
            onChanged: (value) {
              setState(() {
                name = value;
              });
            },
          ),
        ),
      ),
      body: StreamBuilder(
        stream: Rx.combineLatest2(
          player.orderBy('name').snapshots(),
          team.orderBy('name').snapshots(),
          (QuerySnapshot playerSnapshot, QuerySnapshot teamSnapshot) {
            // Combine the data from both snapshots
            List<QueryDocumentSnapshot> allDocs = [];
            allDocs.addAll(playerSnapshot.docs);
            allDocs.addAll(teamSnapshot.docs);

            // Create a new QuerySnapshot with the combined documents
            return QuerySnapshot(
              allDocs: allDocs,
              size: allDocs.length,
              metadata: SnapshotMetadata(hasPendingWrites: false),
              //empty: allDocs.isEmpty,
            );
          },
        ),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var playerSnap =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;

                return !playerSnap['name']
                            .toString()
                            .toLowerCase()
                            .contains(name.toLowerCase()) &&
                        name.isNotEmpty
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                              boxShadow: const [
                                BoxShadow(
                                    color: Color.fromARGB(255, 209, 208, 208),
                                    blurRadius: 10,
                                    spreadRadius: 15),
                              ]),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      playerSnap['name'],
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      playerSnap['nationality'],
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  child: CircleAvatar(
                                    backgroundColor:
                                        const Color.fromARGB(255, 26, 118, 193),
                                    radius: 30,
                                    child: Text(
                                      playerSnap['age'].toString(),
                                      style: const TextStyle(fontSize: 25),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
              },
            );
          }
          return Container();
        },
      ),
    );
  }
}
