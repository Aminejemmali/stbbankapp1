import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

Future<void> sendWelcomeEmail(
    String email, String password, String nom, String prenom) async {
  final smtpServer = gmail('houilinour@gmail.com', 'jhcb srfj lqva gmaq');

  final message = Message()
    ..from = Address('STB-email@gmail.com', 'RapidBankBooking')
    ..recipients.add(email)
    ..subject = 'Bienvenue sur RapidBankBooking'
    ..text = 'Bienvenue sur RapidBankBooking!\n\n'
        'Nom: $nom\n'
        'Prénom: $prenom\n'
        'Votre adresse e-mail: $email\n'
        'Votre mot de passe: $password\n\n'
        'Merci de vous être inscrit sur RapidBankBooking.';

  try {
    final sendReport = await send(message, smtpServer);
    print('Message sent: ' + sendReport.toString());
  } catch (e) {
    print('Error sending welcome email: $e');
    // Gérer les erreurs d'envoi d'e-mail ici
  }
}
