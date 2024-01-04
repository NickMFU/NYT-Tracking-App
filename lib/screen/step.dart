import 'package:flutter/material.dart';
import 'package:namyong_demo/screen/CreateWork.dart';

class StatusStepperDemo extends StatefulWidget {
  StatusStepperDemo() : super();

  final String title = "Status Stepper Demo";

  @override
  StatusStepperDemoState createState() => StatusStepperDemoState();
}

class StatusStepperDemoState extends State<StatusStepperDemo> {
  int currentStep = 0;

  List<Step> steps = [
    Step(
      title: Text('Assigned'),
      content: Text('Task assigned to a user.'),
      isActive: true,
    ),
    Step(
      title: Text('During Checker Survey'),
      content: Text('Survey in progress by a checker.'),
      isActive: true,
    ),
    Step(
      title: Text('Load to Tractor'),
      content: Text('Loading the task onto a tractor.'),
      isActive: true,
    ),
    Step(
      title: Text('During Gate Out Confirm'),
      content: Text('Confirmation during gate out.'),
      isActive: true,
    ),
    Step(
      title: Text('Product Release Complete'),
      content: Text('Product release process completed.'),
      isActive: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: 16.0),
            Image.asset(
              'assets/images/1.jpg', // Replace 'your_image.png' with the actual image path
              height: 100, // Adjust the height as needed
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 16.0),
            Text(
              "Current Status: ${steps[currentStep].title}",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: Stepper(
                currentStep: currentStep,
                steps: steps,
                type: StepperType.vertical,
                onStepTapped: (step) {
                  setState(() {
                    currentStep = step;
                  });
                },
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: currentStep > 0
                      ? () {
                          setState(() {
                            currentStep--;
                          });
                        }
                      : null,
                  child: Text("Back"),
                ),
                ElevatedButton(
                  onPressed: currentStep < steps.length - 1
                      ? () {
                          setState(() {
                            currentStep++;
                          });
                        }
                      : null,
                  child: Text("Continue"),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Implement Cancel functionality here
                  },
                  child: Text("Cancel"),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Navigate to WorkDetailScreen and pass workData
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateWorkPage(),
                  ),
                );
              },
              child: Text("View Details"),
            ),
          ],
        ),
      ),
    );
  }
}
