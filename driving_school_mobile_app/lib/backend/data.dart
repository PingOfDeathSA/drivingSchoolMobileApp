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

List<dynamic> usersLessons = [
  {
    'lessons': '1',
    'date': '2024-11-10',
    'time': '8:00',
    'status': 'completed',
    'instructor': 'Mr. John Doe',
    'course': 'code 10',
    'duration': '1 hour',
    'location': '522 Tembisa Ivory Driving School',
    'student': 'Lebo Mokwena',
    'lesson_type': 'Introduction to Motor Vehicle Controls',
  },

  {
    'lessons': '2',
    'date': '2024-11-11',
    'time': '9:00',
    'status': 'completed',
    'instructor': 'Ms. Jane Smith',
    'course': 'code 10',
    'duration': '1 hour',
    'location': '522 Tembisa Ivory Driving School',
    'student': 'Lebo Mokwena',
    'lesson_type': 'How to start, stop the engine and move off',
  },

  // Added lessons
  {
    'lessons': '3',
    'date': '2024-11-12',
    'time': '10:00',
    'status': 'completed',
    'instructor': 'Mr. Michael Williams',
    'course': 'code 8',
    'duration': '1 hour',
    'location': 'Johannesburg Central Driving School',
    'student': 'Siphiwe Ndlovu',
    'lesson_type': 'Basic Vehicle Maintenance',
  },

  {
    'lessons': '4',
    'date': '2024-11-13',
    'time': '14:00',
    'status': 'completed',
    'instructor': 'Ms. Sarah Lee',
    'course': 'code 8',
    'duration': '1 hour',
    'location': 'Pretoria West Driving School',
    'student': 'Siphiwe Ndlovu',
    'lesson_type': 'Parking and Reverse Techniques',
  },

  {
    'lessons': '5',
    'date': '2024-11-14',
    'time': '11:00',
    'status': 'missed',
    'instructor': 'Mr. John Doe',
    'course': 'code 10',
    'duration': '1 hour',
    'location': 'Tembisa Ivory Driving School',
    'student': 'Lebo Mokwena',
    'lesson_type': 'Highway Driving Skills',
  },

  {
    'lessons': '6',
    'date': '2024-11-15',
    'time': '12:00',
    'status': 'pending',
    'instructor': 'Ms. Jane Smith',
    'course': 'code 10',
    'duration': '1 hour',
    'location': 'Johannesburg Central Driving School',
    'student': 'Siphiwe Ndlovu',
    'lesson_type': 'Night Driving Practice',
  },

  {
    'lessons': '7',
    'date': '2024-11-16',
    'time': '13:00',
    'status': 'pending',
    'instructor': 'Mr. Michael Williams',
    'course': 'code 8',
    'duration': '1 hour',
    'location': 'Pretoria West Driving School',
    'student': 'Lebo Mokwena',
    'lesson_type': 'Emergency Braking Techniques',
  },

  {
    'lessons': '8',
    'date': '2024-11-17',
    'time': '15:00',
    'status': 'pending',
    'instructor': 'Ms. Sarah Lee',
    'course': 'code 8',
    'duration': '1 hour',
    'location': 'Tembisa Ivory Driving School',
    'student': 'Siphiwe Ndlovu',
    'lesson_type': 'Driver Safety and Rules of the Road',
  },
];
