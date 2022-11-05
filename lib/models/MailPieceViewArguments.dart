import 'package:summer2022/models/MailPiece.dart';
import 'package:summer2022/models/Digest.dart';

class MailPieceViewArguments {
  final MailPiece mailPiece;
  final Digest? digest;

  MailPieceViewArguments(this.mailPiece, [this.digest = null]);

}