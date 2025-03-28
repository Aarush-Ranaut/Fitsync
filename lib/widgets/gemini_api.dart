import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fitsync_app/models/onboarding_data.dart';

class GeminiAI {
  static const String apiKey = "AIzaSyCfiFthFiVQ3wdO2Qa5_yUiD9ngbhfUebU";
  static const String apiUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey";

  static Future<Map<String, dynamic>> generateWorkoutPlan(
      OnboardingData data, List<Map<String, dynamic>> exercisesDB) async {
    Map<String, dynamic> workoutPlan = {};

    for (int day = 1; day <= data.workoutFrequency; day++) {
      // Get muscle focus dynamically based on user selections
      String muscleFocus =
          getMuscleFocus(day, data.workoutFrequency, data.focusAreas);

      String prompt = """
        You are a professional fitness trainer. Create a **Day $day workout** plan for a user whose goal is **${data.goal}**, experience level is **${data.experience}**, and they train **${data.workoutFrequency} days per week**.

        **Workout Focus for Day $day:** $muscleFocus (User selected: ${data.focusAreas.join(', ')})
        
        **Previously generated workouts:**
        ${jsonEncode(workoutPlan)}

        **Rules:**
        - Ensure **6 different exercises** for the day.
        - Select exercises that target **$muscleFocus**.
        - Assign **2-3 target muscles** per exercise from the following list only:
          - Chest, Triceps, Lats, Biceps, Shoulder, Abs, Forearms, Traps, Glutes, Quads, Hamstring, Calves.
        - At least **one workout day must prioritize leg exercises** (Glutes, Quads, Hamstring, Calves) if "Legs" is in user focus.
        - If the user has fewer training days, combine multiple muscle groups into one day to maximize efficiency.
        - If the user has more training days, distribute muscle groups effectively to ensure balanced training.
        - Avoid repeating the same muscle group on consecutive days.
        - Maintain a structured progression based on experience level.
        - Choose only from the provided **Exercises Database**.

        **Exercises Database:** ${jsonEncode(exercisesDB)}

        **Return JSON format:**
        {
          "workout": "$muscleFocus",
          "exercises": [
            { 
              "name": "Exercise 1", 
              "targetMuscles": ["Chest", "Triceps"], 
              "sets": 4, 
              "reps": 10 
            },
            { 
              "name": "Exercise 2", 
              "targetMuscles": ["Lats", "Biceps"], 
              "sets": 4, 
              "reps": 10 
            },
            { 
              "name": "Exercise 3", 
              "targetMuscles": ["Shoulder", "Traps"], 
              "sets": 3, 
              "reps": 12 
            },
            { 
              "name": "Exercise 4", 
              "targetMuscles": ["Glutes", "Quads", "Hamstring"], 
              "sets": 3, 
              "reps": 12 
            },
            { 
              "name": "Exercise 5", 
              "targetMuscles": ["Abs", "Forearms"], 
              "sets": 3, 
              "reps": 10 
            },
            { 
              "name": "Exercise 6", 
              "targetMuscles": ["Calves", "Quads"], 
              "sets": 3, 
              "reps": 12 
            }
          ]
        }
      """;

      print("Generating Day $day workout...");

      try {
        var response = await http.post(
          Uri.parse(apiUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "contents": [
              {
                "parts": [
                  {"text": prompt}
                ]
              }
            ]
          }),
        );

        if (response.statusCode == 200) {
          var jsonData = jsonDecode(response.body);

          if (jsonData.containsKey("candidates") &&
              jsonData["candidates"] != null &&
              jsonData["candidates"].isNotEmpty &&
              jsonData["candidates"][0]["content"] != null &&
              jsonData["candidates"][0]["content"]["parts"] != null &&
              jsonData["candidates"][0]["content"]["parts"].isNotEmpty) {
            String rawResponse =
                jsonData["candidates"][0]["content"]["parts"][0]["text"];

            if (rawResponse.isEmpty) {
              print("Empty response received for Day $day");
              continue;
            }

            rawResponse =
                rawResponse.replaceAll(RegExp(r'```json|```'), '').trim();

            try {
              var parsedResponse = jsonDecode(rawResponse);

              if (parsedResponse.containsKey("workout") &&
                  parsedResponse.containsKey("exercises") &&
                  (parsedResponse["exercises"] as List).isNotEmpty) {
                workoutPlan["Day $day"] = {
                  "workout": parsedResponse["workout"] ?? muscleFocus,
                  "exercises": parsedResponse["exercises"]
                };
              } else {
                print(
                    "Skipping Day $day due to incomplete response: $parsedResponse");
              }
            } catch (e) {
              print("Error parsing JSON for Day $day: $e");
              continue;
            }
          } else {
            print("Unexpected API response format for Day $day: $jsonData");
          }
        } else {
          print(
              "Failed to fetch workout for Day $day. Status Code: ${response.statusCode}");
        }
      } catch (e) {
        print("Exception caught for Day $day: $e");
      }
    }

    print(jsonEncode(workoutPlan)); // Prints the full JSON in console

    return workoutPlan;
  }
}

String getMuscleFocus(int day, int workoutDays, List<String> focusAreas) {
  List<List<String>> muscleSplits;

  if (workoutDays == 1) {
    muscleSplits = [
      ["Full Body"]
    ];
  } else if (workoutDays == 2) {
    muscleSplits = [
      ["Upper Body"],
      ["Lower Body"]
    ];
  } else if (workoutDays == 3) {
    muscleSplits = [
      ["Push (Chest, Triceps, Shoulders)"],
      ["Pull (Back, Biceps)"],
      ["Legs"]
    ];
  } else if (workoutDays == 4) {
    muscleSplits = [
      ["Chest & Triceps"],
      ["Back & Biceps"],
      ["Legs & Abs"],
      ["Shoulders & Arms"]
    ];
  } else if (workoutDays == 5) {
    muscleSplits = [
      ["Chest & Triceps"],
      ["Back & Biceps"],
      ["Legs"],
      ["Shoulders & Abs"],
      ["Full Body"]
    ];
  } else if (workoutDays == 6) {
    muscleSplits = [
      ["Chest & Triceps"],
      ["Back & Biceps"],
      ["Legs"],
      ["Shoulders & Abs"],
      ["Arms"],
      ["Legs"]
    ];
  } else {
    muscleSplits = [
      ["Chest"],
      ["Back"],
      ["Legs"],
      ["Shoulders"],
      ["Arms"],
      ["Legs"],
      ["Full Body"]
    ];
  }

  // Filter only muscle groups that the user selected
  List<String> filteredDays = muscleSplits
      .map((split) => split
          .where((muscle) =>
              focusAreas.any((focus) => split.join().contains(focus)))
          .toList())
      .where((split) => split.isNotEmpty)
      .map((split) => split.join(", ")) // Convert list back to string
      .toList();

  // Ensure at least one "Legs" day if the user selected Legs
  if (focusAreas.contains("Legs") &&
      !filteredDays.any((day) => day.contains("Legs"))) {
    filteredDays.insert(2, "Legs");
  }

  if (day - 1 >= filteredDays.length) {
    print("Warning: Day $day exceeds available muscle splits. Using fallback.");
    return muscleSplits[(day - 1) % muscleSplits.length].join(", ");
  }

  return filteredDays[day - 1]; // Return dynamically adjusted focus
}
