import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class CreateMatchForm extends StatefulWidget {
  final TextEditingController descriptionController;
  final DateTime? matchDate;
  final TimeOfDay? matchTime;
  final TimeOfDay? endTime;
  final TextEditingController addressController;
  final TextEditingController numberOfPlayersController;
  final Future<void> Function(DateTime?, TimeOfDay?, TimeOfDay?) createMatch;
  final void Function(String) autoCompleteAddress;

  const CreateMatchForm({
    Key? key,
    required this.descriptionController,
    required this.matchDate,
    required this.matchTime,
    required this.endTime,
    required this.addressController,
    required this.numberOfPlayersController,
    required this.createMatch,
    required this.autoCompleteAddress,
  }) : super(key: key);

  @override
  _CreateMatchFormState createState() => _CreateMatchFormState();
}

class _CreateMatchFormState extends State<CreateMatchForm> {
  DateTime? _matchDate;
  TimeOfDay? _matchTime;
  TimeOfDay? _endTime;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _matchDate = widget.matchDate;
    _matchTime = widget.matchTime;
    _endTime = widget.endTime;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Créer un match',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: widget.descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: _matchDate ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2101),
              locale: const Locale('fr', 'FR'),
            );
            if (pickedDate != null) {
              setState(() {
                _matchDate = pickedDate;
              });
            }
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Sélectionner la date',
              border: OutlineInputBorder(),
            ),
            child: Text(
              _matchDate != null ? DateFormat('dd/MM/yyyy').format(_matchDate!) : 'Date',
            ),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: _matchTime ?? TimeOfDay.now(),
            );
            if (pickedTime != null) {
              setState(() {
                _matchTime = pickedTime;
              });
            }
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Sélectionner l\'heure de début',
              border: OutlineInputBorder(),
            ),
            child: Text(
              _matchTime != null ? _matchTime!.format(context) : 'Heure de début',
            ),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: _endTime ?? TimeOfDay.now(),
            );
            if (pickedTime != null) {
              setState(() {
                _endTime = pickedTime;
              });
            }
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Sélectionner l\'heure de fin',
              border: OutlineInputBorder(),
            ),
            child: Text(
              _endTime != null ? _endTime!.format(context) : 'Heure de fin',
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: widget.addressController,
          decoration: const InputDecoration(
            labelText: 'Adresse',
            border: OutlineInputBorder(),
          ),
          onChanged: (query) {
            if (_debounce?.isActive ?? false) _debounce!.cancel();
            _debounce = Timer(const Duration(seconds: 1), () {
              widget.autoCompleteAddress(query);
            });
          },
        ),
        const SizedBox(height: 8),
        TextField(
          controller: widget.numberOfPlayersController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Nombre de joueurs',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            await widget.createMatch(_matchDate, _matchTime, _endTime);
          },
          child: const Text(
            'Créer le match',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}