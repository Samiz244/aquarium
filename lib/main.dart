import 'dart:math';
import 'package:flutter/material.dart';

class AquariumApp extends StatefulWidget {
  @override
  _AquariumAppState createState() => _AquariumAppState();
}

class _AquariumAppState extends State<AquariumApp> {
  double fishSpeed = 1.0;
  Color selectedColor = Colors.blue;
  List<Fish> fishList = [];
  Random random = Random();

  // Add new fish
  void _addFish() {
    setState(() {
      fishList.add(Fish(color: selectedColor, speed: fishSpeed));
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
              children: fishList.map((fish) => fish.buildFish(random)).toList(),
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
          // Dropdown for selecting fish color
          DropdownButton<Color>(
            value: selectedColor,
            items: [
              DropdownMenuItem(child: Text("Blue"), value: Colors.blue),
              DropdownMenuItem(child: Text("Red"), value: Colors.red),
              DropdownMenuItem(child: Text("Green"), value: Colors.green),
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
                onPressed: () {},
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
  double leftPosition;
  double topPosition;

  Fish({required this.color, required this.speed})
      : leftPosition = 0.0,
        topPosition = 0.0;

  // Randomize fish movement
  void randomizePosition(Random random) {
    leftPosition = random.nextDouble() * 250; // Keep within 300x300 container bounds
    topPosition = random.nextDouble() * 250;
  }

  // Fish as a moving colored circle
  Widget buildFish(Random random) {
    randomizePosition(random);
    return AnimatedPositioned(
      duration: Duration(milliseconds: (5000 / speed).round()),
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
  }
}

void main() {
  runApp(MaterialApp(home: AquariumApp()));
}
