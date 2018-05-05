enum SerializationError: Error {
    case missing(String)
    case invalid(String, Any)
}
