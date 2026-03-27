public extension String {
    var capitalizedFirstLetter: String {
        prefix(1).capitalized + dropFirst()
    }
}
