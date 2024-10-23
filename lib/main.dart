import 'dart:math';
import 'package:flutter/material.dart';

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
      duration: const Duration(milliseconds: 16), // Frame-by-frame animation
      vsync: this,
    )..repeat();
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
  final AnimationController controller;
  late double leftPosition;
  late double topPosition;
  late double horizontalDirection;
  late double verticalDirection;

  Fish({required this.color, required this.speed, required this.controller}) {
    // Random start positions
    leftPosition = Random().nextDouble() * 250;
    topPosition = Random().nextDouble() * 250;

    // Random initial directions (-1 for left/up, 1 for right/down)
    horizontalDirection = Random().nextBool() ? 1 : -1;
    verticalDirection = Random().nextBool() ? 1 : -1;

    // Add listener to update fish position based on speed and direction
    controller.addListener(() {
      moveFish();
    });
  }

  // Update the fish position and bounce off edges
  void moveFish() {
    // Update positions based on speed and direction
    leftPosition += horizontalDirection * speed;
    topPosition += verticalDirection * speed;

    // Check for boundaries and reverse direction when hitting an edge
    if (leftPosition <= 0 || leftPosition >= 270) {  // 270 to keep within 300x300 container
      horizontalDirection *= -1;
    }
    if (topPosition <= 0 || topPosition >= 270) {
      verticalDirection *= -1;
    }
  }

  // Build the fish widget
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

void main() {
  runApp(MaterialApp(home: AquariumApp()));
}
