import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(const JarvisApp());
}

class JarvisApp extends StatelessWidget {
  const JarvisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'J.A.R.V.I.S. Protocol',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF030710),
        primaryColor: const Color(0xFF00E5FF),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E5FF),
          secondary: Color(0xFFFF9100),
        ),
      ),
      home: const JarvisHomeScreen(),
    );
  }
}

class JarvisTask {
  String id;
  String title;
  DateTime scheduledTime;
  bool isCompleted;
  String agentGender;

  JarvisTask({
    required this.id,
    required this.title,
    required this.scheduledTime,
    this.isCompleted = false,
    this.agentGender = 'Male',
  });
}

class JarvisHomeScreen extends StatefulWidget {
  const JarvisHomeScreen({super.key});

  @override
  State<JarvisHomeScreen> createState() => _JarvisHomeScreenState();
}

class _JarvisHomeScreenState extends State<JarvisHomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _reactorController;
  final List<JarvisTask> _tasks = [];
  Timer? _scheduleTimer;
  String _selectedGender = 'Male';

  @override
  void initState() {
    super.initState();
    _reactorController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _scheduleTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _checkPendingTasks();
    });
  }

  void _checkPendingTasks() {
    final now = DateTime.now();
    for (var task in _tasks) {
      if (!task.isCompleted && task.scheduledTime.isBefore(now)) {
        _triggerIncomingVideoCall(task);
        break;
      }
    }
  }

  void _triggerIncomingVideoCall(JarvisTask task) {
    task.isCompleted = true;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VideoCallReminderScreen(
          task: task,
          onTaskResult: (status) {
            setState(() {
              task.isCompleted = status;
            });
          },
        ),
      ),
    );
  }

  void _addNewTaskDialog() {
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0A1526),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFF00E5FF), width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          "INITIATE NEW PROTOCOL",
          style: TextStyle(color: Color(0xFF00E5FF), letterSpacing: 1.5, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Enter Task / Reminder",
                hintStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00E5FF))),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("AI Agent Gender:", style: TextStyle(color: Colors.white70)),
                DropdownButton<String>(
                  value: _selectedGender,
                  dropdownColor: const Color(0xFF0A1526),
                  style: const TextStyle(color: Color(0xFF00E5FF)),
                  items: ['Male', 'Female'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedGender = val);
                  },
                )
              ],
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("ABORT", style: TextStyle(color: Colors.redAccent)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5FF)),
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                setState(() {
                  _tasks.add(JarvisTask(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text,
                    scheduledTime: DateTime.now().add(const Duration(seconds: 5)),
                    agentGender: _selectedGender,
                  ));
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text("DEPLOY", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _reactorController.dispose();
    _scheduleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "STARK HUD // J.A.R.V.I.S.",
          style: TextStyle(
            color: Color(0xFF00E5FF),
            fontWeight: FontWeight.w900,
            letterSpacing: 3.0,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Center(
                child: RotationTransition(
                  turns: _reactorController,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E5FF).withOpacity(0.3),
                          blurRadius: 25,
                          spreadRadius: 5,
                        ),
                      ],
                      border: Border.all(color: const Color(0xFF00E5FF), width: 3),
                    ),
                    child: Center(
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFFF9100), width: 2),
                        ),
                        child: const Icon(Icons.bolt, color: Color(0xFF00E5FF), size: 45),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF081220).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "TACTICAL UTILITY DECK",
                      style: TextStyle(color: Color(0xFF00E5FF), fontSize: 13, letterSpacing: 2, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildToolButton(Icons.language, "Browser", () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const JarvisBrowserScreen()));
                        }),
                        _buildToolButton(Icons.calculate, "Calculator", () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const JarvisCalculatorScreen()));
                        }),
                        _buildToolButton(Icons.description, "Doc / PDF", () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const JarvisPdfViewerScreen()));
                        }),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF081220).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "ACTIVE PROTOCOLS / TASKS",
                          style: TextStyle(color: Color(0xFF00E5FF), fontSize: 13, letterSpacing: 2, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: Color(0xFF00E5FF)),
                          onPressed: _addNewTaskDialog,
                        )
                      ],
                    ),
                    const Divider(color: Color(0xFF00E5FF)),
                    _tasks.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: Text(
                                "NO ACTIVE TASKS RECORDED",
                                style: TextStyle(color: Colors.white38, letterSpacing: 1.5),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _tasks.length,
                            itemBuilder: (ctx, idx) {
                              final t = _tasks[idx];
                              return ListTile(
                                leading: Icon(
                                  t.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                                  color: t.isCompleted ? Colors.greenAccent : const Color(0xFFFF9100),
                                ),
                                title: Text(t.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                  "Scheduled: ${DateFormat('hh:mm a').format(t.scheduledTime)} | Agent: ${t.agentGender}",
                                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00E5FF),
        onPressed: _addNewTaskDialog,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildToolButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF00E5FF)),
              color: const Color(0xFF00E5FF).withOpacity(0.1),
            ),
            child: Icon(icon, color: const Color(0xFF00E5FF), size: 26),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

