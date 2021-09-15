import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:reciplus/theme.dart';
import 'package:flutter/services.dart';

// void main() {
//   runApp(const MyApp());
// }

class Ingredient {
  String name = '';
  int count = 0;
  int kcal = 0;
  Ingredient(this.name);
}

class Recipe {
  String name = '';
  List<Ingredient> ingredients = [];
  int ingredientsCount = 0;
  Recipe(this.name);
  void _addIngredient(String ingredient) {
    ingredientsCount++;
    Ingredient ing = Ingredient(ingredient);
    ingredients.add(ing);
  }

  void _removeIngredient(int index) {
    ingredients.removeAt(index);
    ingredientsCount--;
  }
}

List<Recipe> recipes = [];
int current = -1;
String barcode = 'Unknown';

//Main stateless widget
class MyApp2 extends StatelessWidget {
  const MyApp2({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: primarySwatchColor,
      ),
      home: const RecipeListPage(title: 'Recipe List'),
    );
  }
}

//Recipe list home page
class RecipeListPage extends StatefulWidget {
  const RecipeListPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _RecipeListPageState createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  TextEditingController recipeController = TextEditingController();

  void _addRecipe() {
    setState(() {
      Recipe rec = Recipe(recipeController.text);
      recipes.add(rec);
      Navigator.pop(context);
      recipeController.clear();
    });
  }

  void _removeRecipe(int index) {
    setState(() {
      recipes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), actions: <Widget>[
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.add),
        )
      ]),
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
              },
              title: Text(recipes[index].name),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  _removeRecipe(index);
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
                onPressed: () => _addRecipe(),
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
              onTap: () {},
              title: Text(rec.ingredients[index].name),
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
        onPressed: () => showDialog<String>(
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const BarcodeScanPage()),
                  );
                  setState(() {
                    ingredientController.text = barcode;
                  });
                },
                child: const Text('Scan'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    rec._addIngredient(ingredientController.text);
                    Navigator.pop(context);
                    ingredientController.clear();
                  });
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

//Barcode Scanner Code inspired by:
//https://github.com/JohannesMilke/barcode_scanner_example/blob/master/lib/page/barcode_scan_page.dart

class BarcodeScanPage extends StatefulWidget {
  const BarcodeScanPage({Key? key}) : super(key: key);

  @override
  _BarcodeScanPageState createState() => _BarcodeScanPageState();
}

class _BarcodeScanPageState extends State<BarcodeScanPage> {
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
                barcode,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue,
                ),
              ),
              const SizedBox(height: 72),
              TextButton(
                onPressed: scanBarcode,
                child: const Text('Start Barcode scan'),
              ),
              Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Done"),
                  ))
            ],
          ),
        ),
      );

  Future<void> scanBarcode() async {
    try {
      final bc = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.BARCODE,
      );

      if (!mounted) return;

      setState(() {
        barcode = bc;
      });
    } on PlatformException {
      barcode = 'Failed to get platform version.';
    }
  }
}
