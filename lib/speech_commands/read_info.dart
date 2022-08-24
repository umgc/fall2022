import 'package:enough_mail/pop.dart';
import 'dart:io';
import 'package:global_configuration/global_configuration.dart';
import 'package:summer2022/models/MailResponse.dart';
import 'package:summer2022/models/Address.dart';
import 'package:summer2022/models/Logo.dart';
import 'package:summer2022/models/Digest.dart';
import 'package:summer2022/main.dart';


/*
 * The ReadDigestMail class's purpose is to read the details of a Daily Digest mail 
 */
class ReadDigestMail {
  late MailResponse currentMail;
  AddressObject? sender;
  AddressObject? recipient;
  List<Link> links = <Link>[];

  void setCurrentMail(MailResponse mail) {
    currentMail = mail;
    setSenderAndRecipient(currentMail.addresses);
  }

  void setSenderAndRecipient(List<AddressObject> addresses) {
    sender = null;
    recipient = null;
    for(int x = 0; x < addresses.length; x++) {
      if(addresses[x].type == "sender" && sender == null) {
        sender = addresses[x];
      } else if(addresses[x].type == "recipient" && recipient == null) {
        recipient = addresses[x];
      }
    }
  }

  List<AddressObject> getSenderAndRecipient() {
    return [sender!, recipient!];
  }

  // Use this function if you want to read all the details. If you want a specific detail, use the other functions
  Future<bool> readDigestInfo() async {
    String senderString = '';
    String recipientString = '';
    String validatedSender = '';
    String validatedRecipient = '';
    String senderAddress = '';
    String recipientAddress = '';
    String logos = '';
    String digestLinks = '';
    if (GlobalConfiguration().getValue("sender") && sender != null) {
      senderString = getDigestSenderName();
    }
    if (GlobalConfiguration().getValue("recipient") && recipient != null) {
      recipientString = getDigestRecipientName();
    }
    if (GlobalConfiguration().getValue("validated")) {
      if(sender != null) {
        validatedSender = getDigestSenderAddressValidated();
      }
      if(recipient != null) {
        validatedRecipient = getDigestRecipientAddressValidated();
      }
    }
    if (GlobalConfiguration().getValue("address")) {
      if(sender != null) {
        senderAddress = getDigestSenderAddress();
      }
      if(recipient != null) {
        recipientAddress = getDigestRecipientAddress();
      }
    }
    if (GlobalConfiguration().getValue("logos")) {
      logos = getDigestLogos();
    }
    if (GlobalConfiguration().getValue("links")) {
      digestLinks = getDigestLinks();
    }
    String read = '$senderString $senderAddress $validatedSender $recipientString $recipientAddress $validatedRecipient $logos $digestLinks';
    var result = await speak(read);

    return true;  
  }

  String getDigestSenderName() {
    return "The sender is '${sender!.name}'";
  }

  void readDigestSenderName() async {
    /* Get the name of the sender */
    String text = getDigestSenderName();
    var result = await speak(text);
  }

  String getDigestRecipientName() {
    return "The recipient is '${recipient!.name}'";
  }

  void readDigestRecipientName() async {
    /* Get the name of the recipient */
    String text = getDigestRecipientName();
    var result = await speak(text);
  }

  String getDigestSenderAddress() {
    return "The sender's address is '${sender!.address}'";
  }

  void readDigestSenderAddress() async {
    /* Get the sender's address */
    String text = getDigestSenderAddress();
    var result = await speak(text);
  }

  String getDigestRecipientAddress() {
    return "The recipient's address is '${recipient!.address}'";
  }

  void readDigestRecipientAddress() async {
    /* Get the recipient's address */
    String text = getDigestRecipientAddress();
    var result = await speak(text);
  }

  String getDigestLogos() {
    String text = "The logos are";
    if (currentMail.logos.isEmpty) {
      return "There are no logos.";
    }
    for (LogoObject logo in currentMail.logos) {
      text = "$text ${logo.name}";
    }
    return text;
  }

  void readDigestLogos() async {
    /* Get the logos */
      String text = getDigestLogos();
      var result = await speak(text);
  }

  String getDigestLinks() {
    String text = "The links are";
    if (links.isEmpty) {
      return "There are no links.";
    }
    for (Link code in links) {
      text = '$text ${code.info != "" ? code.info : code.link}';
    }
    return text;
  }

  void readDigestLinks() async {
    /* Get the links */
    String text = getDigestLinks();
    var result = await speak(text);
  }

  String getDigestSenderAddressValidated() {
    String validated = "was not";

    if (sender!.validated) {
      validated = "was";
    }
    String text = "The sender's address $validated validated";
    return text;
  }
  
