import 'package:flutter/material.dart';
import 'package:sivi_chat/locator.dart';
import 'package:sivi_chat/services/api_service.dart';

class MeaningSheet extends StatefulWidget {
  final String word;

  const MeaningSheet({required this.word});

  @override
  State<MeaningSheet> createState() => _MeaningSheetState();
}

class _MeaningSheetState extends State<MeaningSheet> {
  String? meaning;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMeaning();
  }

  Future<void> _loadMeaning() async {
    final apiService = locator<ApiService>();
    final result = await apiService.getMeaning(widget.word.toLowerCase());

    if (!mounted) return;

    setState(() {
      meaning = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.word,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                if (isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  Text(
                    meaning ?? '',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
