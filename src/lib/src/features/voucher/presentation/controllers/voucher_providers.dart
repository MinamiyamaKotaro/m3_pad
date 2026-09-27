import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/utils/id_generator.dart';
import '../../data/datasources/customer_local_datasource.dart';
import '../../data/datasources/daily_payment_summary_local_datasource.dart';
import '../../data/datasources/header_local_datasource.dart';
import '../../data/datasources/header_price_local_datasource.dart';
import '../../data/datasources/header_type_local_datasource.dart';
import '../../data/datasources/sheet_cell_local_datasource.dart';
import '../../data/datasources/sheet_instance_local_datasource.dart';
import '../../data/datasources/sheet_row_local_datasource.dart';
import '../../data/datasources/sheet_template_local_datasource.dart';
import '../../data/datasources/staff_local_datasource.dart';
import '../../data/datasources/staff_shift_local_datasource.dart';
import '../../data/repositories/customer_repository_impl.dart';
import '../../data/repositories/daily_payment_summary_repository_impl.dart';
import '../../data/repositories/header_price_repository_impl.dart';
import '../../data/repositories/header_repository_impl.dart';
import '../../data/repositories/header_type_repository_impl.dart';
import '../../data/repositories/sheet_cell_repository_impl.dart';
import '../../data/repositories/sheet_instance_repository_impl.dart';
import '../../data/repositories/sheet_row_repository_impl.dart';
import '../../data/repositories/sheet_template_repository_impl.dart';
import '../../data/repositories/staff_repository_impl.dart';
import '../../data/repositories/staff_shift_repository_impl.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../domain/repositories/daily_payment_summary_repository.dart';
import '../../domain/repositories/header_price_repository.dart';
import '../../domain/repositories/header_repository.dart';
import '../../domain/repositories/header_type_repository.dart';
import '../../domain/repositories/sheet_cell_repository.dart';
import '../../domain/repositories/sheet_instance_repository.dart';
import '../../domain/repositories/sheet_row_repository.dart';
import '../../domain/repositories/sheet_template_repository.dart';
import '../../domain/repositories/staff_repository.dart';
import '../../domain/repositories/staff_shift_repository.dart';
import '../../domain/usecases/add_header_usecase.dart';
import '../../domain/usecases/add_row_usecase.dart';
import '../../domain/usecases/create_template_usecase.dart';
import '../../domain/usecases/export_daily_sheet_to_csv_usecase.dart';
import '../../domain/usecases/get_sheet_detail_usecase.dart';
import '../../domain/usecases/input_cell_usecase.dart';
import '../../domain/usecases/open_sheet_instance_usecase.dart';
import '../../domain/usecases/update_row_usecase.dart';
import '../../domain/usecases/update_staff_shift_usecase.dart';

/// [IdGenerator] を提供するプロバイダ。
final Provider<IdGenerator> idGeneratorProvider = Provider<IdGenerator>(
  (final Ref ref) => const IdGenerator(),
);

// ---------- データソース ----------

final Provider<HeaderTypeLocalDataSource> _headerTypeDataSourceProvider =
    Provider<HeaderTypeLocalDataSource>(
  (final Ref ref) => HeaderTypeLocalDataSource(ref.watch(databaseProvider)),
);

final Provider<HeaderLocalDataSource> _headerDataSourceProvider =
    Provider<HeaderLocalDataSource>(
  (final Ref ref) => HeaderLocalDataSource(ref.watch(databaseProvider)),
);

final Provider<HeaderPriceLocalDataSource> _headerPriceDataSourceProvider =
    Provider<HeaderPriceLocalDataSource>(
  (final Ref ref) => HeaderPriceLocalDataSource(ref.watch(databaseProvider)),
);

final Provider<SheetTemplateLocalDataSource> _sheetTemplateDataSourceProvider =
    Provider<SheetTemplateLocalDataSource>(
  (final Ref ref) => SheetTemplateLocalDataSource(ref.watch(databaseProvider)),
);

final Provider<SheetInstanceLocalDataSource> _sheetInstanceDataSourceProvider =
    Provider<SheetInstanceLocalDataSource>(
  (final Ref ref) => SheetInstanceLocalDataSource(ref.watch(databaseProvider)),
);

final Provider<CustomerLocalDataSource> _customerDataSourceProvider =
    Provider<CustomerLocalDataSource>(
  (final Ref ref) => CustomerLocalDataSource(ref.watch(databaseProvider)),
);

final Provider<StaffLocalDataSource> _staffDataSourceProvider =
    Provider<StaffLocalDataSource>(
  (final Ref ref) => StaffLocalDataSource(ref.watch(databaseProvider)),
);

final Provider<StaffShiftLocalDataSource> _staffShiftDataSourceProvider =
    Provider<StaffShiftLocalDataSource>(
  (final Ref ref) => StaffShiftLocalDataSource(ref.watch(databaseProvider)),
);

