import 'package:tcs_e_office/feature/private_app_shell/leave_management/domain/repositories/leave_repository_interface.dart';

class GetDepartmentsUseCase {
  final LeaveRepositoryInterface repository;
  GetDepartmentsUseCase(this.repository);

  Future<List<String>> call() {
    return repository.getDepartmentNames();
  }
}
