import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class WorkoutScreen extends StatefulWidget {
  final List<ExerciseData> exercises;

  const WorkoutScreen({
    super.key,
    required this.exercises,
  });

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen>
    with SingleTickerProviderStateMixin {
  bool _isVideoLoading = true;
  bool _hasVideoError = false;
  int selectedExerciseIndex = 0;

  Timer? _timer;
  int _time = 0;
  bool _isResting = false; // Flag to indicate if the timer is for rest
  Map<String, String>? videoUrls;
  YoutubePlayerController? _ytController;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late List<Animation<double>> _setAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startTimer();
    _loadVideoUrls();
  }

  void _initializeAnimations() {
    // Initialize the animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Initialize the fade animation for the screen
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Initialize set animations (will be updated after sets are loaded)
    _setAnimations = [];

    // Start the animation
    _animationController.forward();
  }

  void _updateSetAnimations() {
    final setCount = widget.exercises[selectedExerciseIndex].sets.length;
    _setAnimations = List.generate(
      setCount,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            0.2 + (index * 0.1), // Staggered delay for each set row
            1.0,
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );

    // Reset and restart the animation for the set rows
    _animationController.reset();
    _animationController.forward();
  }

  void _loadVideoUrls() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/videos.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      setState(() {
        videoUrls = jsonMap.map((key, value) {
          final url = value.toString();
          final id = YoutubePlayer.convertUrlToId(url);
          return MapEntry(key, id ?? '');
        });
        _isVideoLoading = false;
      });

      // Initialize controller after loading URLs
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateControllerForCurrentExercise();
      });
    } catch (e) {
      setState(() {
        _hasVideoError = true;
        _isVideoLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _ytController?.pause();
    _ytController?.dispose();
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _time = 0; // Reset the timer to 0 when starting a workout
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _time++; // Increment the timer
      });
    });
  }

  void _logSet(int index) {
    final currentExercise = widget.exercises[selectedExerciseIndex];
    final currentSets = currentExercise.sets;

    if (currentSets[index].weight <= 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text(
            'Invalid Weight',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          content: Text(
            'Please enter a valid weight before logging.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF89F336),
                ),
              ),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      currentSets[index].isLogged = true;
    });

    // Pause video when logging
    _ytController?.pause();

    // Only show timer if not all sets are logged
    if (currentSets.any((set) => !set.isLogged)) {
      _showTimerDialog();
    }
  }

  void _showTimerDialog() {
    _isResting = true;
    int restTime = 60;
    Timer? restTimer;
    bool dialogOpen = true;

    _ytController?.pause();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void updateTime(int seconds) {
              if (!mounted) return;
              if (dialogOpen && context.mounted) {
                setState(() => restTime = seconds);
              }
            }

            restTimer?.cancel();
            restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
              if (!mounted) {
                timer.cancel();
                return;
              }
              if (restTime > 0) {
                updateTime(restTime - 1);
              } else {
                timer.cancel();
                if (dialogOpen && context.mounted) {
                  Navigator.of(context).pop();
                }
              }
            });

            return PopScope(
              canPop: true,
              onPopInvoked: (didPop) {
                if (!didPop) return; // Ensures the pop was triggered
                if (!mounted) return;
                restTimer?.cancel();
                dialogOpen = false;
              },
              child: Dialog(
                backgroundColor: const Color(0xFF1E1E1E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon
                      const Icon(
                        Icons.timer,
                        color: Color(0xFF89F336),
                        size: 40,
                      ),
                      const SizedBox(height: 16),

                      // Title
                      Text(
                        "Rest Timer",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Timer display
                      Text(
                        "$restTime sec remaining",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[400],
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      // Circular progress indicator
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 60,
                            width: 60,
                            child: CircularProgressIndicator(
                              value: restTime / 60,
                              backgroundColor: Colors.grey[700],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF89F336)),
                              strokeWidth: 6,
                            ),
                          ),
                          Text(
                            "$restTime",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () {
                              restTimer?.cancel();
                              dialogOpen = false;
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Skip',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: const Color(0xFF89F336),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              updateTime(restTime + 30);
                            },
                            child: Text(
                              '+30 sec',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: const Color(0xFF89F336),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      restTimer?.cancel();
      dialogOpen = false;
      _isResting = false;
      // Resume video when timer ends
      if (context.mounted) _ytController?.play();
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  void _showAddSetDialog(BuildContext context) {
    final currentExercise = widget.exercises[selectedExerciseIndex];
    int newSetNumber = currentExercise.sets.length + 1;

    double newLastReps = 0.00;
    int newReps = 10;
    double newWeight = 0.00;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text(
            'Add New Set',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: newReps.toString(),
                keyboardType: TextInputType.number,
                style: GoogleFonts.poppins(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Reps',
                  labelStyle: GoogleFonts.poppins(color: Colors.grey),
                  enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF89F336))),
                ),
                onChanged: (value) {
                  newReps = int.tryParse(value) ?? 10;
                },
              ),
              TextFormField(
                initialValue: newWeight.toString(),
                keyboardType: TextInputType.number,
                style: GoogleFonts.poppins(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Weight',
                  labelStyle: GoogleFonts.poppins(color: Colors.grey),
                  enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF89F336))),
                ),
                onChanged: (value) {
                  newWeight = double.tryParse(value) ?? 0.00;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final newSet = WorkoutSet(
                  setNumber: newSetNumber,
                  lastReps: newLastReps,
                  reps: newReps,
                  weight: newWeight,
                  isLogged: false,
                );
                setState(() {
                  currentExercise.sets.add(newSet);
                  _updateSetAnimations();
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF89F336),
              ),
              child: Text(
                'OK',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _logNextSet() {
    final currentSets = widget.exercises[selectedExerciseIndex].sets;
    final firstUnlogged = currentSets.indexWhere((set) => !set.isLogged);

    if (firstUnlogged == -1) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text(
            'All Sets Logged',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          content: Text(
            'All sets for this exercise have been logged.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF89F336),
                ),
              ),
            ),
          ],
        ),
      );
      return;
    }

    _logSet(firstUnlogged);
  }

  void _showEditDialog(BuildContext context, WorkoutSet set) {
    int newReps = set.reps;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text(
            'Edit Reps',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          content: TextFormField(
            initialValue: newReps.toString(),
            keyboardType: TextInputType.number,
            style: GoogleFonts.poppins(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Reps',
              labelStyle: GoogleFonts.poppins(color: Colors.grey),
              enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey)),
              focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF89F336))),
            ),
            onChanged: (value) {
              newReps = int.tryParse(value) ?? set.reps;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  set.reps = newReps;
                });
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF89F336),
              ),
              child: Text(
                'Save',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditWeightDialog(BuildContext context, WorkoutSet set) {
    double newWeight = set.weight;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text(
            'Edit Weight',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          content: TextFormField(
            initialValue: newWeight.toString(),
            keyboardType: TextInputType.number,
            style: GoogleFonts.poppins(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Weight',
              labelStyle: GoogleFonts.poppins(color: Colors.grey),
              enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey)),
              focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF89F336))),
            ),
            onChanged: (value) {
              newWeight = double.tryParse(value) ?? set.weight;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  set.weight = newWeight;
                });
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF89F336),
              ),
              child: Text(
                'Save',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditLastDialog(BuildContext context, WorkoutSet set) {
    double newLastReps = set.lastReps;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text(
            'Edit Last Reps',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          content: TextFormField(
            initialValue: newLastReps.toString(),
            keyboardType: TextInputType.number,
            style: GoogleFonts.poppins(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Last Reps',
              labelStyle: GoogleFonts.poppins(color: Colors.grey),
              enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey)),
              focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF89F336))),
            ),
            onChanged: (value) {
              newLastReps = double.tryParse(value) ?? set.lastReps;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  set.lastReps = newLastReps;
                });
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF89F336),
              ),
              child: Text(
                'Save',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateControllerForCurrentExercise();
    _updateSetAnimations();
  }

  @override
  Widget build(BuildContext context) {
    final currentExercise = widget.exercises[selectedExerciseIndex];
    // Get video URL and convert to ID
    final String? videoUrl = videoUrls?[currentExercise.name];
    final String? videoId =
        videoUrl != null ? YoutubePlayer.convertUrlToId(videoUrl) : null;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Time: ${_formatTime(_time)}',
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, {
                'exercises': widget.exercises,
                'duration': _time,
              });
            },
            child: Text(
              'Finish',
              style: GoogleFonts.poppins(
                color: const Color(0xFF89F336),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                width: double.infinity,
                height: 200,
                color: const Color(0xFF121212),
                child: _buildMediaDisplay(videoId, currentExercise),
              ),
            ),
            const SizedBox(height: 16),
            FadeTransition(
              opacity: _fadeAnimation,
              child: SizedBox(
                height: 80,
                child: ListView.builder(
                  cacheExtent: 1000,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: widget.exercises.length,
                  itemBuilder: (context, index) {
                    return _exerciseIcon(
                      index == selectedExerciseIndex,
                      widget.exercises[index].imagePath,
                      index,
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.linear_scale,
                                        color: Color(0xFF89F336), size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      widget.exercises[selectedExerciseIndex]
                                          .name,
                                      style: GoogleFonts.poppins(
                                        fontSize: 22,
                                        color: const Color(0xFF89F336),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.timer,
                                        size: 18, color: Colors.grey),
                                    const SizedBox(width: 5),
                                    Text(
                                      '60 sec rest',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.view_list,
                                    color: Colors.grey, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Sets',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.history,
                                    color: Colors.grey, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Last',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.repeat,
                                    color: Colors.grey, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Reps',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.fitness_center,
                                    color: Colors.grey, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Kg',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        cacheExtent: 1000,
                        padding: EdgeInsets.zero,
                        itemCount:
                            widget.exercises[selectedExerciseIndex].sets.length,
                        itemBuilder: (context, index) {
                          if (index >= _setAnimations.length) {
                            return const SizedBox.shrink();
                          }
                          return FadeTransition(
                            opacity: _setAnimations[index],
                            child: Transform.translate(
                              offset: Offset(
                                  0, 20 * (1 - _setAnimations[index].value)),
                              child: _setRow(
                                context,
                                widget.exercises[selectedExerciseIndex]
                                    .sets[index],
                                index,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    _buildBottomBar(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _exerciseIcon(bool isSelected, String imagePath, int index) {
    return GestureDetector(
      onTap: () {
        final nextExercise = widget.exercises[index];
        final videoUrl = videoUrls?[nextExercise.name];

        if (videoUrl?.isNotEmpty ?? false) {
          final videoId = YoutubePlayer.convertUrlToId(videoUrl!);
          if (videoId != null) {
            precacheImage(
              NetworkImage(YoutubePlayer.getThumbnail(videoId: videoId)),
              context,
            );
          }
        }

        setState(() {
          selectedExerciseIndex = index;
          _isVideoLoading = true;
          _hasVideoError = false;
          // Force controller update
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateControllerForCurrentExercise();
            if (mounted) {
              setState(() => _isVideoLoading = false);
            }
          });

          // Ensure sets are initialized
          if (widget.exercises[index].sets.isEmpty) {
            widget.exercises[index].sets = [
              WorkoutSet(
                  setNumber: 1,
                  lastReps: 0.00,
                  reps: 10,
                  weight: 0.00,
                  isLogged: false),
              WorkoutSet(
                  setNumber: 2,
                  lastReps: 0.00,
                  reps: 10,
                  weight: 0.00,
                  isLogged: false),
              WorkoutSet(
                  setNumber: 3,
                  lastReps: 0.00,
                  reps: 10,
                  weight: 0.00,
                  isLogged: false),
            ];
          }
          _updateSetAnimations();
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF89F336).withOpacity(0.2)
              : Colors.grey[900],
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: const Color(0xFF89F336), width: 2)
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.fitness_center,
                color: Colors.grey,
              );
            },
          ),
        ),
      ),
    );
  }

  void _updateControllerForCurrentExercise() {
    if (videoUrls == null) return;

    final currentExercise = widget.exercises[selectedExerciseIndex];
    final videoUrl = videoUrls?[currentExercise.name];
    final videoId = YoutubePlayer.convertUrlToId(videoUrl ?? '');

    if (videoId == _ytController?.initialVideoId) return;

    _ytController?.dispose();

    if (videoId != null && videoId.isNotEmpty) {
      _ytController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          disableDragSeek: true,
          enableCaption: false,
          hideThumbnail: true,
          useHybridComposition: false,
        ),
      );
      setState(() => _hasVideoError = false);
    } else {
      setState(() => _hasVideoError = true);
    }
  }

  Widget _buildMediaDisplay(String? videoId, ExerciseData exercise) {
    if (_isVideoLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasVideoError || videoId == null || videoId.isEmpty) {
      return _buildErrorFallback(exercise);
    }

    return YoutubePlayerBuilder(
      key: ValueKey(videoId),
      player: YoutubePlayer(
        controller: _ytController ??
            YoutubePlayerController(
              initialVideoId: videoId,
              flags: const YoutubePlayerFlags(
                autoPlay: false,
                mute: false,
                disableDragSeek: true,
              ),
            ),
        showVideoProgressIndicator: true,
        onReady: () => setState(() {}),
      ),
      builder: (context, player) => AspectRatio(
        aspectRatio: 16 / 9,
        child: player,
      ),
    );
  }

  Widget _buildErrorFallback(ExerciseData exercise) {
    return Image.asset(
      exercise.imagePath,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => const Center(
        child: Icon(
          Icons.error_outline,
          color: Colors.red,
          size: 50,
        ),
      ),
    );
  }

  Widget _setRow(BuildContext context, WorkoutSet set, int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: set.isLogged
            ? const Color(0xFF89F336).withOpacity(0.7)
            : const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              '${set.setNumber}',
              style: GoogleFonts.poppins(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            InkWell(
              onTap: () => _showEditLastDialog(context, set),
              child: Column(
                children: [
                  Text(
                    set.lastReps > 0 ? set.lastReps.toStringAsFixed(2) : '0.00',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 30,
                    child: Divider(
                      color: Colors.grey[400],
                      thickness: 2,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () => _showEditDialog(context, set),
              child: Column(
                children: [
                  Text(
                    '${set.reps}',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 30,
                    child: Divider(
                      color: Colors.grey[400],
                      thickness: 2,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: set.isLogged
                  ? null
                  : () => _showEditWeightDialog(context, set),
              child: Column(
                children: [
                  Text(
                    set.weight.toStringAsFixed(2),
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 30,
                    child: Divider(
                      color: Colors.grey[400],
                      thickness: 2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              _showAddSetDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2A2A2A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(
              'Add a set',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _logNextSet,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF89F336),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Log',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WorkoutSet {
  int setNumber;
  double lastReps;
  int reps;
  double weight;
  bool isLogged;

  WorkoutSet({
    required this.setNumber,
    required this.lastReps,
    required this.reps,
    required this.weight,
    required this.isLogged,
  });
}

class ExerciseData {
  final String name;
  final String imagePath;
  final List<String> targetMuscles;
  List<WorkoutSet> sets;

  ExerciseData({
    required this.name,
    required this.imagePath,
    required this.targetMuscles,
    List<WorkoutSet>? sets,
  }) : sets = sets ??
            List.generate(
              3,
              (index) => WorkoutSet(
                setNumber: index + 1,
                lastReps: 0.00,
                reps: 10,
                weight: 0.00,
                isLogged: false,
              ),
            );
}
