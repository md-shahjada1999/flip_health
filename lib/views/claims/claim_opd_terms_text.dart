/// OPD claim terms (plain text, aligned with patient_app `AddClaimsNewController` HTML).
abstract final class ClaimOpdTermsText {
  static const String title = 'General Terms & Conditions for OPD Claims';

  static const String body = '''
Please read the following terms carefully before submitting a claim under your OPD (Outpatient Department) benefits.

1. Scope of Coverage
Claims must fall strictly under OPD benefits and as defined within your policy. Only covered services, as outlined in the policy, are eligible for reimbursement.

2. Documentation Requirements
Users must submit genuine and complete documentation, including valid prescriptions, invoices and bills, and diagnostic or lab reports where applicable. The invoice must clearly itemize all services and products purchased. Incomplete submissions may lead to claim rejection.

3. Timelines
All claims must be submitted within 30 days from the invoice date. Late submissions will not be considered and may result in claim rejection.

4. Review & Processing
Submitted claims will be reviewed and verified for eligibility. Processing time may vary based on the nature and completeness of the claim. Submission of a claim does not guarantee reimbursement.

5. Fraud & Rejection
Incomplete, falsified, or manipulated claims will be rejected and may be reported to relevant authorities.

6. Data Accuracy & Privacy
You are responsible for the accuracy and authenticity of all data and documents uploaded. Personal data is collected for claim processing and handled according to our privacy practices.

7. Policy Updates
These terms may be updated from time to time. Continued use of the service implies acceptance of the latest terms.
''';
}

/// Shown before moving to bill entry (patient_app `step1PopupTermsNConditionsBS`).
abstract final class ClaimStep1ImportantNoteText {
  static const String title = 'Important Note:';

  static const String part1 =
      'Claims will be rejected if any details are incomplete or do not match the bill or service. Please ensure all details are filled out ';

  static const String part1Bold = 'accurately and thoroughly.\n\n';

  static const String part2 =
      'Claims will be processed only if the bill includes the correct address, service type, bill amount, and payment receipt (if required) and ';

  static const String part2Bold = 'is submitted within 30 days from the bill date.';
}
