import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
//import 'package:reciplus/theme.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

//Food API Key PyPubZ1ZrG4PfcyOWfua0Dh9yll9O6Y4X935eRoS

// void main() {
//   runApp(const MyApp());
// }

class Ingredient {
  String name = '';
  int count = 0;
  int kcal = 0;
  Ingredient(this.name);
  Ingredient.cal(this.name, this.kcal);
  void _setCalorie(int kcal) {
    this.kcal = kcal;
  }

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient.cal(json['foods'][0]['description'] as String,
        json['foods'][0]['foodNutrients'][3]['value'].toInt());
  }

  void reset() {
    name = '';
    kcal = 0;
    count = 0;
  }
}

class Recipe {
  String name = '';
  List<Ingredient> ingredients = [];
  int ingredientsCount = 0;
  int calories = 0;
  String id = '';
  Recipe(this.name);
  void _addIngredient(Ingredient ingredient) {
    ingredientsCount++;
    ingredients.add(ingredient);
  }

  void _removeIngredient(int index) {
    ingredients.removeAt(index);
    ingredientsCount--;
  }

  void _updateCalories() {
    calories = 0;
    for (int i = 0; i < ingredients.length; i++) {
      calories += ingredients[i].kcal;
    }
  }
}

List<Recipe> recipes = [];
int current = -1;
String barcode = 'Unknown';
Ingredient ingGlobal = Ingredient('');

//Main stateless widget
class MyApp2 extends StatelessWidget {
  const MyApp2({Key? key, required this.uid}) : super(key: key);

  final String uid;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text('Recipe List')),
      body: RecipeListPage(title: 'Recipe List', userid: uid),
    );
  }
}

//Recipe list home page
class RecipeListPage extends StatefulWidget {
  const RecipeListPage({Key? key, required this.title, required this.userid})
      : super(key: key);

  final String title;
  final String userid;

  @override
  _RecipeListPageState createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  TextEditingController recipeController = TextEditingController();
  CollectionReference? users;
  @override
  void initState() {
    getUserInfo();
    getRecipeList();
  }

  void updateRecipeList(querySnapshot) {
    recipes = [];
    querySnapshot.docs.forEach((doc) {
      Recipe rec = Recipe(doc["name"]);
      rec.id = doc.id;
      recipes.add(rec);
    });
    setState(() {});
  }

  Future<void> getRecipeList() {
    print('DEBUG: get recipe list');
    CollectionReference? recipes = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userid)
        .collection('recipes');
    return recipes.get().then((QuerySnapshot querySnapshot) {
      updateRecipeList(querySnapshot);
    }).catchError((error) => print('DEBUG: add recipe error: ${error}'));
  }

  Future<void> addRecipe(name) {
    print('DEBUG: add recipe');
    CollectionReference? recipes = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userid)
        .collection('recipes');
    return recipes
        .add({
          'name': name,
          'ingredients': ['egg', 'spinarch'],
        })
        .then((value) => getRecipeList())
        .catchError((error) => print('DEBUG: add recipe error: ${error}'));
  }

  Future<void> removeRecipe(index) {
    print('DEBUG: remove recipe');
    CollectionReference? recipesdb = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userid)
        .collection('recipes');
    return recipesdb
        .doc(recipes[index].id)
        .delete()
        .then((value) => getRecipeList())
        .catchError((error) => print('DEBUG: delete recipe error: ${error}'));
  }

  Future<void> addUser() {
    print('DEBUG: add user');
    CollectionReference? dbusers =
        FirebaseFirestore.instance.collection('users');
    // Call the user's CollectionReference to add a new user
    return dbusers
        .doc(widget.userid)
        .set({
          'owner': widget.userid, // John Doe
        })
        .then((value) => print('User added'))
        .catchError((error) => print('DEBUG: add user error: ${error}'));
  }

  Future<void> checkUserExists() {
    print('DEBUG: check user');
    CollectionReference? dbusers =
        FirebaseFirestore.instance.collection('users');
    // Call the user's CollectionReference to add a new user
    return dbusers
        .doc(widget.userid)
        .update({
          'owner': widget.userid, // John Doe
        })
        .then((value) => print("User exists"))
        .catchError((error) => {
              if (error.code == 'not-found') {addUser()}
            });
  }

  Future<void> getUserInfo() {
    print('DEBUG: get info');
    CollectionReference? dbusers =
        FirebaseFirestore.instance.collection('users');
    return dbusers
        .doc(widget.userid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        DocumentSnapshot? res = documentSnapshot;
        print('Document data: ${documentSnapshot.data()}');
        // _updateRecipeList(res.get('recipe_list'));
      } else {
        checkUserExists();
      }
    }).catchError((error) => print('DEBUG get info error: ${error}'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListView.builder(
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            return Card(
                child: ListTile(
              leading: const Icon(Icons.set_meal),
              onTap: () {
                current = index;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RecipePage()),
                );
                setState(() {
                  recipes[index]._updateCalories();
                });
              },
              title: Text(recipes[index].name),
              subtitle: Text(recipes[index].calories.toString()),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  removeRecipe(index);
                },
              ),
            ));
          }),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        tooltip: 'Add New Recipe',
        onPressed: () => showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('New Recipe Name'),
            content: TextField(
              controller: recipeController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Input Recipe Name',
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context, 'Cancel');
                  recipeController.clear();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    addRecipe(recipeController.text);
                  });
                  Navigator.pop(context);
                  recipeController.clear();
                  barcode = 'Unknown';
                },
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//Recipe page class
class RecipePage extends StatefulWidget {
  const RecipePage({Key? key}) : super(key: key);

