import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:io';
import '../services/database_service.dart';
import '../services/storage_service.dart';
import '../services/permission_service.dart';
import '../models/client.dart';

class NewClientScreen extends StatefulWidget {
  @override
  _NewClientScreenState createState() => _NewClientScreenState();
}

class _NewClientScreenState extends State<NewClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _databaseService = DatabaseService();
  final StorageService _storageService = StorageService();
  final PermissionService _permissionService = PermissionService();
  final LocalAuthentication _localAuth = LocalAuthentication();

  String id = '';
  String _name = '';
  String _phone = '';
  String _issueDescription = '';
  double _repairCost = 0.0;
  DateTime _submissionDate = DateTime.now();
  DateTime? _pickupDate;
  XFile? _clientPhoto;
  bool _useFingerprint = false;

  Future<void> _takePicture() async {
    bool hasPermission = await _permissionService.requestCameraPermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission de caméra refusée')),
      );
      return;
    }

    final ImagePicker _picker = ImagePicker();
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      setState(() {
        _clientPhoto = photo;
      });
    }
  }

  Future<void> _authenticateWithFingerprint() async {
    bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
    if (canCheckBiometrics) {
      List<BiometricType> availableBiometrics =
          await _localAuth.getAvailableBiometrics();
      if (availableBiometrics.contains(BiometricType.fingerprint)) {
        bool didAuthenticate = await _localAuth.authenticate(
          localizedReason:
              'Veuillez scanner votre empreinte digitale pour confirmer',
          options: const AuthenticationOptions(biometricOnly: true),
        );
        setState(() {
          _useFingerprint = didAuthenticate;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'L\'authentification par empreinte digitale n\'est pas disponible sur cet appareil')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'L\'authentification biométrique n\'est pas disponible sur cet appareil')),
      );
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        String? photoUrl;
        if (_clientPhoto != null) {
          bool hasPermission =
              await _permissionService.requestStoragePermission();
          if (!hasPermission) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Permission de stockage refusée')),
            );
            return;
          }
          photoUrl = await _storageService.uploadFile(
            File(_clientPhoto!.path),
            'client_photos/${DateTime.now().millisecondsSinceEpoch}.jpg',
          );
        }

        Client newClient = Client(
          id: id,
          name: _name,
          phone: _phone,
          photoUrl: photoUrl,
          useFingerprint: _useFingerprint,
          issueDescription: _issueDescription,
          repairCost: _repairCost,
          submissionDate: _submissionDate,
          pickupDate: _pickupDate,
        );

        await _databaseService.addClient(newClient);

        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'ajout du client: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nouveau Client'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Nom'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
                onChanged: (value) => _name = value,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Téléphone'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un numéro de téléphone';
                  }
                  return null;
                },
                onChanged: (value) => _phone = value,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration:
                    InputDecoration(labelText: 'Description du problème'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description du problème';
                  }
                  return null;
                },
                onChanged: (value) => _issueDescription = value,
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
              ElevatedButton(
                child: Text('Prendre une photo'),
                onPressed: _takePicture,
              ),
              if (_clientPhoto != null)
                Image.file(File(_clientPhoto!.path), height: 200),
              SizedBox(height: 16),
              ElevatedButton(
                child: Text('Utiliser l\'empreinte digitale'),
                onPressed: _authenticateWithFingerprint,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                child: Text('Ajouter le client'),
                onPressed: _submitForm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
