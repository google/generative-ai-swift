// Copyright 2023 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation
import InternalGenerativeAI

/// Configuration parameters for sending requests to the backend.
@available(iOS 15.0, macOS 11.0, macCatalyst 15.0, *)
public struct RequestOptions {
  /// The request’s timeout interval in seconds; if not specified uses the default value for a
  /// `URLRequest`.
  let timeout: TimeInterval?

  /// The API version to use in requests to the backend.
  let apiVersion: String

  /// Initializes a request options object.
  ///
  /// - Parameters:
  ///   - timeout The request’s timeout interval in seconds; if not specified uses the default value
  ///   for a `URLRequest`.
  ///   - apiVersion The API version to use in requests to the backend; defaults to "v1".
  public init(timeout: TimeInterval? = nil, apiVersion: String = "v1") {
    self.timeout = timeout
    self.apiVersion = apiVersion
  }

  func toInternal() -> InternalGenerativeAI.RequestOptions {
    return InternalGenerativeAI.RequestOptions(
      baseURL: GenerativeAISwift.baseURL,
      timeout: timeout,
      apiVersion: apiVersion
    )
  }
}