class VideoCallReminderScreen extends StatefulWidget {
  final JarvisTask task;
  final Function(bool) onTaskResult;

  const VideoCallReminderScreen({super.key, required this.task, required this.onTaskResult});

  @override
  State<VideoCallReminderScreen> createState() => _VideoCallReminderScreenState();
}

class _VideoCallReminderScreenState extends State<VideoCallReminderScreen> {
  bool _isCallAnswered = false;
  final FlutterTts _tts = FlutterTts();

  void _answerCall() async {
    setState(() {
      _isCallAnswered = true;
    });
    await _tts.setPitch(widget.task.agentGender == 'Female' ? 1.2 : 0.8);
    await _tts.speak("Sir, you have a scheduled reminder: ${widget.task.title}. Have you completed this protocol?");
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020712),
      body: SafeArea(
        child: _isCallAnswered ? _buildLiveVideoInterface() : _buildIncomingCallInterface(),
      ),
    );
  }

  Widget _buildIncomingCallInterface() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "INCOMING SECURE TRANSMISSION",
          style: TextStyle(color: Color(0xFF00E5FF), letterSpacing: 2, fontSize: 13),
        ),
        const SizedBox(height: 30),
        Center(
          child: Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF00E5FF), width: 2),
              boxShadow: [
                BoxShadow(color: const Color(0xFF00E5FF).withOpacity(0.4), blurRadius: 30),
              ],
            ),
            child: Icon(
              widget.task.agentGender == 'Female' ? Icons.support_agent : Icons.psychology,
              size: 80,
              color: const Color(0xFF00E5FF),
            ),
          ),
        ),
        const SizedBox(height: 25),
        Text(
          "J.A.R.V.I.S. (${widget.task.agentGender.toUpperCase()} AGENT)",
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        const SizedBox(height: 10),
        Text("Task: ${widget.task.title}", style: const TextStyle(color: Colors.white70)),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton(
              heroTag: 'decline',
              backgroundColor: Colors.redAccent,
              onPressed: () => Navigator.pop(context),
              child: const Icon(Icons.call_end, color: Colors.white),
            ),
            FloatingActionButton(
              heroTag: 'accept',
              backgroundColor: Colors.greenAccent,
              onPressed: _answerCall,
              child: const Icon(Icons.videocam, color: Colors.black),
            ),
          ],
        ),
        const SizedBox(height: 50),
      ],
    );
  }

  Widget _buildLiveVideoInterface() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF00E5FF), width: 1.5),
                gradient: const RadialGradient(colors: [Color(0xFF09233B), Color(0xFF020712)]),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.task.agentGender == 'Female' ? Icons.face_3 : Icons.face,
                    size: 130,
                    color: const Color(0xFF00E5FF),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "AUDIO SYNTHESIZING...",
                    style: TextStyle(color: const Color(0xFF00E5FF).withOpacity(0.7), letterSpacing: 2),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      "Task: ${widget.task.title}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            "DID YOU COMPLETE THIS TASK?",
            style: TextStyle(color: Colors.white70, letterSpacing: 1.5),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.withOpacity(0.2),
                  side: const BorderSide(color: Colors.redAccent),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                icon: const Icon(Icons.close, color: Colors.redAccent),
                label: const Text("NO, SNOOZE", style: TextStyle(color: Colors.redAccent)),
                onPressed: () {
                  widget.onTaskResult(false);
                  Navigator.pop(context);
                },
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF).withOpacity(0.2),
                  side: const BorderSide(color: Color(0xFF00E5FF)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                icon: const Icon(Icons.check, color: Color(0xFF00E5FF)),
                label: const Text("YES, FINISHED", style: TextStyle(color: Color(0xFF00E5FF))),
                onPressed: () {
                  widget.onTaskResult(true);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class JarvisBrowserScreen extends StatefulWidget {
  const JarvisBrowserScreen({super.key});

  @override
  State<JarvisBrowserScreen> createState() => _JarvisBrowserScreenState();
}

class _JarvisBrowserScreenState extends State<JarvisBrowserScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://www.google.com'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("HUD BROWSER", s
