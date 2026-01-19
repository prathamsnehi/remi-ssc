//
// MobileFaceNet.swift
//
// This file was automatically generated and should not be edited.
//

import CoreML


/// Model Prediction Input Type
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
class MobileFaceNetInput : MLFeatureProvider {
    
    /// input_1 as color (kCVPixelFormatType_32BGRA) image buffer, 112 pixels wide by 112 pixels high
    var input_1: CVPixelBuffer
    
    var featureNames: Set<String> { ["input_1"] }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        if featureName == "input_1" {
            return MLFeatureValue(pixelBuffer: input_1)
        }
        return nil
    }
    
    init(input_1: CVPixelBuffer) {
        self.input_1 = input_1
    }
    
    convenience init(input_1With input_1: CGImage) throws {
        self.init(input_1: try MLFeatureValue(cgImage: input_1, pixelsWide: 112, pixelsHigh: 112, pixelFormatType: kCVPixelFormatType_32ARGB, options: nil).imageBufferValue!)
    }
    
    convenience init(input_1At input_1: URL) throws {
        self.init(input_1: try MLFeatureValue(imageAt: input_1, pixelsWide: 112, pixelsHigh: 112, pixelFormatType: kCVPixelFormatType_32ARGB, options: nil).imageBufferValue!)
    }
    
    func setInput_1(with input_1: CGImage) throws  {
        self.input_1 = try MLFeatureValue(cgImage: input_1, pixelsWide: 112, pixelsHigh: 112, pixelFormatType: kCVPixelFormatType_32ARGB, options: nil).imageBufferValue!
    }
    
    func setInput_1(with input_1: URL) throws  {
        self.input_1 = try MLFeatureValue(imageAt: input_1, pixelsWide: 112, pixelsHigh: 112, pixelFormatType: kCVPixelFormatType_32ARGB, options: nil).imageBufferValue!
    }
    
}


/// Model Prediction Output Type
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
class MobileFaceNetOutput : MLFeatureProvider {
    
    /// Source provided by CoreML
    private let provider : MLFeatureProvider
    
    /// var_950 as multidimensional array of floats
    /// var_950 as multidimensional array of floats
    var var_950: MLMultiArray {
        guard let value = provider.featureValue(for: "var_950") else {
            print("CRITICAL ML ERROR: 'var_950' output not found. Available features: \(provider.featureNames)")
            return try! MLMultiArray(shape: [512], dataType: .double) // Fallback to avoid crash
        }
        return value.multiArrayValue!
    }
    
    /// var_950 as multidimensional array of floats
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    var var_950ShapedArray: MLShapedArray<Float> {
        MLShapedArray<Float>(var_950)
    }
    
    var featureNames: Set<String> {
        provider.featureNames
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        provider.featureValue(for: featureName)
    }
    
    init(var_950: MLMultiArray) {
        self.provider = try! MLDictionaryFeatureProvider(dictionary: ["var_950" : MLFeatureValue(multiArray: var_950)])
    }
    
    init(features: MLFeatureProvider) {
        self.provider = features
    }
}


/// Class for model loading and prediction
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
class MobileFaceNet {
    let model: MLModel
    
    /// URL of model assuming it was installed in the same bundle as this class
    class var urlOfModelInThisBundle: URL {
        let bundle = Bundle.main
        
        // Try finding as a standard resource bundle
        if let url = bundle.url(forResource: "MobileFaceNet", withExtension: "mlmodelc") {
            return url
        }
        
        // Try finding as a folder directly in the root of the bundle (common in Swift Playgrounds)
        if let url = bundle.url(forResource: "MobileFaceNet.mlmodelc", withExtension: nil) {
            return url
        }
        
        // Try finding inside "Resources" subdirectory (common with .copy)
        if let url = bundle.url(forResource: "Resources/MobileFaceNet.mlmodelc", withExtension: nil) {
            return url
        }
        
        // Debugging info if both fail
        print("Bundle Path: \(bundle.bundlePath)")
        fatalError("Could not find MobileFaceNet.mlmodelc in Bundle.main. Checked for 'MobileFaceNet.mlmodelc' (folder) and 'MobileFaceNet.mlmodelc' (extension lookup).")
    }
    
    /**
     Construct MobileFaceNet instance with an existing MLModel object.
     
     Usually the application does not use this initializer unless it makes a subclass of MobileFaceNet.
     Such application may want to use `MLModel(contentsOfURL:configuration:)` and `MobileFaceNet.urlOfModelInThisBundle` to create a MLModel object to pass-in.
     
     - parameters:
     - model: MLModel object
     */
    init(model: MLModel) {
        self.model = model
    }
    
    /**
     Construct MobileFaceNet instance by automatically loading the model from the app's bundle.
     */
    @available(*, deprecated, message: "Use init(configuration:) instead and handle errors appropriately.")
    convenience init() {
        try! self.init(contentsOf: type(of:self).urlOfModelInThisBundle)
    }
    
    /**
     Construct a model with configuration
     
     - parameters:
     - configuration: the desired model configuration
     
     - throws: an NSError object that describes the problem
     */
    convenience init(configuration: MLModelConfiguration) throws {
        try self.init(contentsOf: type(of:self).urlOfModelInThisBundle, configuration: configuration)
    }
    
