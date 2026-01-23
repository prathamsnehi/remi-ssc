//
// FaceRec_MobileNetV3.swift
//
// This file was automatically generated and should not be edited.
//

import CoreML


/// Model Prediction Input Type
@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
class FaceRec_MobileNetV3Input : MLFeatureProvider {

    /// input_image as color (kCVPixelFormatType_32BGRA) image buffer, 112 pixels wide by 112 pixels high
    var input_image: CVPixelBuffer

    var featureNames: Set<String> { ["input_image"] }

    func featureValue(for featureName: String) -> MLFeatureValue? {
        if featureName == "input_image" {
            return MLFeatureValue(pixelBuffer: input_image)
        }
        return nil
    }

    init(input_image: CVPixelBuffer) {
        self.input_image = input_image
    }

    convenience init(input_imageWith input_image: CGImage) throws {
        self.init(input_image: try MLFeatureValue(cgImage: input_image, pixelsWide: 112, pixelsHigh: 112, pixelFormatType: kCVPixelFormatType_32ARGB, options: nil).imageBufferValue!)
    }

    convenience init(input_imageAt input_image: URL) throws {
        self.init(input_image: try MLFeatureValue(imageAt: input_image, pixelsWide: 112, pixelsHigh: 112, pixelFormatType: kCVPixelFormatType_32ARGB, options: nil).imageBufferValue!)
    }

    func setInput_image(with input_image: CGImage) throws  {
        self.input_image = try MLFeatureValue(cgImage: input_image, pixelsWide: 112, pixelsHigh: 112, pixelFormatType: kCVPixelFormatType_32ARGB, options: nil).imageBufferValue!
    }

    func setInput_image(with input_image: URL) throws  {
        self.input_image = try MLFeatureValue(imageAt: input_image, pixelsWide: 112, pixelsHigh: 112, pixelFormatType: kCVPixelFormatType_32ARGB, options: nil).imageBufferValue!
    }

}


/// Model Prediction Output Type
@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
class FaceRec_MobileNetV3Output : MLFeatureProvider {

    /// Source provided by CoreML
    private let provider : MLFeatureProvider

    /// embedding as 1 by 512 matrix of 16-bit floats
    var embedding: MLMultiArray {
        provider.featureValue(for: "embedding")!.multiArrayValue!
    }

    /// embedding as 1 by 512 matrix of 16-bit floats
    #if (os(macOS) || targetEnvironment(macCatalyst)) && arch(x86_64)
    @available(macOS, unavailable)
    @available(macCatalyst, unavailable)
    #else
    @available(macOS 15.0, *)
    #endif
    var embeddingShapedArray: MLShapedArray<Float16> {
        MLShapedArray<Float16>(embedding)
    }

    var featureNames: Set<String> {
        provider.featureNames
    }

    func featureValue(for featureName: String) -> MLFeatureValue? {
        provider.featureValue(for: featureName)
    }

    init(embedding: MLMultiArray) {
        self.provider = try! MLDictionaryFeatureProvider(dictionary: ["embedding" : MLFeatureValue(multiArray: embedding)])
    }

    init(features: MLFeatureProvider) {
        self.provider = features
    }
}


/// Class for model loading and prediction
@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
class FaceRec_MobileNetV3 {
    let model: MLModel

    /// URL of model assuming it was installed in the same bundle as this class
    class var urlOfModelInThisBundle : URL {
        let bundle = Bundle(for: self)
        return bundle.url(forResource: "FaceRec_MobileNetV3", withExtension:"mlmodelc")!
    }

    /**
        Construct FaceRec_MobileNetV3 instance with an existing MLModel object.

        Usually the application does not use this initializer unless it makes a subclass of FaceRec_MobileNetV3.
        Such application may want to use `MLModel(contentsOfURL:configuration:)` and `FaceRec_MobileNetV3.urlOfModelInThisBundle` to create a MLModel object to pass-in.

        - parameters:
          - model: MLModel object
    */
    init(model: MLModel) {
        self.model = model
    }

    /**
        Construct a model with configuration

        - parameters:
           - configuration: the desired model configuration

        - throws: an NSError object that describes the problem
    */
    convenience init(configuration: MLModelConfiguration = MLModelConfiguration()) throws {
        try self.init(contentsOf: type(of:self).urlOfModelInThisBundle, configuration: configuration)
    }

    /**
        Construct FaceRec_MobileNetV3 instance with explicit path to mlmodelc file
        - parameters:
           - modelURL: the file url of the model

        - throws: an NSError object that describes the problem
    */
    convenience init(contentsOf modelURL: URL) throws {
        try self.init(model: MLModel(contentsOf: modelURL))
    }

    /**
        Construct a model with URL of the .mlmodelc directory and configuration

        - parameters:
           - modelURL: the file url of the model
           - configuration: the desired model configuration

        - throws: an NSError object that describes the problem
    */
    convenience init(contentsOf modelURL: URL, configuration: MLModelConfiguration) throws {
        try self.init(model: MLModel(contentsOf: modelURL, configuration: configuration))
    }

