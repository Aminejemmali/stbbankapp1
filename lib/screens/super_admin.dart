// ignore_for_file: use_key_in_widget_constructors, await_only_futures, avoid_print, prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stbbankapplication1/models/Utilisateur.dart';

class super_admin extends StatefulWidget {
  const super_admin({Key? key});

  @override
  State<super_admin> createState() => super_adminState();
}

class super_adminState extends State<super_admin> {
  //Getting the users filtered by role admin
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Utilisateur> filteredUsers = [];
  Future<List<Utilisateur>> getUsersByRole(String role) async {
    List<Utilisateur> users = [];
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: role)
          .get();
      querySnapshot.docs.forEach((doc) {
        users.add(Utilisateur(
          uid: doc.id,
          nom: doc['nom'],
          prenom: doc['prenom'],
          role: doc['role'],
        ));
      });
      setState(() {
        this.filteredUsers = users;
      });
    } catch (e) {
      print('Error getting users by role: $e');
    }
    return users;
  }

  initState() {
    super.initState();
    getUsersByRole("admin");
  }

  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  /*QuerySnapshot querySnapshot =  FirebaseFirestore
          .collection('users')
          .where('role', isEqualTo: role)
          .get();*/

  //final FirebaseAuth _auth = FirebaseAuth.instance;

  String searchQuery = '';
  bool isSearchBarOpen = false;

  Future<void> deleteUser(String userId) async {
    /*try {
      final user = await _auth.currentUser;
      if (user != null) {
        await user.delete();
      }
    } catch (e) {
      print("Error deleting user from Firebase Authentication: $e");
    }*/

    await usersCollection.doc(userId).delete();

  }

  /*Future<void> editUser(String userId) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditUserScreen(userId: userId),
      ),
    );
  }*/

  void toggleSearchBar() {
    setState(() {
      isSearchBarOpen = !isSearchBarOpen;
      if (!isSearchBarOpen) {
        // Reset search query when closing search bar
        searchQuery = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: isSearchBarOpen
            ? TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Rechercher par nom',
                  hintStyle: TextStyle(color: Colors.white70),
                ),
              )
            : const Text('Liste des Utilisateurs'),
        leading: isSearchBarOpen
            ? IconButton(
                icon: Icon(Icons.close),
                color: const Color.fromARGB(255, 20, 17, 17),
                onPressed: toggleSearchBar,
              )
            : IconButton(
                icon: Icon(Icons.arrow_back),
                color: const Color.fromARGB(255, 20, 17, 17),
                onPressed: () async {
                  Navigator.of(context).pushReplacementNamed('HomeScreen');
                },
              ),
        actions: [
          IconButton(
            icon: Icon(isSearchBarOpen ? Icons.search : Icons.search_outlined),
            onPressed: toggleSearchBar,
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: usersCollection.snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }
            final users = snapshot.data?.docs;

            // Filtrer les utilisateurs en fonction de la recherche
            final filteredUsers = users!
                .where((userDocument) =>
                    (userDocument.data() as Map<String, dynamic>)['nom']
                        .toString()
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()))
                .toList();

            return DataTable(
                columnSpacing: 40, // Ajustez cette valeur selon vos besoins
                columns: const [
                  DataColumn(label: Text('Nom')),
                  DataColumn(label: Text('Prénom')),
                  DataColumn(label: Text('Rôle')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: this
                    .filteredUsers
                    .map((user) => DataRow(cells: [
                          DataCell(Text(user.nom.toString())),
                          DataCell(Text(user.prenom)),
                          DataCell(Text(user.role)),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    //editUser(userId);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(
                                              'Supprimer cet utilisateur?'),
                                          actions: <Widget>[
                                            TextButton(
                                              child: Text('Annuler'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            TextButton(
                                              child: Text('Supprimer'),
                                              onPressed: () async {
                                                await deleteUser(user.uid);
                                                Navigator.of(context).pop();
                                                initState() {
                                                  super.initState();
                                                }
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ]))
                    .toList());
            /*filteredUsers.map((userDocument) {
                final user = userDocument.data() as Map<String, dynamic>;
                final userId = userDocument.id;

                return DataRow(
                  cells: [
                    DataCell(Text(user['nom'].toString())),
                    DataCell(Text(user['prenom'])),
                    DataCell(Text(user['role'])),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              //editUser(userId);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Supprimer cet utilisateur?'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text('Annuler'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: Text('Supprimer'),
                                        onPressed: () async {
                                          await deleteUser(userId);
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            );*/
          },
        ),
      ),
    );
  }
}
