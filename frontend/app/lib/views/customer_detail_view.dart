import "package:aw40_hub_frontend/dialogs/update_customer_dialog.dart";
import "package:aw40_hub_frontend/dtos/customer_update_dto.dart";
import "package:aw40_hub_frontend/models/customer_model.dart";
import "package:aw40_hub_frontend/providers/customer_provider.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

class CustomerDetailView extends StatelessWidget {
  const CustomerDetailView({
    required this.customerModel,
    required this.onClose,
    super.key,
  });

  final CustomerModel customerModel;
  final void Function() onClose;

  @override
  Widget build(BuildContext context) {
    return DesktopCustomerDetailView(
      customerModel: customerModel,
      onClose: onClose,
      onDelete: () {},
    );
  }
}

class DesktopCustomerDetailView extends StatefulWidget {
  const DesktopCustomerDetailView({
    required this.customerModel,
    required this.onClose,
    required this.onDelete,
    super.key,
  });

  final CustomerModel customerModel;
  final void Function() onClose;
  final void Function() onDelete;

  @override
  State<DesktopCustomerDetailView> createState() =>
      _DesktopCustomerDetailViewState();
}

class _DesktopCustomerDetailViewState extends State<DesktopCustomerDetailView> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final customerProvider =
        Provider.of<CustomerProvider>(context, listen: false);

    final List<String> attributesCase = [
      tr("general.id"),
      tr("general.firstname"),
      tr("general.lastname"),
      tr("general.email"),
      tr("general.phone"),
      tr("general.street"),
      tr("general.housenumber"),
      tr("general.postcode"),
      tr("general.city"),
    ];
    final List<String> valuesCase = [
      widget.customerModel.id.toString(),
      widget.customerModel.firstname,
      widget.customerModel.lastname,
      widget.customerModel.email ?? "",
      widget.customerModel.phone ?? "",
      widget.customerModel.street ?? "",
      widget.customerModel.housenumber ?? "",
      widget.customerModel.postcode ?? "",
      widget.customerModel.city ?? "",
    ];

    return SizedBox.expand(
      child: SingleChildScrollView(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_double_arrow_right),
                      iconSize: 28,
                      onPressed: widget.onClose,
                      style: IconButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                      ),
                    ),
                    // const SizedBox(width: 16),
                    Text(
                      tr("cases.details.headline"),
                      style: textTheme.displaySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Table(
                  columnWidths: const {0: IntrinsicColumnWidth()},
                  children: List.generate(
                    attributesCase.length,
                    (i) => TableRow(
                      children: [
                        const SizedBox(height: 32),
                        Text(attributesCase[i]),
                        Text(valuesCase[i]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FilledButton.icon(
                      icon: const Icon(Icons.edit),
                      label: Text(tr("general.edit")),
                      onPressed: () async {
                        final CustomerUpdateDto? customerUpdateDto =
                            await _showUpdateCustomerDialog(
                          widget.customerModel,
                        );
                        if (customerUpdateDto == null) return;
                        // TODO check for Id?
                        await customerProvider.updateCustomer(
                          widget.customerModel.id.toString(),
                          customerUpdateDto,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<CustomerUpdateDto?> _showUpdateCustomerDialog(
    CustomerModel customerModel,
  ) async {
    return showDialog<CustomerUpdateDto>(
      context: context,
      builder: (BuildContext context) {
        return UpdateCustomerDialog(customerModel: customerModel);
      },
    );
  }
}
