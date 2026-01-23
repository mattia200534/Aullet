import 'package:applicazione/viewmodel/auth_view_model.dart';
import 'package:applicazione/viewmodel/profile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});
  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _nameCtrl = TextEditingController();
  bool _didScheduleLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didScheduleLoad) {
      _didScheduleLoad = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final vm = context.read<ProfileViewModel>();
        await vm.loadProfile();
        if (!mounted) return;
        if (vm.profile != null) {
          _nameCtrl.text = vm.profile!.displayname;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();
    final authVM = context.read<AuthViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authVM.Logout();
              if (!mounted) return;
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/login', (route) => false);
            },
          ),
        ],
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  GestureDetector(
                    onTap: () => vm.pickAndUploadAvatar(),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: vm.profile?.avatarUrl != null
                          ? NetworkImage(vm.profile!.avatarUrl!)
                          : null,
                      child: vm.profile?.avatarUrl == null
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () async {
                      await authVM.Logout();
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black54,
                    ),
                    padding: const EdgeInsets.all(4.0),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  TextButton(
                    onPressed: () => vm.pickAndUploadAvatar(),
                    child: const Text('Cambia Avatar'),
                  ),
                  TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: 'Nome'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      vm.updateDisplayName(_nameCtrl.text);
                    },
                    child: const Text('Salva modifiche'),
                  ),
                  if (vm.error != null) ...[
                    const SizedBox(height: 20),
                    Text(vm.error!, style: const TextStyle(color: Colors.red)),
                  ],
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }
}
