/// Response from `GET /patient/reimbursement/:id` (patient_app: `data` + `status_steps`).
class ClaimDetailBundle {
  final Map<String, dynamic> data;
  final List<Map<String, dynamic>> statusSteps;

  ClaimDetailBundle({
    required this.data,
    required this.statusSteps,
  });
}
