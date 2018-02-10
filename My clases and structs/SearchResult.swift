//
//  SearchResult.swift
//  StoreSearch
//
//  Created by getTrickS2 on 2/8/18.
//  Copyright © 2018 Nik's. All rights reserved.
//


class SearchResult {
    var name = ""
    var artistName = ""
    var artworkSmallURL = ""
    var artworkLargeURL = ""
    var storeURL = ""
    var kind = ""
    var currency = ""
    var price = 0.0
    var genre = ""
}

func < (lhs: SearchResult, rhs: SearchResult) -> Bool {
    return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
}
