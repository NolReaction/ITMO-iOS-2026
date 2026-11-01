struct Order {
    let id: Int
    let customer: String
    let amount: Double
    let isPaid: Bool
    let promoCode: String?
}

func runTask1() {
    let orders: [Order] = [
        Order(id: 1, customer: "Анна", amount: 1200, isPaid: true, promoCode: "SALE10"),
        Order(id: 2, customer: "Иван", amount: 800, isPaid: false, promoCode: nil),
        Order(id: 3, customer: "Анна", amount: 5400, isPaid: true, promoCode: nil),
        Order(id: 4, customer: "Олег", amount: 300, isPaid: true, promoCode: "NEW"),
        Order(id: 5, customer: "Иван", amount: 2100, isPaid: false, promoCode: "SALE10")
    ]

    // 1. Суммы оплаченных заказов
    let paidAmounts = orders
        .filter { order in order.isPaid }
        .map { order in order.amount }

    print("Paid amounts:", paidAmounts)

    // 2. Сумма неоплаченных заказов
    let unpaidTotal = orders
        .filter { order in !order.isPaid }
        .reduce(0.0) { total, order in
            total + order.amount
        }

    print("Unpaid total:", unpaidTotal)

    // 3. Уникальные имена по алфавиту
    let names = orders.map { order in order.customer }
    let uniqueNames = Set(names).sorted()

    print("Customers:", uniqueNames)

    // 4. Промокоды без nil
    let promoCodes = orders.compactMap { order in order.promoCode }

    print("Promo codes:", promoCodes)

    // 5. Заказы по клиентам
    let ordersByCustomer: [String: [Order]] = Dictionary(
        grouping: orders,
        by: { order in order.customer }
    )

    ordersByCustomer.keys.sorted().forEach { name in
        let ids = ordersByCustomer[name, default: []].map { order in order.id }
        print(name, ids)
    }

    // 6. Клиент с наибольшей оплаченной суммой
    let paidOrders = orders.filter { order in order.isPaid }
    let paidGroups = Dictionary(grouping: paidOrders, by: { order in order.customer })

    let paidTotals = paidGroups.mapValues { customerOrders in
        customerOrders.reduce(0.0) { total, order in
            total + order.amount
        }
    }

    let bestCustomer = paidTotals.max { first, second in
        first.value < second.value
    }

    if let customer = bestCustomer {
        print("Top customer:", customer.key, "Total:", customer.value)
    } else {
        print("No paid orders")
    }
}
