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

/// A type defining potentially harmful media categories and their model-assigned ratings. A value
/// of this type may be assigned to a category for every model-generated response, not just
/// responses that exceed a certain threshold.
@available(iOS 15.0, macOS 11.0, macCatalyst 15.0, *)
public struct SafetyRating: Equatable, Hashable {
  /// The category describing the potential harm a piece of content may pose. See
  /// ``SafetySetting/HarmCategory`` for a list of possible values.
  public let category: SafetySetting.HarmCategory

  /// The model-generated probability that a given piece of content falls under the harm category
  /// described in ``category``. This does not
  /// indiciate the severity of harm for a piece of content. See ``HarmProbability`` for a list of
  /// possible values.
  public let probability: HarmProbability

  /// Initializes a new `SafetyRating` instance with the given category and probability.
  /// Use this initializer for SwiftUI previews or tests.
  public init(category: SafetySetting.HarmCategory, probability: HarmProbability) {
    self.category = category
    self.probability = probability
  }

  init(internalSafetyRating: InternalGenerativeAI.SafetyRating) {
    self.init(
      category: SafetySetting.HarmCategory(internalCategory: internalSafetyRating.category),
      probability: HarmProbability(internalProbability: internalSafetyRating.probability)
    )
  }

  /// The probability that a given model output falls under a harmful content category. This does
  /// not indicate the severity of harm for a piece of content.
  public enum HarmProbability {
    /// Unknown. A new server value that isn't recognized by the SDK.
    case unknown

    /// The probability was not specified in the server response.
    case unspecified

    /// The probability is zero or close to zero. For benign content, the probability across all
    /// categories will be this value.
    case negligible

    /// The probability is small but non-zero.
    case low

    /// The probability is moderate.
    case medium

    /// The probability is high. The content described is very likely harmful.
    case high

    init(internalProbability: InternalGenerativeAI.SafetyRating.HarmProbability) {
      switch internalProbability {
      case .unknown:
        self = .unknown
      case .unspecified:
        self = .unspecified
      case .negligible:
        self = .negligible
      case .low:
        self = .low
      case .medium:
        self = .medium
      case .high:
        self = .high
      }
    }
  }
}

/// Safety feedback for an entire request.
@available(iOS 15.0, macOS 11.0, macCatalyst 15.0, *)
public struct SafetyFeedback {
  /// Safety rating evaluated from content.
  public let rating: SafetyRating

  /// Safety settings applied to the request.
  public let setting: SafetySetting

  /// Internal initializer.
  init(rating: SafetyRating, setting: SafetySetting) {
    self.rating = rating
    self.setting = setting
  }
}

/// A type used to specify a threshold for harmful content, beyond which the model will return a
/// fallback response instead of generated content.
@available(iOS 15.0, macOS 11.0, macCatalyst 15.0, *)
public struct SafetySetting {
  /// A type describing safety attributes, which include harmful categories and topics that can
  /// be considered sensitive.
  public enum HarmCategory {
    /// Unknown. A new server value that isn't recognized by the SDK.
    case unknown

    /// Unspecified by the server.
    case unspecified

    /// Harassment content.
    case harassment

    /// Negative or harmful comments targeting identity and/or protected attributes.
    case hateSpeech

    /// Contains references to sexual acts or other lewd content.
    case sexuallyExplicit

    /// Promotes or enables access to harmful goods, services, or activities.
    case dangerousContent

    init(internalCategory: InternalGenerativeAI.SafetySetting.HarmCategory) {
      switch internalCategory {
      case .unknown:
        self = .unknown
      case .unspecified:
        self = .unspecified
      case .harassment:
        self = .harassment
      case .hateSpeech:
        self = .hateSpeech
      case .sexuallyExplicit:
        self = .sexuallyExplicit
      case .dangerousContent:
        self = .dangerousContent
      }
    }

    func toInternal() -> InternalGenerativeAI.SafetySetting.HarmCategory {
      switch self {
      case .unknown:
        return .unknown
      case .unspecified:
        return .unspecified
      case .harassment:
        return .harassment
      case .hateSpeech:
        return .hateSpeech
      case .sexuallyExplicit:
        return .sexuallyExplicit
      case .dangerousContent:
        return .dangerousContent
      }
    }
  }

  /// Block at and beyond a specified ``SafetyRating/HarmProbability``.
  public enum BlockThreshold {
    /// Unknown. A new server value that isn't recognized by the SDK.
    case unknown

    /// Threshold is unspecified.
    case unspecified

    // Content with `.negligible` will be allowed.
    case blockLowAndAbove

    /// Content with `.negligible` and `.low` will be allowed.
    case blockMediumAndAbove

    /// Content with `.negligible`, `.low`, and `.medium` will be allowed.
    case blockOnlyHigh

    /// All content will be allowed.
    case blockNone

    func toInternal() -> InternalGenerativeAI.SafetySetting.BlockThreshold {
      switch self {
      case .unknown:
        return .unknown
      case .unspecified:
        return .unspecified
      case .blockLowAndAbove:
        return .blockLowAndAbove
      case .blockMediumAndAbove:
        return .blockMediumAndAbove
      case .blockOnlyHigh:
        return .blockOnlyHigh
      case .blockNone:
        return .blockNone
      }
    }
  }

  /// The category this safety setting should be applied to.
  public let harmCategory: HarmCategory

  /// The threshold describing what content should be blocked.
  public let threshold: BlockThreshold

  /// Initializes a new safety setting with the given category and threshold.
  public init(harmCategory: HarmCategory, threshold: BlockThreshold) {
    self.harmCategory = harmCategory
    self.threshold = threshold
  }

  func toInternal() -> InternalGenerativeAI.SafetySetting {
    return InternalGenerativeAI.SafetySetting(
      harmCategory: harmCategory.toInternal(),
      threshold: threshold.toInternal()
    )
  }
}

@available(iOS 15.0, macOS 11.0, macCatalyst 15.0, *)
extension [SafetySetting] {
  func toInternal() -> [InternalGenerativeAI.SafetySetting] {
    return self.map { $0.toInternal() }
  }
}
