List<dynamic> packages = [
  {
    'name': 'code 10 with 10 lessons',
    'price': 3000,
    'sale_price': 2500,
    'image': 'assets/images/code10.jpg',
    'description': 'This package includes 10 lessons and a code 10 license',
  },
  {
    'name': 'code 8 with 10 lessons',
    'price': 3000,
    'sale_price': 2500,
    'image': 'assets/images/code8.jpg',
    'description': 'This package includes 10 lessons and a code 8 license',
  },
  {
    'name': 'code 14 with 10 lessons',
    'price': 3000,
    'sale_price': 2500,
    'image': 'assets/images/code14.jpg',
    'description': 'This package includes 10 lessons and a code 14 license',
  },
  {
    'name': 'code 10 with 20 lessons',
    'price': 6000,
    'sale_price': 5000,
    'image': 'assets/images/code10.jpg',
    'description': 'This package includes 20 lessons and a code 10 license',
  },
  {
    'name': 'code 8 with 20 lessons',
    'price': 6000,
    'sale_price': 5000,
    'image': 'assets/images/code8.jpg',
    'description': 'This package includes 20 lessons and a code 8 license',
  },
  {
    'name': 'code 14 with 20 lessons',
    'price': 6000,
    'sale_price': 5000,
    'image': 'assets/images/code14.jpg',
    'description': 'This package includes 20 lessons and a code 14 license',
  }
];

// Map of time slots to driving schools
Map<String, String> drivingSchools = {
  '8:00': '522 Tembisa Ivory Driving School',
  '9:00': '522 Tembisa Ivory Driving School',
  '10:00': '522 Pretoria Driving School',
  '11:00': '522 Pretoria Driving School',
  '12:00': '522 Pretoria Driving School',
  '13:00': '522 Pretoria Driving School',
  '14:00': '522 Pretoria Driving School',
  '15:00': '522 Pretoria Driving School',
};
// Dummy data list for lessons
List<Map<String, dynamic>> generateDummyLessonsData() {
  List<Map<String, dynamic>> lessonsDate = [];
  DateTime baseDate =
      DateTime.now(); // Starting date is today (ensuring future dates)
  List<String> locations = ["Johannesburg", "Thembisa", "Pretoria", "Soweto"];
  List<String> instructors = [
    "Mr. John Doe",
    "Ms. Jane Smith",
    "Mr. Adam Brown"
  ];

  for (int i = 0; i < 10; i++) {
    DateTime lessonDate = baseDate
        .add(Duration(days: i + 1)); // Ensure at least 1 day in the future
    if (lessonDate.isBefore(DateTime.now()))
      continue; // Skip if the generated date is in the past

    String formattedDate =
        '${lessonDate.year}-${lessonDate.month.toString().padLeft(2, '0')}-${lessonDate.day.toString().padLeft(2, '0')}';
    String time = '${8 + (i % 8)}:00';

    lessonsDate.add({
      'lessons': '${9 + i}',
      'date': formattedDate,
      'time': time,
      'status': 'pending',
      'instructor': instructors[i % instructors.length],
      'course': 'code ${(10 + i % 5)}',
      'duration': '1 hour',
      'location': locations[i % locations.length],
      'student': 'Student ${i + 1}',
    });
  }

  return lessonsDate;
}
