//
// SFace.swift
//
// This file was automatically generated and should not be edited.
//

import CoreML


/// Model Prediction Input Type
@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
class SFaceInput : MLFeatureProvider {

    /// data as color (kCVPixelFormatType_32BGRA) image buffer, 112 pixels wide by 112 pixels high
    var data: CVPixelBuffer

    var featureNames: Set<String> { ["data"] }

    func featureValue(for featureName: String) -> MLFeatureValue? {
        if featureName == "data" {
            return MLFeatureValue(pixelBuffer: data)
        }
        return nil
    }

    init(data: CVPixelBuffer) {
        self.data = data
    }

    convenience init(dataWith data: CGImage) throws {
        self.init(data: try MLFeatureValue(cgImage: data, pixelsWide: 112, pixelsHigh: 112, pixelFormatType: kCVPixelFormatType_32BGRA, options: nil).imageBufferValue!)
    }

    convenience init(dataAt data: URL) throws {
        self.init(data: try MLFeatureValue(imageAt: data, pixelsWide: 112, pixelsHigh: 112, pixelFormatType: kCVPixelFormatType_32BGRA, options: nil).imageBufferValue!)
    }

    func setData(with data: CGImage) throws  {
        self.data = try MLFeatureValue(cgImage: data, pixelsWide: 112, pixelsHigh: 112, pixelFormatType: kCVPixelFormatType_32BGRA, options: nil).imageBufferValue!
    }

    func setData(with data: URL) throws  {
        self.data = try MLFeatureValue(imageAt: data, pixelsWide: 112, pixelsHigh: 112, pixelFormatType: kCVPixelFormatType_32BGRA, options: nil).imageBufferValue!
    }

}


/// Model Prediction Output Type
@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
class SFaceOutput : MLFeatureProvider {

    /// Source provided by CoreML
    private let provider : MLFeatureProvider

    /// var_811 as 1 by 128 matrix of 16-bit floats
    var var_811: MLMultiArray {
        provider.featureValue(for: "var_811")!.multiArrayValue!
    }

    /// var_811 as 1 by 128 matrix of 16-bit floats
    #if (os(macOS) || targetEnvironment(macCatalyst)) && arch(x86_64)
    @available(macOS, unavailable)
    @available(macCatalyst, unavailable)
    #else
    @available(macOS 15.0, *)
    #endif
    var var_811ShapedArray: MLShapedArray<Float16> {
        MLShapedArray<Float16>(var_811)
    }

    var featureNames: Set<String> {
        provider.featureNames
    }

    func featureValue(for featureName: String) -> MLFeatureValue? {
        provider.featureValue(for: featureName)
    }

    init(var_811: MLMultiArray) {
        self.provider = try! MLDictionaryFeatureProvider(dictionary: ["var_811" : MLFeatureValue(multiArray: var_811)])
    }

    init(features: MLFeatureProvider) {
        self.provider = features
    }
}


/// Class for model loading and prediction
@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
class SFace {
    let model: MLModel

    /// URL of model assuming it was installed in the same bundle as this class
    class var urlOfModelInThisBundle : URL {
        let bundle = Bundle(for: self)
        return bundle.url(forResource: "SFace", withExtension:"mlmodelc")!
    }

    /**
        Construct SFace instance with an existing MLModel object.

        Usually the application does not use this initializer unless it makes a subclass of SFace.
        Such application may want to use `MLModel(contentsOfURL:configuration:)` and `SFace.urlOfModelInThisBundle` to create a MLModel object to pass-in.

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
        Construct SFace instance with explicit path to mlmodelc file
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
        Construct SFace instance asynchronously with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - configuration: the desired model configuration
          - handler: the completion handler to be called when the model loading completes successfully or unsuccessfully
    */
    class func load(configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Swift.Result<SFace, Error>) -> Void) {
        load(contentsOf: self.urlOfModelInThisBundle, configuration: configuration, completionHandler: handler)
    }

    /**
        Construct SFace instance asynchronously with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - configuration: the desired model configuration
    */
    class func load(configuration: MLModelConfiguration = MLModelConfiguration()) async throws -> SFace {
        try await load(contentsOf: self.urlOfModelInThisBundle, configuration: configuration)
    }

    /**
        Construct SFace instance asynchronously with URL of the .mlmodelc directory with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - modelURL: the URL to the model
          - configuration: the desired model configuration
          - handler: the completion handler to be called when the model loading completes successfully or unsuccessfully
    */
    class func load(contentsOf modelURL: URL, configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Swift.Result<SFace, Error>) -> Void) {
        MLModel.load(contentsOf: modelURL, configuration: configuration) { result in
            switch result {
            case .failure(let error):
                handler(.failure(error))
            case .success(let model):
                handler(.success(SFace(model: model)))
            }
        }
    }

    /**
        Construct SFace instance asynchronously with URL of the .mlmodelc directory with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - modelURL: the URL to the model
          - configuration: the desired model configuration
    */
    class func load(contentsOf modelURL: URL, configuration: MLModelConfiguration = MLModelConfiguration()) async throws -> SFace {
        let model = try await MLModel.load(contentsOf: modelURL, configuration: configuration)
        return SFace(model: model)
    }

    /**
        Make a prediction using the structured interface

        It uses the default function if the model has multiple functions.

        - parameters:
           - input: the input to the prediction as SFaceInput

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as SFaceOutput
    */
    func prediction(input: SFaceInput) throws -> SFaceOutput {
        try prediction(input: input, options: MLPredictionOptions())
    }

    /**
        Make a prediction using the structured interface

        It uses the default function if the model has multiple functions.

        - parameters:
           - input: the input to the prediction as SFaceInput
           - options: prediction options

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as SFaceOutput
    */
    func prediction(input: SFaceInput, options: MLPredictionOptions) throws -> SFaceOutput {
        let outFeatures = try model.prediction(from: input, options: options)
        return SFaceOutput(features: outFeatures)
    }

    /**
        Make an asynchronous prediction using the structured interface

        It uses the default function if the model has multiple functions.

        - parameters:
           - input: the input to the prediction as SFaceInput
           - options: prediction options

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as SFaceOutput
    */
    @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
    func prediction(input: SFaceInput, options: MLPredictionOptions = MLPredictionOptions()) async throws -> SFaceOutput {
        let outFeatures = try await model.prediction(from: input, options: options)
        return SFaceOutput(features: outFeatures)
    }

    /**
        Make a prediction using the convenience interface

        It uses the default function if the model has multiple functions.

        - parameters:
            - data: color (kCVPixelFormatType_32BGRA) image buffer, 112 pixels wide by 112 pixels high

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as SFaceOutput
    */
    func prediction(data: CVPixelBuffer) throws -> SFaceOutput {
        let input_ = SFaceInput(data: data)
        return try prediction(input: input_)
    }

    /**
        Make a batch prediction using the structured interface

        It uses the default function if the model has multiple functions.

        - parameters:
           - inputs: the inputs to the prediction as [SFaceInput]
           - options: prediction options

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as [SFaceOutput]
    */
    func predictions(inputs: [SFaceInput], options: MLPredictionOptions = MLPredictionOptions()) throws -> [SFaceOutput] {
        let batchIn = MLArrayBatchProvider(array: inputs)
        let batchOut = try model.predictions(from: batchIn, options: options)
        var results : [SFaceOutput] = []
        results.reserveCapacity(inputs.count)
        for i in 0..<batchOut.count {
            let outProvider = batchOut.features(at: i)
            let result =  SFaceOutput(features: outProvider)
            results.append(result)
        }
        return results
    }
}
