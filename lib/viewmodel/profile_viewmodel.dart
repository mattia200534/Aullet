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

  Future<void> updateDisplayName(String name) async {
    if (_profile == null) return;
    _setLoading(true);

    try {
      _profile!.displayname = name;
      await _repo.updateProfile(_profile!);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final file = File(picked.path);
    await uploadAvatar(file);
  }

  Future<void> uploadAvatar(File file) async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser!.id;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = 'image/$userId/$timestamp.png';

    _setLoading(true);
    try {
      await client.storage
          .from('image')
          .upload(
            path,
            file,
            fileOptions: const FileOptions(cacheControl: '3600'),
          );

      final publicUrl = client.storage.from('image').getPublicUrl(path);

      _profile!.avatarUrl = publicUrl;
      await _repo.updateProfile(_profile!);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}
