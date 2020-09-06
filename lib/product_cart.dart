final String simpleProducts = '''
mutation SimpleProduct(\$id: String!, \$qty: Float!, \$sku: String!) {
  addSimpleProductsToCart(
    input: {
      cart_id: \$id
      cart_items: [
        {
          data: {
            quantity: \$qty
            sku: \$sku
          }
        }
      ]
    }
  ) {
    cart {
      items {
        id
        product {
          name
          sku
        }
        quantity
      }
    }
  }
}
''';

final String virtualProducts = '''
mutation VirtualProduct(\$id: String!, \$qty: Float!, \$sku: String!) {
  addVirtualProductsToCart(
    input: {
      cart_id: \$id,
      cart_items: [
        {
          data: {
            quantity: \$qty
            sku: \$sku
          }
        }
       ]
    }
  ) {
    cart {
      items {
        id
        product {
          name
          sku
        }
        quantity
      }
    }
  }
}
''';
