import "package:aw40_hub_frontend/models/state_machine_log_entry_model.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:aw40_hub_frontend/utils/extensions.dart";
import "package:change_case/change_case.dart";
import "package:easy_localization/easy_localization.dart";
import "package:enum_to_string/enum_to_string.dart";
import "package:flutter/material.dart";
import "package:logging/logging.dart";

class StateMachineLogView extends StatelessWidget {
  const StateMachineLogView({required this.stateMachineLog, super.key});

  final List<StateMachineLogEntryModel> stateMachineLog;

  Icon _getIcon(StateMachineEvent event) {
    switch (event) {
      case StateMachineEvent.stateTransition:
        return const Icon(Icons.autorenew);
      case StateMachineEvent.retrievedDataSet:
        return const Icon(Icons.dataset);
      case StateMachineEvent.heatmaps:
      case StateMachineEvent.causalGraphVisualizations:
        return const Icon(Icons.scatter_plot);
      case StateMachineEvent.faultPaths:
        return const Icon(Icons.check);
      case StateMachineEvent.diagnosisFailed:
        return const Icon(Icons.cancel);
      case StateMachineEvent.unknown:
        return const Icon(Icons.question_mark);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Logger logger = Logger("state_machine_log_table");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "State Machine Log",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            itemCount: stateMachineLog.length,
            separatorBuilder: (c, i) => const Divider(),
            itemBuilder: (context, index) {
              final int reverseIndex = stateMachineLog.length - index - 1;
              final String message = stateMachineLog[reverseIndex].message;
              final String eventString =
                  message.substringBefore(":").constantCaseToCamelCase();
              final StateMachineEvent event = EnumToString.fromString(
                    StateMachineEvent.values,
                    eventString,
                  ) ??
                  StateMachineEvent.unknown;
              if (event == StateMachineEvent.unknown) {
                logger.warning(
                  "Unknown event string: $eventString. Message: $message",
                );
              }

              final String infos = message.substringAfter(": ");

              // Special handling for state transition.
              if (event == StateMachineEvent.stateTransition) {
                final String oldState = infos
                    .substringBefore(" --- ")
                    .constantCaseToCamelCase()
                    .toSentenceCase();
                final String newState = infos
                    .substringAfter(" ---> ")
                    .constantCaseToCamelCase()
                    .toSentenceCase();
                final String transition = infos
                    .substringBetween(startDelimiter: "(", endDelimiter: ")")
                    .toUpperCase()
                    .constantCaseToCamelCase()
                    .toSentenceCase();
                return ListTile(
                  isThreeLine: true,
                  title: Text("${tr('general.state')}: $newState"),
                  subtitle: Table(
                    columnWidths: const {0: IntrinsicColumnWidth()},
                    children: [
                      TableRow(
                        children: [
                          Text("${tr("general.previous")}: "),
                          Text(oldState),
                        ],
                      ),
                      TableRow(
                        children: [
                          Text("${tr("general.transition")}: "),
                          Text(transition),
                        ],
                      ),
                    ],
                  ),
                  leading: _getIcon(event),
                );
              }
              return ListTile(
                title: Text(event.name.toSentenceCase()),
                subtitle: Text(infos),
                leading: _getIcon(event),
              );
            },
          ),
        ),
      ],
    );
  }
}
