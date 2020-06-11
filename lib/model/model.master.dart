class CashTitleModel{
  final int titleid;
  final String titlename;
  final DateTime updateDate;
  final bool candelete;

  CashTitleModel(
      {this.titleid, this.titlename, this.updateDate, this.candelete});
}

class StockItemModel {
  final String itemcode;
  final String itemname;
  final String chemicalname;
  final String companyname;

  StockItemModel(
      {this.itemcode, this.itemname, this.chemicalname, this.companyname});
}

class PacketTypeModel {
  final String typecode;
  final String typename;
  final int capacity;

  PacketTypeModel({this.typecode, this.typename, this.capacity});
}

class ShopModel {
  final int shopid;
  final String shopname;

  ShopModel({this.shopid, this.shopname});
}

class SupplierModel {
  final String supplierid;
  final String company;
  final String contactname;
  final String address;
  final String phone;
  final int balance;
  final DateTime updatedate;

  SupplierModel(
      {this.supplierid,
      this.company,
      this.contactname,
      this.address,
      this.phone,
      this.balance,
      this.updatedate});
}
