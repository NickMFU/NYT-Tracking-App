import 'package:flutter/material.dart';
import 'package:namyong_demo/screen/Dashboard.dart';
import 'package:namyong_demo/screen/CreateWork.dart';
import 'package:namyong_demo/screen/Notification.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool hasNotification; 
  // Add a boolean to indicate if there is a new notification

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.hasNotification = false, // Initialize with a default value
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      margin: const EdgeInsets.only(left: 12, right: 12, bottom: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(40)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(40)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < 3; i++) ...<Widget>{
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    onTap(i);
                    _navigateToPage(context, i);
                  },
                  child: Container(
                    height: 70,
                    color: Colors.white,
                    child: Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (i == 1) // Check if it's the 'CreateWork' item
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color.fromARGB(255, 4, 6, 126),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              if (i != 1) // If it's not the 'CreateWork' item, show regular icon
                                Icon(
                                  i == 0 ? Icons.home : Icons.notifications,
                                  color: i == currentIndex ? Color.fromARGB(255, 4, 6, 126) : Colors.black54,
                                  size: i == currentIndex ? 30 : 26,
                                ),
                              if (i != 1 && i == currentIndex)
                                Container(
                                  margin: const EdgeInsets.only(top: 6),
                                  height: 3,
                                  width: 22,
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(40)),
                                    color: Color.fromARGB(255, 4, 6, 126),
                                  ),
                                ),
                            ],
                          ),
                          if (i == 2 && hasNotification) // Show red dot above notification icon
                            Positioned(
                              top: 8,
                              right: 20,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            },
          ],
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Dashboard()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CreateWorkPage()));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AcceptWorkPage()));
        break;
      default:
        break;
    }
  }
}
