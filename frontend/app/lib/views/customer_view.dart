import "package:aw40_hub_frontend/data_sources/customer_data_table_source.dart";
import "package:aw40_hub_frontend/exceptions/app_exception.dart";
import "package:aw40_hub_frontend/models/customer_model.dart";
import "package:aw40_hub_frontend/providers/customer_provider.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:aw40_hub_frontend/views/customer_detail_view.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:logging/logging.dart";
import "package:provider/provider.dart";

class CustomerView extends StatefulWidget {
  const CustomerView({
    super.key,
  });

  @override
  State<CustomerView> createState() => _CustomerViewState();
}

class _CustomerViewState extends State<CustomerView> {
  final currentCustomerIndexNotifier = ValueNotifier<int?>(null);
  Logger customViewLogger = Logger("CustomerViewLogger");

  @override
  void dispose() {
    currentCustomerIndexNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // ignore: discarded_futures
      future: Provider.of<CustomerProvider>(context).getCustomers(0, 30),
      builder:
          (BuildContext context, AsyncSnapshot<List<CustomerModel>> snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final List<CustomerModel>? customerModels = snapshot.data;
        if (customerModels == null) {
          throw AppException(
            exceptionType: ExceptionType.notFound,
            exceptionMessage: "Received no customers.",
          );
        }
        return Row(
          children: [
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                child: PaginatedDataTable(
                  source: CustomerDataTableSource(
                    themeData: Theme.of(context),
                    currentIndexNotifier: currentCustomerIndexNotifier,
                    customerModels: customerModels,
                    onPressedRow: (int i) {
                      currentCustomerIndexNotifier.value = i;
                    },
                  ),
                  showCheckboxColumn: false,
                  rowsPerPage: 50,
                  columns: [
                    DataColumn(label: Text(tr("general.id"))),
                    DataColumn(label: Text(tr("general.firstname"))),
                    DataColumn(label: Text(tr("general.lastname"))),
                    DataColumn(label: Text(tr("general.email"))),
                    DataColumn(label: Text(tr("general.phone"))),
                    DataColumn(label: Text(tr("general.street"))),
                    DataColumn(label: Text(tr("general.housenumber"))),
                    DataColumn(label: Text(tr("general.postcode"))),
                    DataColumn(label: Text(tr("general.city"))),
                  ],
                ),
              ),
            ),

            // Show detail view if a customer is selected.
            ValueListenableBuilder(
              valueListenable: currentCustomerIndexNotifier,
              builder: (context, value, child) {
                if (value == null) return const SizedBox.shrink();
                return Expanded(
                  flex: 2,
                  child: CustomerDetailView(
                    customerModel: customerModels[value],
                    onClose: () => currentCustomerIndexNotifier.value = null,
                  ),
                );
              },
            )
          ],
        );
      },
    );
  }
}
