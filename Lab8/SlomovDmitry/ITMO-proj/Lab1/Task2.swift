struct Point: Equatable, Hashable {
    var x: Double
    var y: Double

    mutating func move(byX dx: Double, byY dy: Double) {
        x += dx
        y += dy
    }

    var distanceToOrigin: Double {
        (x * x + y * y).squareRoot()
    }
}

struct Rectangle {
    var origin: Point
    private(set) var width: Double
    private(set) var height: Double

    init(origin: Point, width: Double, height: Double) {
        self.origin = origin
        self.width = width > 0 ? width : 1.0
        self.height = height > 0 ? height : 1.0
    }

    var area: Double {
        width * height
    }

    var perimeter: Double {
        2 * (width + height)
    }

    var center: Point {
        Point(x: origin.x + width / 2, y: origin.y + height / 2)
    }

    mutating func scale(by factor: Double) {
        guard factor > 0 else { return }
        width *= factor
        height *= factor
    }

    func contains(_ point: Point) -> Bool {
        point.x >= origin.x && point.x <= origin.x + width &&
        point.y >= origin.y && point.y <= origin.y + height
    }
}

func runTask2() {
    var point = Point(x: 3, y: 4)
    print("Distance:", point.distanceToOrigin) // 5.0

    point.move(byX: 1, byY: -2)
    print("Moved point:", point) // (4, 2)

    let otherPoint = Point(x: 4, y: 2)
    print("Equal:", point == otherPoint) // true
    print("Unique points:", Set([point, otherPoint]).count) // 1

    // Изменение копии не меняет исходную точку
    var pointCopy = point
    pointCopy.move(byX: 10, byY: 0)
    print("Original:", point) // (4, 2)
    print("Copy:", pointCopy) // (14, 2)

    var rectangle = Rectangle(origin: Point(x: 1, y: 2), width: 4, height: 2)
    print("Area:", rectangle.area)           // 8.0
    print("Perimeter:", rectangle.perimeter) // 12.0
    print("Center:", rectangle.center)       // (3, 3)

    print("Inside:", rectangle.contains(Point(x: 3, y: 3)))  // true
    print("Boundary:", rectangle.contains(Point(x: 5, y: 4))) // true
    print("Outside:", rectangle.contains(Point(x: 6, y: 3))) // false

    rectangle.scale(by: 2)
    print("Scaled size:", rectangle.width, rectangle.height) // 8.0, 4.0
    print("Scaled area:", rectangle.area) // 32.0
    print("Origin:", rectangle.origin) // (1, 2)

    rectangle.scale(by: 0)
    print("After zero scale:", rectangle.width, rectangle.height) // 8.0, 4.0

    let corrected = Rectangle(origin: Point(x: 0, y: 0), width: -2, height: 5)
    print("Corrected size:", corrected.width, corrected.height) // 1.0, 5.0
}
