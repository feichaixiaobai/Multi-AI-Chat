import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/chat_provider.dart';
import '../models/message.dart';

class ModelSelector extends StatelessWidget {
  const ModelSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.psychology, size: 20),
              const SizedBox(width: 8),
              const Text(
                'AI模型:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: AIModel.values.map((model) {
                      final isSelected = chatProvider.selectedModel == model;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(model.displayName),
                          selected: isSelected,
                          onSelected: (_) => chatProvider.setModel(model),
                          selectedColor: model.color.withOpacity(0.3),
                          backgroundColor: Colors.grey.withOpacity(0.1),
                          labelStyle: TextStyle(
                            color: isSelected ? model.color : null,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          avatar: isSelected
                              ? Icon(Icons.check_circle, color: model.color, size: 18)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}