final Provider<SheetRowLocalDataSource> _sheetRowDataSourceProvider =
    Provider<SheetRowLocalDataSource>(
  (final Ref ref) => SheetRowLocalDataSource(ref.watch(databaseProvider)),
);

final Provider<SheetCellLocalDataSource> _sheetCellDataSourceProvider =
    Provider<SheetCellLocalDataSource>(
  (final Ref ref) => SheetCellLocalDataSource(ref.watch(databaseProvider)),
);

final Provider<DailyPaymentSummaryLocalDataSource>
    _dailyPaymentSummaryDataSourceProvider =
    Provider<DailyPaymentSummaryLocalDataSource>(
  (final Ref ref) =>
      DailyPaymentSummaryLocalDataSource(ref.watch(databaseProvider)),
);

// ---------- リポジトリ ----------

/// [HeaderTypeRepository] を提供するプロバイダ。
final Provider<HeaderTypeRepository> headerTypeRepositoryProvider =
    Provider<HeaderTypeRepository>(
  (final Ref ref) =>
      HeaderTypeRepositoryImpl(ref.watch(_headerTypeDataSourceProvider)),
);

/// [HeaderRepository] を提供するプロバイダ。
final Provider<HeaderRepository> headerRepositoryProvider =
    Provider<HeaderRepository>(
  (final Ref ref) => HeaderRepositoryImpl(ref.watch(_headerDataSourceProvider)),
);

/// [HeaderPriceRepository] を提供するプロバイダ。
final Provider<HeaderPriceRepository> headerPriceRepositoryProvider =
    Provider<HeaderPriceRepository>(
  (final Ref ref) =>
      HeaderPriceRepositoryImpl(ref.watch(_headerPriceDataSourceProvider)),
);

/// [SheetTemplateRepository] を提供するプロバイダ。
final Provider<SheetTemplateRepository> sheetTemplateRepositoryProvider =
    Provider<SheetTemplateRepository>(
  (final Ref ref) => SheetTemplateRepositoryImpl(
    ref.watch(_sheetTemplateDataSourceProvider),
  ),
);

/// [SheetInstanceRepository] を提供するプロバイダ。
final Provider<SheetInstanceRepository> sheetInstanceRepositoryProvider =
    Provider<SheetInstanceRepository>(
  (final Ref ref) => SheetInstanceRepositoryImpl(
    ref.watch(_sheetInstanceDataSourceProvider),
  ),
);

/// [CustomerRepository] を提供するプロバイダ。
final Provider<CustomerRepository> customerRepositoryProvider =
    Provider<CustomerRepository>(
  (final Ref ref) =>
      CustomerRepositoryImpl(ref.watch(_customerDataSourceProvider)),
);

/// [StaffRepository] を提供するプロバイダ。
final Provider<StaffRepository> staffRepositoryProvider =
    Provider<StaffRepository>(
  (final Ref ref) => StaffRepositoryImpl(ref.watch(_staffDataSourceProvider)),
);

/// [StaffShiftRepository] を提供するプロバイダ。
final Provider<StaffShiftRepository> staffShiftRepositoryProvider =
    Provider<StaffShiftRepository>(
  (final Ref ref) =>
      StaffShiftRepositoryImpl(ref.watch(_staffShiftDataSourceProvider)),
);

/// [SheetRowRepository] を提供するプロバイダ。
final Provider<SheetRowRepository> sheetRowRepositoryProvider =
    Provider<SheetRowRepository>(
  (final Ref ref) =>
      SheetRowRepositoryImpl(ref.watch(_sheetRowDataSourceProvider)),
);

/// [SheetCellRepository] を提供するプロバイダ。
final Provider<SheetCellRepository> sheetCellRepositoryProvider =
    Provider<SheetCellRepository>(
  (final Ref ref) =>
      SheetCellRepositoryImpl(ref.watch(_sheetCellDataSourceProvider)),
);

/// [DailyPaymentSummaryRepository] を提供するプロバイダ。
final Provider<DailyPaymentSummaryRepository>
    dailyPaymentSummaryRepositoryProvider =
    Provider<DailyPaymentSummaryRepository>(
  (final Ref ref) => DailyPaymentSummaryRepositoryImpl(
    ref.watch(_dailyPaymentSummaryDataSourceProvider),
  ),
);

// ---------- ユースケース ----------

/// [CreateTemplateUsecase] を提供するプロバイダ。
final Provider<CreateTemplateUsecase> createTemplateUsecaseProvider =
    Provider<CreateTemplateUsecase>(
  (final Ref ref) => CreateTemplateUsecase(
    templateRepository: ref.watch(sheetTemplateRepositoryProvider),
    idGenerator: ref.watch(idGeneratorProvider),
  ),
);

