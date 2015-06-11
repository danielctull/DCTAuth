
import Foundation

class DCTAuthMultipartData: NSObject {

	var data: NSData?
	var name: String?
	var type: String?

	func dataWithBoundary(boundary: String) -> NSData? {

		let part1 = "--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)
		let part2 = "Content-Disposition: form-data; name=\"\(name)\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)
		let part3 = "Content-Type: \(type)\r\n".dataUsingEncoding(NSUTF8StringEncoding)
		let part4 = "\r\n".dataUsingEncoding(NSUTF8StringEncoding)
		let part5 = "\r\n".dataUsingEncoding(NSUTF8StringEncoding)

		if let data = data, part1 = part1, part2 = part2, part3 = part3, part4 = part4, part5 = part5 {


			let parts = [part1, part2, part3, part4, data, part5]
			let body = parts.reduce(NSMutableData()) { (data, part) in
				data.appendData(part)
				return data
			}

			return body.copy() as? NSData

		}

		return nil
	}
}
