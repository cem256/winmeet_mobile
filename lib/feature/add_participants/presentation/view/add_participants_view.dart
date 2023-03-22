import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:winmeet_mobile/core/extensions/context_extensions.dart';
import 'package:winmeet_mobile/core/extensions/widget_extesions.dart';
import 'package:winmeet_mobile/feature/create_meeting/presentation/cubit/create_meeting_cubit.dart';
import 'package:winmeet_mobile/presentation/widgets/input/email_input_field.dart';

class AddParticipantsView extends StatefulWidget {
  const AddParticipantsView({required CreateMeetingCubit cubit, super.key}) : _cubit = cubit;

  final CreateMeetingCubit _cubit;

  @override
  State<AddParticipantsView> createState() => _AddParticipantsViewState();
}

class _AddParticipantsViewState extends State<AddParticipantsView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Participants'),
      ),
      body: BlocProvider.value(
        value: widget._cubit,
        child: SingleChildScrollView(
          child: Padding(
            padding: context.paddingAllDefault,
            child: Column(
              children: [
                _EmailInput(controller: _controller),
                _SearchResult(controller: _controller),
                const _ParticipantList(),
              ].withSpaceBetween(height: context.mediumValue),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmailInput extends StatelessWidget {
  const _EmailInput({required TextEditingController controller}) : _controller = controller;

  final TextEditingController _controller;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateMeetingCubit, CreateMeetingState>(
      builder: (context, state) {
        return EmailInputField(
          controller: _controller,
          textInputAction: TextInputAction.search,
          autoFocus: true,
          labelText: 'Enter an email address',
          onChanged: (email) => context.read<CreateMeetingCubit>().emailChanged(email: email),
        );
      },
    );
  }
}

class _SearchResult extends StatelessWidget {
  const _SearchResult({required TextEditingController controller}) : _controller = controller;

  final TextEditingController _controller;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateMeetingCubit, CreateMeetingState>(
      builder: (context, state) {
        if (state.email.valid) {
          return _AddParticipantsCard(
            child: _AddParticipantListTile(
              title: state.email.value,
              onTap: () {
                if (context.read<CreateMeetingCubit>().addParticipantToParticipants(email: state.email.value)) {
                  _controller.clear();
                }
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _ParticipantList extends StatelessWidget {
  const _ParticipantList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateMeetingCubit, CreateMeetingState>(
      builder: (context, state) {
        if (state.participants.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Participants',
                style: context.textTheme.bodyLarge,
              ),
              ListView.separated(
                shrinkWrap: true,
                separatorBuilder: (context, index) => SizedBox(
                  height: context.lowValue,
                ),
                itemCount: state.participants.length,
                itemBuilder: (context, index) {
                  return _AddParticipantsCard(
                    child: _AddParticipantListTile(
                      title: state.participants[index],
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => context
                            .read<CreateMeetingCubit>()
                            .removeParticipantFromParticipants(email: state.participants[index]),
                      ),
                    ),
                  );
                },
              )
            ].withSpaceBetween(height: context.mediumValue),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _AddParticipantsCard extends StatelessWidget {
  const _AddParticipantsCard({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      shape: OutlineInputBorder(
        borderSide: BorderSide(color: context.theme.dividerColor),
      ),
      child: child,
    );
  }
}

class _AddParticipantListTile extends StatelessWidget {
  const _AddParticipantListTile({
    required this.title,
    this.trailing,
    this.onTap,
  });

  final String title;
  final Widget? trailing;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: context.paddingAllLow,
      title: Text(title),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
