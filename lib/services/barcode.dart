import 'package:flutter_qr_bar_scanner_example/services/networking.dart';

const UPCURL = 'https://api.upcitemdb.com/prod/trial/lookup?upc=';
const apiKey = '0e5be670-1552-11eb-a889-d7aa2024a686';
const GSURL = 'https://app.zenserp.com/api/v2/search?q=';
const VSURL = 'https://app.zenserp.com/api/v2/search?apikey=';

class BarcodeModel {
  Future<dynamic> getBarcode(String bc) async {
    NetworkHelper networkHelper = NetworkHelper('$UPCURL$bc');

    var barcodeData = await networkHelper.getData();
    return barcodeData;
  }

  Future<dynamic> getLink(String q, String k) async {
    NetworkHelper networkHelper = NetworkHelper('$GSURL$q$k&apikey=$apiKey');

    var linkData = await networkHelper.getData();
    return linkData;
  }

  Future<dynamic> getVideoLink(String q, String k) async {
    NetworkHelper networkHelper = NetworkHelper('$VSURL$apiKey&q=$q$k&tbm=vid');

    var linkData = await networkHelper.getData();
    return linkData;
  }
}
