export const publishSchema = {
  service_descr: {
    isObject: true
  },
  'service_descr.url': {
    isURL: true
  },
  'service_descr.api_key': {
    isString: true
  },
  'service_descr.data_key': {
    isString: true
  },
  'service_descr.timeout': {
    default: {
      options: 0
    },
    isInt: {
      options: { min: 0 }
    }
  },
  asset_descr: {
    isObject: true
  },
  'asset_descr.name': {
    isString: true
  },
  'asset_descr.type': {
    isString: true,
    toLowerCase: true,
    matches: {
      options: '^dataset$'
    }
  },
  'asset_descr.description': {
    isString: true
  },
  'asset_descr.author': {
    isString: true
  },
  'asset_descr.license': {
    isString: true
  },
  'asset_descr.price': {
    isObject: true
  },
  'asset_descr.price.value': {
    isFloat: {
      options: { min: 0.0 }
    }
  },
  'asset_descr.price.currency': {
    isString: true,
    toUpperCase: true
  }
}
