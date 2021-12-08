//
//  DataSnapshotExtension.swift
//  DataSnapshotExtension
//
//  Created by Leonardo Angeli on 28/08/21.
//

import SwiftUI
import Foundation
import FirebaseDatabase

extension DataSnapshot {
  /// Retrieves the value of a snapshot and converts it to an instance of
  /// caller-specified type.
  /// Throws `DecodingError.valueNotFound`
  /// if the document does not exist and `T` is not an `Optional`.
  ///
  /// See `Database.Decoder` for more details about the decoding process.
  ///
  /// - Parameters
  ///   - type: The type to convert the document fields to.
  ///   - decoder: The decoder to use to convert the document. Defaults to use
  ///              default decoder.
  public func data<T: Decodable>(as type: T.Type,
                                 decoder: Database.Decoder =
                                   Database.Decoder()) throws -> T {
    try decoder.decode(T.self, from: value ?? NSNull())
  }
}
