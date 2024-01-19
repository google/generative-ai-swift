// Copyright 2024 Google LLC
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

import UniformTypeIdentifiers
#if canImport(UIKit)
  import UIKit // For UIImage extensions.
#elseif canImport(AppKit)
  import AppKit // For NSImage extensions.
#endif

private let imageCompressionQuality: CGFloat = 0.8

/// An enum describing failures that can occur when converting image types to model content data.
/// For some image types like `CIImage`, creating valid model content requires creating a JPEG
/// representation of the image that may not yet exist, which may be computationally expensive.
public enum ImageConversionError: Error {
  #if canImport(AppKit)
    /// The image (the receiver of the call `toModelContentParts()`) was invalid.
    case invalidUnderlyingImage
  #endif

  /// A valid image destination could not be allocated.
  case couldNotAllocateDestination

  /// JPEG image data conversion failed, accompanied by the original image, which may be an
  /// instance of `NSImageRep`, `UIImage`, `CGImage`, or `CIImage`.
  case couldNotConvertToJPEG(Any)
}

#if canImport(UIKit)
  /// Enables images to be representable as ``PartsRepresentable``.
  extension UIImage: PartsRepresentable {
    public func toModelContentParts() -> Result<[ModelContent.Part], ImageConversionError> {
      guard let data = jpegData(compressionQuality: imageCompressionQuality) else {
        return .failure(.couldNotConvertToJPEG(self))
      }
      return .success([ModelContent.Part.data(mimetype: "image/jpeg", data)])
    }
  }

#elseif canImport(AppKit)
  /// Enables images to be representable as ``PartsRepresentable``.
  extension NSImage: PartsRepresentable {
    public func toModelContentParts() -> Result<[ModelContent.Part], ImageConversionError> {
      guard let cgImage = cgImage(forProposedRect: nil, context: nil, hints: nil) else {
        return .failure(.invalidUnderlyingImage)
      }
      let bmp = NSBitmapImageRep(cgImage: cgImage)
      guard let data = bmp.representation(using: .jpeg, properties: [.compressionFactor: 0.8])
      else {
        return .failure(.couldNotConvertToJPEG(bmp))
      }
      return .success([ModelContent.Part.data(mimetype: "image/jpeg", data)])
    }
  }
#endif

extension CGImage: PartsRepresentable {
  public func toModelContentParts() -> Result<[ModelContent.Part], ImageConversionError> {
    let output = NSMutableData()
    guard let imageDestination = CGImageDestinationCreateWithData(
      output, UTType.jpeg.identifier as CFString, 1, nil
    ) else {
      return .failure(.couldNotAllocateDestination)
    }
    CGImageDestinationAddImage(imageDestination, self, nil)
    CGImageDestinationSetProperties(imageDestination, [
      kCGImageDestinationLossyCompressionQuality: imageCompressionQuality,
    ] as CFDictionary)
    if CGImageDestinationFinalize(imageDestination) {
      return .success([.data(mimetype: "image/jpeg", output as Data)])
    }
    return .failure(.couldNotConvertToJPEG(self))
  }
}

extension CIImage: PartsRepresentable {
  public func toModelContentParts() -> Result<[ModelContent.Part], ImageConversionError> {
    let context = CIContext()
    let jpegData = (colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB))
      .flatMap {
        // The docs specify kCGImageDestinationLossyCompressionQuality as a supported option, but
        // Swift's type system does not allow this.
        // [kCGImageDestinationLossyCompressionQuality: imageCompressionQuality]
        context.jpegRepresentation(of: self, colorSpace: $0, options: [:])
      }
    if let jpegData = jpegData {
      return .success([.data(mimetype: "image/jpeg", jpegData)])
    }
    return .failure(.couldNotConvertToJPEG(self))
  }
}
