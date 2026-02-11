import 'package:applicazione/viewmodel/auth_view_model.dart';
import 'package:applicazione/viewmodel/profile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final TextEditingController _nameCtrl = TextEditingController();
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
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () async {
              await authVM.Logout();
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// AVATAR + ICONA CAMERA
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        GestureDetector(
                          onTap: () => vm.pickAndUploadAvatar(),
                          child: CircleAvatar(
                            radius: 51.5, // border radius
                            backgroundColor: const Color.fromARGB(
                              255,
                              0,
                              0,
                              0,
                            ), // colore del bordo
                            child: CircleAvatar(
                              radius: 50,

                              backgroundImage: vm.profile?.avatarUrl != null
                                  ? NetworkImage(vm.profile!.avatarUrl!)
                                  : null,
                              child: vm.profile?.avatarUrl == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.black,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black54,
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    /// NOME UTENTE
                    TextField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        labelStyle: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 0, 0, 0),
                            width:
                                2, // spessore del bordo quando il campo è attivo
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// SALVA MODIFICHE
                    SizedBox(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 14,
                          ),
                        ),
                        onPressed: () {
                          vm.updateDisplayName(_nameCtrl.text);
                        },
                        child: const Text(
                          'Salva modifiche',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    if (vm.error != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        vm.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],

                    const SizedBox(height: 24),

                    /// ERRORE
                  ],
                ),
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