    /**
     Construct MobileFaceNet instance with explicit path to mlmodelc file
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
     Construct MobileFaceNet instance asynchronously with optional configuration.
     
     Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.
     
     - parameters:
     - configuration: the desired model configuration
     - handler: the completion handler to be called when the model loading completes successfully or unsuccessfully
     */
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, visionOS 1.0, *)
    class func load(configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Swift.Result<MobileFaceNet, Error>) -> Void) {
        load(contentsOf: self.urlOfModelInThisBundle, configuration: configuration, completionHandler: handler)
    }
    
    /**
     Construct MobileFaceNet instance asynchronously with optional configuration.
     
     Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.
     
     - parameters:
     - configuration: the desired model configuration
     */
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    class func load(configuration: MLModelConfiguration = MLModelConfiguration()) async throws -> MobileFaceNet {
        try await load(contentsOf: self.urlOfModelInThisBundle, configuration: configuration)
    }
    
    /**
     Construct MobileFaceNet instance asynchronously with URL of the .mlmodelc directory with optional configuration.
     
     Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.
     
     - parameters:
     - modelURL: the URL to the model
     - configuration: the desired model configuration
     - handler: the completion handler to be called when the model loading completes successfully or unsuccessfully
     */
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, visionOS 1.0, *)
    class func load(contentsOf modelURL: URL, configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Swift.Result<MobileFaceNet, Error>) -> Void) {
        MLModel.load(contentsOf: modelURL, configuration: configuration) { result in
            switch result {
            case .failure(let error):
                handler(.failure(error))
            case .success(let model):
                handler(.success(MobileFaceNet(model: model)))
            }
        }
    }
    
    /**
     Construct MobileFaceNet instance asynchronously with URL of the .mlmodelc directory with optional configuration.
     
     Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.
     
     - parameters:
     - modelURL: the URL to the model
     - configuration: the desired model configuration
     */
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    class func load(contentsOf modelURL: URL, configuration: MLModelConfiguration = MLModelConfiguration()) async throws -> MobileFaceNet {
        let model = try await MLModel.load(contentsOf: modelURL, configuration: configuration)
        return MobileFaceNet(model: model)
    }
    
    /**
     Make a prediction using the structured interface
     
     It uses the default function if the model has multiple functions.
     
     - parameters:
     - input: the input to the prediction as MobileFaceNetInput
     
     - throws: an NSError object that describes the problem
     
     - returns: the result of the prediction as MobileFaceNetOutput
     */
    func prediction(input: MobileFaceNetInput) throws -> MobileFaceNetOutput {
        try prediction(input: input, options: MLPredictionOptions())
    }
    
    /**
     Make a prediction using the structured interface
     
     It uses the default function if the model has multiple functions.
     
     - parameters:
     - input: the input to the prediction as MobileFaceNetInput
     - options: prediction options
     
     - throws: an NSError object that describes the problem
     
     - returns: the result of the prediction as MobileFaceNetOutput
     */
    func prediction(input: MobileFaceNetInput, options: MLPredictionOptions) throws -> MobileFaceNetOutput {
        let outFeatures = try model.prediction(from: input, options: options)
        return MobileFaceNetOutput(features: outFeatures)
    }
    
    /**
     Make an asynchronous prediction using the structured interface
     
     It uses the default function if the model has multiple functions.
     
     - parameters:
     - input: the input to the prediction as MobileFaceNetInput
     - options: prediction options
     
     - throws: an NSError object that describes the problem
     
     - returns: the result of the prediction as MobileFaceNetOutput
     */
    @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
    func prediction(input: MobileFaceNetInput, options: MLPredictionOptions = MLPredictionOptions()) async throws -> MobileFaceNetOutput {
        let outFeatures = try await model.prediction(from: input, options: options)
        return MobileFaceNetOutput(features: outFeatures)
    }
    
    /**
     Make a prediction using the convenience interface
     
     It uses the default function if the model has multiple functions.
     
     - parameters:
     - input_1: color (kCVPixelFormatType_32BGRA) image buffer, 112 pixels wide by 112 pixels high
     
     - throws: an NSError object that describes the problem
     
     - returns: the result of the prediction as MobileFaceNetOutput
     */
    func prediction(input_1: CVPixelBuffer) throws -> MobileFaceNetOutput {
        let input_ = MobileFaceNetInput(input_1: input_1)
        return try prediction(input: input_)
    }
    
    /**
     Make a batch prediction using the structured interface
     
     It uses the default function if the model has multiple functions.
     
     - parameters:
     - inputs: the inputs to the prediction as [MobileFaceNetInput]
     - options: prediction options
     
     - throws: an NSError object that describes the problem
     
     - returns: the result of the prediction as [MobileFaceNetOutput]
     */
    func predictions(inputs: [MobileFaceNetInput], options: MLPredictionOptions = MLPredictionOptions()) throws -> [MobileFaceNetOutput] {
        let batchIn = MLArrayBatchProvider(array: inputs)
        let batchOut = try model.predictions(from: batchIn, options: options)
        var results : [MobileFaceNetOutput] = []
        results.reserveCapacity(inputs.count)
        for i in 0..<batchOut.count {
            let outProvider = batchOut.features(at: i)
            let result =  MobileFaceNetOutput(features: outProvider)
            results.append(result)
        }
        return results
    }
}
