

import 'package:tpm_prak_final/api/base_network.dart';

class DataSource {
  static DataSource instance = DataSource();

  Future<List<dynamic>> loadAnimeList(String category, String orderBy, String sort){

    if(category == 'Movie' || category == 'TV') {
      return BaseNetwork.getSearch('type', category, orderBy, sort);
    }
    else if(category == 'Airing' || category == 'Upcoming' || category == 'Completed'){
      return BaseNetwork.getSearch('status', category, orderBy, sort);
    }
    else {
      return BaseNetwork.getTop();
    }
  }
}