  void readDigestSenderAddressValidated() async {
    /* Get if the sender's address was validated */
   String text = getDigestSenderAddressValidated();
    var result = await speak(text);
  }

  String getDigestRecipientAddressValidated() {
    String validated = "was not";

    if (recipient!.validated) {
      validated = "was";
    }
    String text = "The recipient's address $validated validated";
    return text;
  }

  void readDigestRecipientAddressValidated() async {
    /* Get if the recipient's address was validated */
    String text = getDigestRecipientAddressValidated();
    var result = await speak(text);
  }
}

/*
 * The ReadMail class's purpose is to read the details of an email that is not a Daily Digest 
 */
class ReadMail {
  late MimeMessage currentMail;

  void setCurrentMail(MimeMessage mail) {
    currentMail = mail;
  }

  // Use this function if you want to read all the details. If you want a specific detail, use the other functions
  Future<bool> readEmailInfo() async {
    String subject = '';
    String text = '';
    String sender = '';
    String recipient = '';
    if (GlobalConfiguration().getValue("email_subject")) {
      subject = getEmailSubject();
    }
    if (GlobalConfiguration().getValue("email_text")) {
      text = getEmailText();
    }
    if (GlobalConfiguration().getValue("email_sender")) {
      sender = getEmailSender();
    }
    if (GlobalConfiguration().getValue("email_recipients")) {
      recipient = getEmailRecipients();
    }
    String read = '$subject $text $sender $recipient';
    var result = await speak(read);
    return true;
  }

  String getEmailSubject() {
    var subject = currentMail.decodeSubject();
    if (subject != null) {
      return "The email subject is $subject";
    } else{
      return "There is no email subject.";
    }
  }

  void readEmailSubject() async {
    var text = getEmailSubject();
    var result = await speak(text);
  }

  String getEmailText() {
    var emailText = currentMail.body;
    if (emailText != null) {
      return "The email text is $emailText";
    } else{
      return "There is no email text.";
    }
  }

  void readEmailText() async {
    String text = getEmailText();
    var result = await speak(text);
  }

  String getEmailSender() {
    var sender = currentMail.decodeSender();
    if (sender.isNotEmpty) {
      return "The email sender is $sender";
    } else{
      return "There is no email sender.";
    }
  }

  void readEmailSender() async {
    String text = getEmailSender();
    var result = await speak(text);
  }

  String getEmailRecipients() {
    List<String?> recipients = [];
    for (MailAddress recipient in currentMail.recipients) {
      if (recipient.hasPersonalName) {
        recipients.add(recipient.personalName);
      } else {
        recipients.add(recipient.mailboxName);
      }
    }
    if (recipients.length > 1) { // Fix for grammar
      recipients[recipients.length-1] = "and ${recipients[recipients.length-1]}";
    }
    recipients.join(', ');
    if (recipients.isNotEmpty) {
      String? recipientsString = recipients[0];
      return "The email recipients are $recipientsString";
    } else {
      return "There are no email recipients.";
    }
  }

  Future<void> readEmailRecipients() async {
    String text = getEmailRecipients();
    var result = await speak(text);
  }
}

class CommandTutorial {
  String tutorial =
    '''
    Welcome to the USPS Visual Assistance App.
    To skip the voice command tutorial this time, say skip.
    To turn off the voice command tutorial so it does not play at startup, say off.
    Currently you are on the main page. You can navigate to the Digest page, Email page, and settings through a series of commands.
    ''';

  String main =
    '''
    To sign out of your account, say sign out.
    To navigate to the settings page, say settings.
    ''';

  String digest =
    '''
    To navigate to the digest page, there are two voice command options.
    Option 1 is to get the latest digest, by saying latest digest.
    Option 2 is to get a digest for a specific date, by saying digest date followed by the date.
    ''';

  String email =
    '''
    To navigate to the email page, there are three voice command options.
    Option 1 is to get emails for a specific date, by saying email date followed by the date.
    Option 2 is to get the latest email, by saying latest email.
    Option 3 is to get emails you have not listened to yet, by saying unread email.
    ''';

  String digestAndEmail =
    '''
    When requesting digests or emails for a specific date, the date formatting is month, day, year.
    An example is June 10th 2022.
    When listening to digests or emails, say next to go to the next item and previous to go to the previous item.
    While on the digest or email page, to get all of the details for the current email or digest, say details.
    On the digest page, you can ask for the specific details: sender name, recipient name, sender address, recipient address, sender validated, recipient validated, logos, and hyperlinks.
    On the email page, you can ask for the specific email details: subject, text, sender, and recipients.
    On the digest and recipients pages, say help to receive more details on these options.
    ''';

