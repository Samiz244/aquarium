import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AquariumApp extends StatefulWidget {
  @override
  _AquariumAppState createState() => _AquariumAppState();
}

class _AquariumAppState extends State<AquariumApp> with SingleTickerProviderStateMixin {
  double fishSpeed = 1.0;
  Color selectedColor = Colors.blue;
  List<Fish> fishList = [];
  Random random = Random();
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 16),
      vsync: this,
    )..repeat();

    // Load settings from database on app launch
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final dbHelper = DatabaseHelper();
    final settings = await dbHelper.getSavedSettings(); // Use getSavedSettings
    if (settings != null) {
      setState(() {
        fishSpeed = settings['speed'] ?? 1.0;
        selectedColor = Color(int.parse(settings['color'] ?? Colors.blue.value.toString()));
        int fishCount = settings['fish_count'] ?? 0;
        for (int i = 0; i < fishCount; i++) {
          _addFish();
        }
      });
    }
  }

  Future<void> _saveSettings() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.insertSettings(fishList.length, fishSpeed, selectedColor.value.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Add new fish
  void _addFish() {
    setState(() {
      fishList.add(Fish(color: selectedColor, speed: fishSpeed, controller: _controller));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Virtual Aquarium"),
      ),
      body: Column(
        children: [
          // Aquarium Container (300x300)
          Container(
            height: 300,
            width: 300,
            decoration: BoxDecoration(
              color: Colors.lightBlueAccent,
              border: Border.all(color: Colors.blueAccent),
            ),
            child: Stack(
              children: fishList.map((fish) => fish.buildFish()).toList(),
            ),
          ),
          // Slider for fish speed
          Slider(
            value: fishSpeed,
            min: 0.5,
            max: 5.0,
            divisions: 10,
            label: "Speed: ${fishSpeed.toStringAsFixed(1)}",
            onChanged: (value) {
              setState(() {
                fishSpeed = value;
              });
            },
          ),
    DropdownButton<Color>(
  value: selectedColor, // Set the current selected color explicitly
  items: [
    DropdownMenuItem(child: Text("Blue"), value: Colors.blue),
    DropdownMenuItem(child: Text("Red"), value: Colors.red),
    DropdownMenuItem(child: Text("Green"), value: Colors.green), // Add green
  ],
  onChanged: (value) {
    setState(() {
      selectedColor = value!;
    });
  },
),
          // Buttons for adding fish and saving settings
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: _addFish,
                child: Text("Add Fish"),
              ),
              ElevatedButton(
                onPressed: _saveSettings, // Save settings when pressed
                child: Text("Save Settings"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Fish {
  final Color color;
  final double speed;
  final AnimationController controller;
  late double leftPosition;
  late double topPosition;
  late double horizontalDirection;
  late double verticalDirection;

  Fish({required this.color, required this.speed, required this.controller}) {
    leftPosition = Random().nextDouble() * 250;
    topPosition = Random().nextDouble() * 250;
    horizontalDirection = Random().nextBool() ? 1 : -1;
    verticalDirection = Random().nextBool() ? 1 : -1;

    controller.addListener(() {
      moveFish();
    });
  }

  void moveFish() {
    leftPosition += horizontalDirection * speed;
    topPosition += verticalDirection * speed;

    if (leftPosition <= 0 || leftPosition >= 270) {
      horizontalDirection *= -1;
    }
    if (topPosition <= 0 || topPosition >= 270) {
      verticalDirection *= -1;
    }
  }

  Widget buildFish() {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Positioned(
          left: leftPosition,
          top: topPosition,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
        );
      },
    );
  }
}

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'aquarium.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE settings(id INTEGER PRIMARY KEY, fish_count INTEGER, speed REAL, color TEXT)',
        );
      },
    );
  }

  Future<void> insertSettings(int fishCount, double speed, String color) async {
    final db = await database;
    await db.insert(
      'settings',
      {'fish_count': fishCount, 'speed': speed, 'color': color},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getSavedSettings() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('settings');
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }
}

void main() {
  runApp(MaterialApp(home: AquariumApp()));
}