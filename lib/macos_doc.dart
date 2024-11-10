import 'package:flutter/material.dart';

class MacOsInspiredDoc extends StatefulWidget {
  const MacOsInspiredDoc({super.key});

  @override
  State<MacOsInspiredDoc> createState() => _MacOsInspiredDocState();
}

class _MacOsInspiredDocState extends State<MacOsInspiredDoc> {
  late int? hoveredIndex;
  late double baseItemHeight;
  late double baseTranslationY;
  late double verticalItemsPadding;

  String? draggedItem;

  double getTranslationY(int index) {
    return baseTranslationY;
  }

  double getIconPosition(int index) {
    if (draggedItem != null && hoveredIndex != null) {
      print("Fimil $draggedItem");
      print("Fimil $hoveredIndex");
      if (index > hoveredIndex!) {
        return -50.0;
      } else if (index < hoveredIndex!) {
        return 50.0;
      }
    }
    return 0.0; // Default position when draggedItem is not hovering or outside
  }

  double getDockWidth() {
    double baseDockWidth = baseItemHeight * items.length +
        verticalItemsPadding * (items.length + 1);

    if (draggedItem != null) {
      baseDockWidth *= 0.8;
    }

    return baseDockWidth;
  }

  @override
  void initState() {
    super.initState();
    hoveredIndex = null;
    baseItemHeight = 80;
    verticalItemsPadding = 20;
    baseTranslationY = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              height: baseItemHeight,
              left: 0,
              right: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: const LinearGradient(
                    colors: [Colors.blueAccent, Colors.greenAccent],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: verticalItemsPadding),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: getDockWidth(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(items.length, (index) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: DragTarget<String>(
                          onAcceptWithDetails: (details) {
                            setState(() {
                              items.remove(draggedItem);
                              items.insert(index, draggedItem!);
                              draggedItem = null;
                            });
                          },
                          builder: (context, candidateData, rejectedData) {
                            return Opacity(
                                opacity: candidateData.isNotEmpty ? 0.5 : 1.0,
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  onEnter: (event) {
                                    if (draggedItem != null) {
                                      setState(() {
                                        hoveredIndex =
                                            index; // Update hoveredIndex only when an item is being dragged
                                      });
                                    }
                                  },
                                  onExit: (event) {
                                    // Keep hoveredIndex unchanged, so the last hovered index stays
                                  },
                                  child: Draggable<String>(
                                    data: items[index],
                                    onDragStarted: () {
                                      setState(() {
                                        draggedItem = items[index];
                                      });
                                    },
                                    onDragUpdate: (details) {
                                      // Update hoveredIndex based on drag position
                                      setState(() {
                                        final itemWidth =
                                            MediaQuery.of(context).size.width /
                                                items.length;
                                        hoveredIndex =
                                            (details.localPosition.dx /
                                                    itemWidth)
                                                .floor();
                                      });
                                    },
                                    onDraggableCanceled: (velocity, offset) {
                                      setState(() {
                                        draggedItem = null;
                                      });
                                    },
                                    childWhenDragging: SizedBox(
                                      height: baseItemHeight,
                                      width: baseItemHeight,
                                    ),
                                    feedback: Material(
                                      color: Colors.transparent,
                                      child: Container(
                                        width: 80,
                                        height: 80,
                                        alignment: Alignment.center,
                                        child: Text(
                                          items[index],
                                          style: const TextStyle(fontSize: 40),
                                        ),
                                      ),
                                    ),
                                    child: AnimatedContainer(
                                      duration: const Duration(seconds: 1),
                                      transform: Matrix4.translationValues(
                                        getIconPosition(index),
                                        getTranslationY(index),
                                        0,
                                      ),
                                      child: FittedBox(
                                        fit: BoxFit.contain,
                                        child: Text(
                                          items[index],
                                          style: const TextStyle(
                                            fontSize: 40,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ));
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<String> items = [
  '📱', // Mobile Phone
  '💻', // Laptop
  '💾',
  '🔋', // Battery
  '⚙️', // Gear (Settings)
];