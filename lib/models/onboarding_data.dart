class OnboardingData {
  String goal;
  List<String> focusAreas;
  String experience;
  int workoutFrequency;
  String title; // Added to match HomeScreen usage
  String description; // Added to match HomeScreen usage

  OnboardingData({
    required this.goal,
    required this.focusAreas,
    required this.experience,
    required this.workoutFrequency,
    this.title = 'Welcome', // Default value for compatibility
    this.description = 'Your fitness journey starts here',
    String? gender, // Default value
  });

  Map<String, dynamic> toJson() {
    return {
      'goal': goal,
      'focusAreas': focusAreas,
      'experience': experience,
      'workoutFrequency': workoutFrequency,
      'title': title,
      'description': description,
    };
  }
}
