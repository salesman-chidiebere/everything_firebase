import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp().whenComplete(() =>
    print("Firebase has been initialized!!!"));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Everything Firestore'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final firestoreInstance = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection("users").snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                if (!snapshot.hasData){
                  return Center(
                    child: CircularProgressIndicator()
                  );
                }

                return Container(
                  height: MediaQuery.of(context).size.height/ 2,
                  width: MediaQuery.of(context).size.width,
                  child: ListView(
                    children: snapshot.data.docs.map((snap) {
                      return Card(
                        child: ListTile(
                          //leading: Text(snap['age'].toString()),
                          leading: Icon(Icons.edit),
                          title: Text(snap['name'].toString()),
                          subtitle: Text(snap['email'].toString()),
                          trailing: Icon(Icons.delete),
                        ),
                      );
                    }).toList()
                  ),
                );
              },
            ),
            SizedBox(height: 30,),
            ElevatedButton(
                onPressed: retrieveDocUsingCondition,
                child: Text("Execute Command")),

          ],
        ),
      ),
    );
  }

  //final firestoreInstance = FirebaseFirestore.instance;

  void updatevalue () {
    firestoreInstance.collection("users").doc("BzGnwYaPZV7l6bFtltww").update({
     "characterristics" : FieldValue.arrayUnion(["generous", "loving", "loyal"])

    }).then((value) {
      print("Data Added successfully");
    });
  }

  void addSubCollections(){
    firestoreInstance.collection("users").add({
      "name" : "Maria",
      "age" : 24,
      "email" : "maria@gmail.com",
      "address" : {"street": "street 24", "city" : "Lagos"}
    }).then ((value){
      print(value.id);
      firestoreInstance.collection("users")
        .doc(value.id)
        .collection("pets")
        .add({"petName": "blacky", "petType" : "dog", "petAge" : 1});
    });
  }

  void deleteDoc(){
    firestoreInstance.collection("users").doc("Zlwiq3xHfW2o7E0qX3xS").delete()
        .then((_){
          print("delete successful!");
    });
  }

  void deleteField(){
    firestoreInstance.collection("users").doc("Zlwiq3xHfW2o7E0qX3xS").update({
      "username" : FieldValue.delete()
    }).then((value) => print("Field deleted Successfully!"));
  }

  void retrieveOnce(){
    firestoreInstance.collection("users").get().then((value) => {
      value.docs.forEach((result){
      print(result.data());
    })
    });
  }

  Future<AsyncSnapshot<QuerySnapshot>> retrieveSubCol(){
    firestoreInstance.collection("users").get().then((value){
      value.docs.forEach((result){
        firestoreInstance.collection("users")
            .doc(result.id)
            .collection("pets")
            .snapshots();
            //.get()
            //.then((subcol){
              //subcol.docs.forEach((element) {
                //print(element.data());
              //});
        });
      });
    //});
  }

  void retrieveDocUsingCondition(){
    firestoreInstance.collection("users").where("age", isEqualTo: 24)
        .get().then((value) => {
          value.docs.forEach((element) {
            print(element.id);
            print(element.data());
          })
    });
  }

}
