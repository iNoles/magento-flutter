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
        product {
          name
          sku
        }
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
        product {
          name
          sku
        }
      }
    }
  }
}
''';

final String configurableProducts = '''
mutation ConfigurableProduct(
  \$id: String!, \$qty: Float!, \$parentSku: String!, \$variantSku: String!
) {
  addConfigurableProductsToCart(
    input: {
      cart_id: \$id,
      cart_items: [
        {
          parent_sku: \$parentSku
          data: {
            quantity: \$qty
            sku: \$variantSku
          }
        }
      ]
    }
  ) {
    cart {
      items {
        product {
          name
          sku
        }
      }
    }
  }
}
''';