  @override
  _RecipePageState createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  Recipe rec = recipes[current];
  bool isScanned = false;
  TextEditingController ingredientController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(rec.name)),
      body: ListView.builder(
          itemCount: rec.ingredientsCount,
          itemBuilder: (context, index) {
            return Card(
                child: ListTile(
              leading: const Icon(Icons.restaurant),
              onTap: () {
                showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Ingredient Calorie Count'),
                    content: TextField(
                      controller: ingredientController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Input Calorie Count',
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, 'Cancel');
                          ingredientController.clear();
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            rec.ingredients[index]._setCalorie(
                                int.parse(ingredientController.text));
                            Navigator.pop(context);
                            ingredientController.clear();
                            rec._updateCalories();
                          });
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              title: Text(rec.ingredients[index].name),
              subtitle: Text(rec.ingredients[index].kcal.toString()),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    rec._removeIngredient(index);
                  });
                },
              ),
            ));
          }),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          tooltip: 'Add New Ingredient',
          onPressed: () {
            barcode = 'Unknown';
            showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('New Ingredient'),
                content: TextField(
                  controller: ingredientController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Input Ingredient',
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, 'Cancel');
                      ingredientController.clear();
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const BarcodeScanPage()),
                      );
                      //barcode = result as String;
                      isScanned = true;
                      setState(() {
                        ingredientController.text = result.name;
                        ingGlobal = result;
                      });
                    },
                    child: const Text('Scan'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        if (isScanned) {
                          rec._addIngredient(ingGlobal);
                          isScanned = false;
                        } else {
                          Ingredient ing =
                              Ingredient(ingredientController.text);
                          rec._addIngredient(ing);
                        }
                        Navigator.pop(context, 'Ok');
                        ingredientController.clear();
                        //ingGlobal.reset();
                      });
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }),
    );
  }
}

//Barcode Scanner Code inspired by:
//https://github.com/JohannesMilke/barcode_scanner_example/blob/master/lib/page/barcode_scan_page.dart

class BarcodeScanPage extends StatefulWidget {
  const BarcodeScanPage({Key? key}) : super(key: key);
  @override
  _BarcodeScanPageState createState() => _BarcodeScanPageState();
}

class _BarcodeScanPageState extends State<BarcodeScanPage> {
  late Future<Ingredient> futureIng;
  Ingredient ing = Ingredient('');

  Future<Ingredient> getFoodData() async {
    final uri = Uri.parse(
        'https://api.nal.usda.gov/fdc/v1/foods/search?query=' +
            barcode +
            '&pageSize=1&Api_Key=PyPubZ1ZrG4PfcyOWfua0Dh9yll9O6Y4X935eRoS');
    print(uri);
    final response = await http.get(
      uri,
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      return Ingredient.fromJson(jsonDecode(response.body.toString()));
    } else {
      throw Exception('Failed to load data');
    }
  }

  void updateIngredient(Ingredient ing) {
    setState(() {
      ingGlobal = ing;
    });
  }
  // @override
  // void initState() {
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Scanner'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Scan Result',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.lightBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                ingGlobal.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue,
                ),
              ),
              const SizedBox(height: 72),
              TextButton(
                onPressed: () {
                  Future<Ingredient> temp = scanBarcode();
                  setState(() {
                    temp.then((ing) {
                      print(ing.name + ' ' + ing.kcal.toString());
                      updateIngredient(ing);
                    });
                  });
                },
                child: const Text('Start Barcode scan'),
              ),
              Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context, ingGlobal);
                    },
                    child: const Text("Done"),
                  ))
            ],
          ),
        ),
      );

  Future<Ingredient> scanBarcode() async {
    String bc;
    try {
      bc = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.BARCODE,
      );
    } on PlatformException {
      bc = 'Failed to get platform version.';
    }

    if (!mounted) {
      throw Exception('Failed to mount');
    } else {
      setState(() => barcode = bc.toString());
      print(barcode);
      return getFoodData();
    }
  }
}