  String general = 
    '''
    At any time, to stop the current audio, say stop.
    To turn the speakers off, say speakers off.
    To turn the speakers on, say speakers on.
    To mute the microphone, say mute.
    To unmute the microphone, say unmute.
    To go back to the previous page, say back.
    To get the list of commands for the page that you are currently on, say help.
    ''';

  bool runTutorial() {
    String readTutorial = '$tutorial $main $digest $email $digestAndEmail $general';
    speak(readTutorial);
    return true;
  }

  String mainHelp =
    '''
    To sign out of your account, say sign out.
    To navigate to the settings page, say settings.
    To navigate to the digest page, there are two voice command options.
    Option 1 is to get the latest mail, by saying latest digest.
    Option 2 is to get a digest for a specific date, by saying digest date followed by the date.
    To navigate to the email page, there are three voice command options.
    Option 1 is to get emails for a specific date, by saying email date followed by the date.
    Option 2 is to get the latest email, by saying latest email.
    Option 3 is to get emails you have no listened to yet, by saying unread email.
    To stop any current audio, say stop.
    To turn the speakers off, say speakers off.
    To turn the speakers on, say speakers on.
    To mute the microphone, say mute.
    To unmute the microphone, say unmute.
    To hear these commands again, say help.
    ''';

  String emailHelp =
    '''
    To go to the next email, say next.
    To go to the previous email, say previous.
    To get the details for the current email, say details.
    To get the current email subject, say subject.
    To get the current email text, say text.
    To get the current email sender, say sender.
    To get the current email recipients, say recipients.
    To go back to the main page, say back.
    To stop any current audio, say stop.
    To turn the speakers off, say speakers off.
    To turn the speakers on, say speakers on.
    To mute the microphone, say mute.
    To unmute the microphone, say unmute.
    To hear these commands again, say help.
    ''';

  String digestHelp =
    '''
    To go to the next digest, say next.
    To go to the previous digest, say previous.
    To get the details for the current digest, say details.
    To get sender's name for the current digest, say sender name.
    To get recipients's name for the current digest, say recipient name.
    To get sender's address for the current digest, say sender address.
    To get recipient's address for the current digest, say recipient address.
    To get if the sender's address for the current digest was validated, say sender validated.
    To get if the recipient's address for the current digest was validated, say recipient validated.
    To get the logos for the current digest, say logos.
    To get the hyperlinks for the current digest, say hyperlinks.
    To go back to the main page, say back.
    To stop any current audio, say stop.
    To turn the speakers off, say speakers off.
    To turn the speakers on, say speakers on.
    To mute the microphone, say mute.
    To unmute the microphone, say unmute.
    To hear these commands again, say help.
    ''';

  String settingsHelp =
    '''
    The following commands allow you to customize the details that you are told by default for digests and emails.
    To turn on the sender default, say sender on.
    To turn off the sender default, say sender off.
    To turn on the recipient default, say recipient on.
    To turn off the recipient default, say recipient off.
    To turn on the logos default, say logos on.
    To turn off the logos default, say logos off.
    To turn on the hyperlinks default, say hyperlinks on.
    To turn off the hyperlinks default, say hyperlinks off.
    To turn on the address default, say address on.
    To turn off the address default, say address off.
    To turn on the email subject default, say email subject on.
    To turn off the email subject default, say email subject off.
    To turn on the email text default, say email text on.
    To turn off the email text default, say email text off.
    To turn on the email sender address default, say email sender address on.
    To turn off the email sender address default, say email sender address off.
    To turn on the email recipients default, say email recipients on.
    To turn off the email recipients default, say email recipients off.
    To turn on autoplay so that the digests and emails are automatically played through, say autoplay on.
    To turn off autoplay so that you have to say next to navigate through the digests and emails, say autoplay off.
    To go back to the main page, say back.
    To stop any current audio, say stop.
    To turn the speakers off, say speakers off.
    To turn the speakers on, say speakers on.
    To mute the microphone, say mute.
    To unmute the microphone, say unmute.
    To hear these commands again, say help.
    ''';

    Future<bool> getMainHelp() async {
      var result = await speak(mainHelp);
      return true;
    }

    Future<bool> getEmailHelp() async {
      var result = await speak(emailHelp);
      return true;
    }

    Future<bool> getDigestHelp() async {
      var result = await speak(digestHelp);
      return true;
    }

    Future<bool> getSettingsHelp() async {
      var result = await speak(settingsHelp);
      return true;
    }
}
