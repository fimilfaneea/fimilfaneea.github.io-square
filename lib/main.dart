import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final List<IconData> icons = [
    Icons.person,
    Icons.message,
    Icons.call,
    Icons.camera,
    Icons.file_copy_sharp,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const SizedBox.shrink(),
      ),
      body: Center(
        child: Dock(
          items: icons,
          onReorder: _onReorder,
        ),
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = icons.removeAt(oldIndex);
      icons.insert(newIndex, item);
    });
  }
}

class Dock extends StatefulWidget {
  const Dock({
    super.key,
    required this.items,
    required this.onReorder,
  });

  final List<IconData> items;
  final Function(int, int) onReorder;

  @override
  DockState createState() => DockState();
}

class DockState extends State<Dock> {
  late List<IconData> _items;
  late Map<String, List<Offset>> _itemPositionsMap;
  Offset? _draggingPosition;
  int? _draggingIndex;
  final List<Offset> _dockPositions = [
    const Offset(0, 100),
    const Offset(75, 100),
    const Offset(150, 100),
    const Offset(225, 100),
    const Offset(300, 100),
  ];

  @override
  void initState() {
    super.initState();
    _items = [
      Icons.abc,
      Icons.book,
      Icons.call,
      Icons.delete,
      Icons.egg,
    ];
    _itemPositionsMap = {
      'a': [const Offset(0, 100)],
      'b': [const Offset(75, 100)],
      'c': [const Offset(150, 100)],
      'd': [const Offset(225, 100)],
      'e': [const Offset(300, 100)],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      child: Stack(
        children: [
          ...List.generate(
            _items.length,
            (index) {
              return AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                left: _itemPositionsMap.containsKey(_getItemKey(index))
                    ? _itemPositionsMap[_getItemKey(index)]![0].dx
                    : 0.0,
                top: _itemPositionsMap.containsKey(_getItemKey(index))
                    ? _itemPositionsMap[_getItemKey(index)]![0].dy
                    : 100.0,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _draggingIndex ??= index;
                      _draggingPosition = details.localPosition;
                    });
                  },
                  onPanEnd: (_) {
                    setState(() {
                      if (_draggingPosition != null) {
                        final newIndex =
                            _getClosestDockPosition(_draggingPosition!);
                        final movedItem = _items.removeAt(_draggingIndex!);
                        _items.insert(newIndex, movedItem);
                        _shiftIcons(newIndex);
                        _draggingPosition = null;
                        _draggingIndex = null;
                      }
                    });
                  },
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.primaries[index % Colors.primaries.length],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        _items[index], // Use the _items list to get the icon
                        color: Colors.white,
                        size: 30, // Adjust size as needed
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          if (_draggingPosition != null && _draggingIndex != null)
            Positioned(
              left: _draggingPosition!.dx - 30,
              top: _draggingPosition!.dy - 30,
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors
                      .primaries[_draggingIndex! % Colors.primaries.length],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(_items[_draggingIndex!], color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getItemKey(int index) {
    return String.fromCharCode(97 + index);
  }

  int _getClosestDockPosition(Offset position) {
    double minDistance = double.infinity;
    int closestIndex = 0;

    for (int i = 0; i < _dockPositions.length; i++) {
      double distance = (position.dx - _dockPositions[i].dx).abs() +
          (position.dy - _dockPositions[i].dy).abs();
      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = i;
      }
    }

    return closestIndex;
  }

  void _shiftIcons(int newIndex) {
    if (_draggingIndex != null && _draggingPosition != null) {
      final oldIndex = _draggingIndex!;
      final draggedKey = _getItemKey(oldIndex);

      final keys = _itemPositionsMap.keys.toList();
      keys.removeAt(oldIndex);
      keys.insert(newIndex, draggedKey);

      for (int i = 0; i < keys.length; i++) {
        final key = keys[i];
        _itemPositionsMap[key] = [Offset(i * 75.0, 100.0)];
      }

      setState(() {});
    }
  }
}
