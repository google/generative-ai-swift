// Generated by Create API
// https://github.com/CreateAPI/CreateAPI
//
// Copyright 2023 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation

/// A collection of source attributions for a piece of content.
public struct CitationMetadata: Codable {
  /// Citations to sources for a specific response.
  public var citationSources: [CitationSource]?

  public init(citationSources: [CitationSource]? = nil) {
    self.citationSources = citationSources
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: StringCodingKey.self)
    self.citationSources = try values.decodeIfPresent([CitationSource].self, forKey: "citationSources")
  }

  public func encode(to encoder: Encoder) throws {
    var values = encoder.container(keyedBy: StringCodingKey.self)
    try values.encodeIfPresent(citationSources, forKey: "citationSources")
  }
}
