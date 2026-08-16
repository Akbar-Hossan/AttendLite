import 'package:flutter/material.dart';
import '../models/attendance.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  // Temporary data (later this will come from Django)
  final List<Attendance> attendanceList = [
    Attendance(date: DateTime(2026, 8, 13), isPresent: true),
    Attendance(date: DateTime(2026, 8, 12), isPresent: false),
    Attendance(date: DateTime(2026, 8, 11), isPresent: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AttendLite'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column( 
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Attendance marked')),
                  );
                },
                child: const Text('Mark Present'),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Recent Attendance',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: attendanceList.length,
                itemBuilder: (context, index) {
                  final attendance = attendanceList[index];

                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: Text(
                        '${attendance.date.day}/${attendance.date.month}/${attendance.date.year}',
                      ),
                      trailing: Text(
                        attendance.isPresent ? 'Present' : 'Absent',
                        style: TextStyle(
                          color: attendance.isPresent
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}