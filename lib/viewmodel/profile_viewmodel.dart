import 'dart:io';
import 'package:flutter/material.dart';
import 'package:applicazione/models/profile.dart';
import 'package:applicazione/repositories/profile_rpository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class ProfileViewModel extends ChangeNotifier {
  final _repo = ProfileRepository();
  Profile? _profile;
  bool _isLoading = false;
  String? _error;

  Profile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProfile() async {
    _setLoading(true);
    try {
      final user = Supabase.instance.client.auth.currentUser!;
      _profile = await _repo.fetchProfile(user.id);

      if (_profile == null) {
        _profile = Profile(
          id: '',
          userId: user.id,
          displayname: user.email!.split('@')[0],
        );
        await _repo.createProfile(_profile!);
        _profile = await _repo.fetchProfile(user.id);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (value) _error = null;
    notifyListeners();
  }
}