/// [AddHeaderUsecase] を提供するプロバイダ。
final Provider<AddHeaderUsecase> addHeaderUsecaseProvider =
    Provider<AddHeaderUsecase>(
  (final Ref ref) => AddHeaderUsecase(
    templateRepository: ref.watch(sheetTemplateRepositoryProvider),
    headerTypeRepository: ref.watch(headerTypeRepositoryProvider),
    headerRepository: ref.watch(headerRepositoryProvider),
    headerPriceRepository: ref.watch(headerPriceRepositoryProvider),
    idGenerator: ref.watch(idGeneratorProvider),
  ),
);

/// [OpenSheetInstanceUsecase] を提供するプロバイダ。
final Provider<OpenSheetInstanceUsecase> openSheetInstanceUsecaseProvider =
    Provider<OpenSheetInstanceUsecase>(
  (final Ref ref) => OpenSheetInstanceUsecase(
    templateRepository: ref.watch(sheetTemplateRepositoryProvider),
    instanceRepository: ref.watch(sheetInstanceRepositoryProvider),
    staffShiftRepository: ref.watch(staffShiftRepositoryProvider),
    idGenerator: ref.watch(idGeneratorProvider),
  ),
);

/// [GetSheetDetailUsecase] を提供するプロバイダ。
final Provider<GetSheetDetailUsecase> getSheetDetailUsecaseProvider =
    Provider<GetSheetDetailUsecase>(
  (final Ref ref) => GetSheetDetailUsecase(
    instanceRepository: ref.watch(sheetInstanceRepositoryProvider),
    headerRepository: ref.watch(headerRepositoryProvider),
    rowRepository: ref.watch(sheetRowRepositoryProvider),
    cellRepository: ref.watch(sheetCellRepositoryProvider),
    staffShiftRepository: ref.watch(staffShiftRepositoryProvider),
    dailyPaymentSummaryRepository: ref.watch(
      dailyPaymentSummaryRepositoryProvider,
    ),
    staffRepository: ref.watch(staffRepositoryProvider),
    customerRepository: ref.watch(customerRepositoryProvider),
    headerPriceRepository: ref.watch(headerPriceRepositoryProvider),
  ),
);

/// [AddRowUsecase] を提供するプロバイダ。
final Provider<AddRowUsecase> addRowUsecaseProvider = Provider<AddRowUsecase>(
  (final Ref ref) => AddRowUsecase(
    customerRepository: ref.watch(customerRepositoryProvider),
    staffRepository: ref.watch(staffRepositoryProvider),
    rowRepository: ref.watch(sheetRowRepositoryProvider),
    idGenerator: ref.watch(idGeneratorProvider),
  ),
);

/// [InputCellUsecase] を提供するプロバイダ。
final Provider<InputCellUsecase> inputCellUsecaseProvider =
    Provider<InputCellUsecase>(
  (final Ref ref) => InputCellUsecase(
    rowRepository: ref.watch(sheetRowRepositoryProvider),
    instanceRepository: ref.watch(sheetInstanceRepositoryProvider),
    headerRepository: ref.watch(headerRepositoryProvider),
    headerPriceRepository: ref.watch(headerPriceRepositoryProvider),
    cellRepository: ref.watch(sheetCellRepositoryProvider),
    idGenerator: ref.watch(idGeneratorProvider),
  ),
);

/// [UpdateRowUsecase] を提供するプロバイダ。
final Provider<UpdateRowUsecase> updateRowUsecaseProvider =
    Provider<UpdateRowUsecase>(
  (final Ref ref) => UpdateRowUsecase(
    rowRepository: ref.watch(sheetRowRepositoryProvider),
    customerRepository: ref.watch(customerRepositoryProvider),
    idGenerator: ref.watch(idGeneratorProvider),
  ),
);

/// [UpdateStaffShiftUsecase] を提供するプロバイダ。
final Provider<UpdateStaffShiftUsecase> updateStaffShiftUsecaseProvider =
    Provider<UpdateStaffShiftUsecase>(
  (final Ref ref) => UpdateStaffShiftUsecase(
    staffShiftRepository: ref.watch(staffShiftRepositoryProvider),
  ),
);

/// [ExportDailySheetToCsvUsecase] を提供するプロバイダ。
final Provider<ExportDailySheetToCsvUsecase>
    exportDailySheetToCsvUsecaseProvider =
    Provider<ExportDailySheetToCsvUsecase>(
  (final Ref ref) => ExportDailySheetToCsvUsecase(
    instanceRepository: ref.watch(sheetInstanceRepositoryProvider),
    headerRepository: ref.watch(headerRepositoryProvider),
    rowRepository: ref.watch(sheetRowRepositoryProvider),
    cellRepository: ref.watch(sheetCellRepositoryProvider),
  ),
);
