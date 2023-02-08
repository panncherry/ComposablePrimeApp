//
//  WolframAlphaResult.swift
//  ComposablePrimeApp
//
//  Created by Pann Cherry on 1/28/23.
//

import SwiftUI

struct WolframAlphaResult: Decodable {
  let queryresult: QueryResult

  struct QueryResult: Decodable {
    let pods: [Pod]

    struct Pod: Decodable {
      let primary: Bool?
      let subpods: [SubPod]

      struct SubPod: Decodable {
        let plaintext: String
      }
    }
  }
}
