import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt; // Added import for STT

// Page for logging trades via voice input
class AddTradeVoicePage extends ConsumerStatefulWidget {
  const AddTradeVoicePage({super.key});

  @override
  ConsumerState<AddTradeVoicePage> createState() => _AddTradeVoicePageState();
}

class _AddTradeVoicePageState extends ConsumerState<AddTradeVoicePage> {
  // --- Added STT Variables ---
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedWords = '';
  String _lastWords = '';
  bool _speechEnabled = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speech = stt.SpeechToText();
    bool available = await _speech.initialize(
      onStatus: (status) => print('STT Status: $status'),
      onError: (errorNotification) => print('STT Error: $errorNotification'),
    );
    if (mounted && available) {
      setState(() => _speechEnabled = true);
      print("Speech recognition initialized.");
    } else {
      if (mounted) setState(() => _speechEnabled = false);
      print("Speech initialization failed.");
    }
  }

  void _startListening() async {
    if (!_speechEnabled || _isListening) return;
    setState(() {
      _isListening = true;
      _recognizedWords = '';
      _lastWords = '';
    });
    print("Starting listening...");
    await _speech.listen(
      onResult: (result) {
        setState(() {
          _recognizedWords = result.recognizedWords;
          if (result.finalResult) {
            _lastWords = _recognizedWords;
            _isListening = false;
            print("Final recognized text stored: $_lastWords");
          }
        });
      },
      listenFor: const Duration(seconds: 60),
      pauseFor: const Duration(seconds: 5),
    );
  }

  void _stopListening() async {
    if (!_speechEnabled || !_isListening) return;
    await _speech.stop();
    setState(() {
      _isListening = false;
      if (_recognizedWords.isNotEmpty) {
        _lastWords = _recognizedWords;
      }
    });
    print("Stopped listening manually. Final text: $_lastWords");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Trade by Voice'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // --- Top Section: Status and Result ---
            Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  _isListening
                      ? 'Listening... Tap mic to stop'
                      : (_lastWords.isNotEmpty
                          ? 'Recording Complete:'
                          : 'Tap the microphone to record trade details'),
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                if (!_isListening && _lastWords.isNotEmpty)
                  Container(
                    height: 150,
                    width: double.infinity,
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: SingleChildScrollView(
                      child: Text(_lastWords.isEmpty ? '...' : _lastWords),
                    ),
                  )
                else
                  Icon(
                    Icons.mic_none,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
              ],
            ),

            // --- Bottom Section: Buttons ---
            Column(
              children: [
                if (!_isListening && _lastWords.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.replay),
                          label: const Text('Redo'),
                          onPressed: () {
                            setState(() {
                              _lastWords = '';
                              _recognizedWords = '';
                            });
                          },
                        ),
                        TextButton.icon(
                          icon: Icon(Icons.delete_outline,
                              color: Colors.red.shade400),
                          label: Text('Delete',
                              style: TextStyle(color: Colors.red.shade400)),
                          onPressed: () {
                            setState(() {
                              _lastWords = '';
                              _recognizedWords = '';
                            });
                          },
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.send),
                          label: const Text('Analyze Text'),
                          onPressed: () {
                            print('--- Sending to AI (Not Implemented Yet) ---');
                            print(_lastWords);
                            print('------------------------------------------');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'AI analysis not implemented yet.')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: IconButton.filled(
                    icon: Icon(_isListening ? Icons.stop : Icons.mic),
                    iconSize: 40,
                    padding: const EdgeInsets.all(20),
                    tooltip: _isListening ? 'Stop recording' : 'Start recording',
                    style: IconButton.styleFrom(
                      backgroundColor: _isListening
                          ? Colors.red.shade300
                          : Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      if (_speechEnabled) {
                        _isListening ? _stopListening() : _startListening();
                      } else {
                        print("Speech not enabled yet.");
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
