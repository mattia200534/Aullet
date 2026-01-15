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
      WidgetsBinding.instance.addPostFrameCallback((_) async{
        final vm = context.read<ProfileViewModel>();
        await vm.loadProfile();
        await context.read<ProfileViewModel>().loadProfile();
        if(mounted && vm.profile != null){
          _nameCtrl.text = vm.profile!.displayname;
        }
      });
      }
    }
    
      @override
      Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
      }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profilo')),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: vm.profile?.avatarUrl != null
                        ? NetworkImage(vm.profile!.avatarUrl!)
                        : null,
                    child: vm.profile?.avatarUrl == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                  TextButton(
                    onPressed: vm.pickAndUploadAvatar,
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
}
