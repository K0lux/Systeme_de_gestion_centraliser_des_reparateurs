import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';
import '../services/permission_service.dart';
import '../models/repair.dart';

class RepairDetailsScreen extends StatefulWidget {
  final String clientId;

  RepairDetailsScreen({required this.clientId});

  @override
  _RepairDetailsScreenState createState() => _RepairDetailsScreenState();
}

class _RepairDetailsScreenState extends State<RepairDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _databaseService = DatabaseService();
  final StorageService _storageService = StorageService();
  final PermissionService _permissionService = PermissionService();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();

  String _problem = '';
  double _repairCost = 0.0;
  DateTime _submissionDate = DateTime.now();
  DateTime? _retrievalDate;
  String? _audioPath;
  bool _isRecording = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    await _recorder.openRecorder();
    await _player.openPlayer();
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.closePlayer();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    bool hasPermission = await _permissionService.requestMicrophonePermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission de microphone refusée')),
      );
      return;
    }

    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      await _recorder.startRecorder(toFile: 'temp_audio.aac');
      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      print('Erreur lors du démarrage de l\'enregistrement: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      String? path = await _recorder.stopRecorder();
      setState(() {
        _audioPath = path;
        _isRecording = false;
      });
    } catch (e) {
      print('Erreur lors de l\'arrêt de l\'enregistrement: $e');
    }
  }

  Future<void> _playRecording() async {
    if (_audioPath != null) {
      try {
        await _player.startPlayer(fromURI: _audioPath);
        setState(() {
          _isPlaying = true;
        });
        _player.setSubscriptionDuration(Duration(milliseconds: 100));
        _player.onProgress!.listen((event) {
          if (event.duration == event.position) {
            setState(() {
              _isPlaying = false;
            });
          }
        });
      } catch (e) {
        print('Erreur lors de la lecture de l\'enregistrement: $e');
      }
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        String? audioUrl;
        if (_audioPath != null) {
          bool hasPermission =
              await _permissionService.requestStoragePermission();
          if (!hasPermission) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Permission de stockage refusée')),
            );
            return;
          }
          audioUrl = await _storageService.uploadFile(
            File(_audioPath!),
            'repair_audio/${DateTime.now().millisecondsSinceEpoch}.aac',
          );
        }

        Repair newRepair = Repair(
          clientId: widget.clientId,
          problem: _problem,
          repairCost: _repairCost,
          submissionDate: _submissionDate,
          retrievalDate: _retrievalDate,
          audioUrl: audioUrl,
          status: 'En attente',
        );

        await _databaseService.addRepair(newRepair);

        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur lors de l\'ajout de la réparation: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de la réparation'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Problème'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez décrire le problème';
                  }
                  return null;
                },
                onChanged: (value) => _problem = value,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Coût de la réparation'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le coût de la réparation';
                  }
                  return null;
                },
                onChanged: (value) =>
                    _repairCost = double.tryParse(value) ?? 0.0,
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                label: Text(_isRecording
                    ? 'Arrêter l\'enregistrement'
                    : 'Enregistrer l\'audio'),
                onPressed: _toggleRecording,
              ),
              if (_audioPath != null)
                ElevatedButton.icon(
                  icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
                  label: Text(_isPlaying
                      ? 'Arrêter la lecture'
                      : 'Écouter l\'enregistrement'),
                  onPressed: _isPlaying ? null : _playRecording,
                ),
              SizedBox(height: 16),
              TextButton(
                child: Text('Date de soumission: ${_submissionDate.toLocal()}'),
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _submissionDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2025),
                  );
                  if (picked != null && picked != _submissionDate)
                    setState(() {
                      _submissionDate = picked;
                    });
                },
              ),
              TextButton(
                child: Text(_retrievalDate == null
                    ? 'Choisir la date de retrait'
                    : 'Date de retrait: ${_retrievalDate!.toLocal()}'),
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _retrievalDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2025),
                  );
                  if (picked != null && picked != _retrievalDate)
                    setState(() {
                      _retrievalDate = picked;
                    });
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                child: Text('Enregistrer la réparation'),
                onPressed: _submitForm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
