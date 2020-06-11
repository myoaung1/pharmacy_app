class ExpenseModel {
  final String expenseid;
  final DateTime date;
  final int titleid;
  final String titlename;
  final double amount;
  final String username;
  final String description;

  ExpenseModel({
    this.expenseid,
    this.date,
    this.titleid,
    this.titlename,
    this.amount,
    this.username,
    this.description,
  });
}
