import 'package:enough_mail/enough_mail.dart';
import 'package:summer2022/models/Digest.dart';


class MailPiece{
  String ID;
  String EmailID;
  DateTime TimeStamp = new DateTime(2022,1,1);
  String Sender;
  String MidID;
  String ImageText;
  MailPiece(this.ID, this.EmailID, this.MidID, this.ImageText, this.Sender, this.TimeStamp);
}

class MailService{

   List fetchMail(String keyword, DateTime? startDate, DateTime? endDate){
     List<MailPiece> mail = <MailPiece>[new MailPiece("","","","","test",DateTime.now())];
     mail = GetMailByKeyword(GetMailByDate(mail, startDate, endDate), keyword);

    return mail;
  }
  List<MailPiece> GetMailByKeyword(List<MailPiece> mail, String keyword){
     List<MailPiece> filteredMail = mail.where((x)=>x.Sender.contains(keyword) || x.ImageText.contains(keyword)).toList();
     return filteredMail;
  }

   List<MailPiece> GetMailByDate(List<MailPiece> mail, DateTime? startDate, DateTime? endDate){
     List<MailPiece> filteredMail = mail.where((x)=>(startDate == null || x.TimeStamp.isAfter(startDate)) && (endDate == null || x.TimeStamp.isBefore(endDate))).toList();
     return filteredMail;
   }
}

