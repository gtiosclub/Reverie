//
//  ImageProcessingErrorService.swift
//  Reverie
//
//  Created by Brayden Huguenard on 10/12/25.
//

enum ImageProcessingErrorService: Error {
    case failedToGetCGImage
    case visionRequestFailed
    case filterCreationFailed
    case filterFailedToOutput
    case finalImageCreationFailed
    case infiniteOrEmptyOutput
    case uploadFailedAfterRetries
}