    /**
        Construct FaceRec_MobileNetV3 instance asynchronously with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - configuration: the desired model configuration
          - handler: the completion handler to be called when the model loading completes successfully or unsuccessfully
    */
    class func load(configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Swift.Result<FaceRec_MobileNetV3, Error>) -> Void) {
        load(contentsOf: self.urlOfModelInThisBundle, configuration: configuration, completionHandler: handler)
    }

    /**
        Construct FaceRec_MobileNetV3 instance asynchronously with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - configuration: the desired model configuration
    */
    class func load(configuration: MLModelConfiguration = MLModelConfiguration()) async throws -> FaceRec_MobileNetV3 {
        try await load(contentsOf: self.urlOfModelInThisBundle, configuration: configuration)
    }

    /**
        Construct FaceRec_MobileNetV3 instance asynchronously with URL of the .mlmodelc directory with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - modelURL: the URL to the model
          - configuration: the desired model configuration
          - handler: the completion handler to be called when the model loading completes successfully or unsuccessfully
    */
    class func load(contentsOf modelURL: URL, configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Swift.Result<FaceRec_MobileNetV3, Error>) -> Void) {
        MLModel.load(contentsOf: modelURL, configuration: configuration) { result in
            switch result {
            case .failure(let error):
                handler(.failure(error))
            case .success(let model):
                handler(.success(FaceRec_MobileNetV3(model: model)))
            }
        }
    }

    /**
        Construct FaceRec_MobileNetV3 instance asynchronously with URL of the .mlmodelc directory with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - modelURL: the URL to the model
          - configuration: the desired model configuration
    */
    class func load(contentsOf modelURL: URL, configuration: MLModelConfiguration = MLModelConfiguration()) async throws -> FaceRec_MobileNetV3 {
        let model = try await MLModel.load(contentsOf: modelURL, configuration: configuration)
        return FaceRec_MobileNetV3(model: model)
    }

    /**
        Make a prediction using the structured interface

        It uses the default function if the model has multiple functions.

        - parameters:
           - input: the input to the prediction as FaceRec_MobileNetV3Input

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as FaceRec_MobileNetV3Output
    */
    func prediction(input: FaceRec_MobileNetV3Input) throws -> FaceRec_MobileNetV3Output {
        try prediction(input: input, options: MLPredictionOptions())
    }

    /**
        Make a prediction using the structured interface

        It uses the default function if the model has multiple functions.

        - parameters:
           - input: the input to the prediction as FaceRec_MobileNetV3Input
           - options: prediction options

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as FaceRec_MobileNetV3Output
    */
    func prediction(input: FaceRec_MobileNetV3Input, options: MLPredictionOptions) throws -> FaceRec_MobileNetV3Output {
        let outFeatures = try model.prediction(from: input, options: options)
        return FaceRec_MobileNetV3Output(features: outFeatures)
    }

    /**
        Make an asynchronous prediction using the structured interface

        It uses the default function if the model has multiple functions.

        - parameters:
           - input: the input to the prediction as FaceRec_MobileNetV3Input
           - options: prediction options

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as FaceRec_MobileNetV3Output
    */
    @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
    func prediction(input: FaceRec_MobileNetV3Input, options: MLPredictionOptions = MLPredictionOptions()) async throws -> FaceRec_MobileNetV3Output {
        let outFeatures = try await model.prediction(from: input, options: options)
        return FaceRec_MobileNetV3Output(features: outFeatures)
    }

    /**
        Make a prediction using the convenience interface

        It uses the default function if the model has multiple functions.

        - parameters:
            - input_image: color (kCVPixelFormatType_32BGRA) image buffer, 112 pixels wide by 112 pixels high

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as FaceRec_MobileNetV3Output
    */
    func prediction(input_image: CVPixelBuffer) throws -> FaceRec_MobileNetV3Output {
        let input_ = FaceRec_MobileNetV3Input(input_image: input_image)
        return try prediction(input: input_)
    }

    /**
        Make a batch prediction using the structured interface

        It uses the default function if the model has multiple functions.

        - parameters:
           - inputs: the inputs to the prediction as [FaceRec_MobileNetV3Input]
           - options: prediction options

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as [FaceRec_MobileNetV3Output]
    */
    func predictions(inputs: [FaceRec_MobileNetV3Input], options: MLPredictionOptions = MLPredictionOptions()) throws -> [FaceRec_MobileNetV3Output] {
        let batchIn = MLArrayBatchProvider(array: inputs)
        let batchOut = try model.predictions(from: batchIn, options: options)
        var results : [FaceRec_MobileNetV3Output] = []
        results.reserveCapacity(inputs.count)
        for i in 0..<batchOut.count {
            let outProvider = batchOut.features(at: i)
            let result =  FaceRec_MobileNetV3Output(features: outProvider)
            results.append(result)
        }
        return results
    }
}
