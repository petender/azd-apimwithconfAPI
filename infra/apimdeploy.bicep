param apimServiceName string = ''
param location string = resourceGroup().location
param tags object = {}
param name string

param WebAppURL string

@description('The SKU of the APIM instance')
@allowed([
  'Developer'
  'Consumption'
  'Standard'
])
param apimSku string


var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = uniqueString(subscription().id, resourceGroup().id, location)

// disable the developer portal for consumption SKUs
// the property is invalid for consumption SKUs, so setting to null
var developerPortalStatus = apimSku == 'Consumption' ? null : 'Enabled'

// capacity is is required to be 0 for consumption SKUs
var capacity = apimSku == 'Consumption' ? 0 : 1

resource apimService 'Microsoft.ApiManagement/service@2023-03-01-preview' = {
  name: name
  location: resourceGroup().location
  sku: {
    name: apimSku
    capacity: capacity
  }
  properties: {
    publisherEmail: 'petender@mttdemoworld.onmicrosoft.com'
    publisherName: 'mttdemoworld'
    notificationSenderEmail: 'apimgmt-noreply@mail.windowsazure.com'
    
    customProperties: {
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls11': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls10': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls11': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls10': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Ssl30': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Protocols.Server.Http2': 'false'
    }
    virtualNetworkType: 'None'
    disableGateway: false
    natGatewayState: 'Disabled'
    apiVersionConstraint: {}
    publicNetworkAccess: 'Enabled'
    legacyPortalStatus: 'Enabled'
    developerPortalStatus: developerPortalStatus
  }
}

resource apimServiceName_demo_conference_api 'Microsoft.ApiManagement/service/apis@2023-03-01-preview' = {
  parent: apimService
  name: 'demo-conference-api'
  properties: {
    displayName: 'MTT Demo Conference API'
    apiRevision: '1'
    description: 'A sample API with information related to a technical conference.  The available resources  include *Speakers*, *Sessions* and *Topics*.  A single write operation is available to provide  feedback on a session.'
    subscriptionRequired: true
    serviceUrl: 'https://${WebAppURL}'
    protocols: [
      'http'
      'https'
    ]
    authenticationSettings: {
      oAuth2AuthenticationSettings: []
      openidAuthenticationSettings: []
    }
    subscriptionKeyParameterNames: {
      header: 'Ocp-Apim-Subscription-Key'
      query: 'subscription-key'
    }
    isCurrent: true
    path: ''
  }
}

resource apimServiceName_echo_api 'Microsoft.ApiManagement/service/apis@2023-03-01-preview' = {
  parent: apimService
  name: 'echo-api'
  properties: {
    displayName: 'Echo API'
    apiRevision: '1'
    subscriptionRequired: true
    serviceUrl: 'http://echoapi.cloudapp.net/api'
    path: 'echo'
    protocols: [
      'https'
    ]
    authenticationSettings: {
      oAuth2AuthenticationSettings: []
      openidAuthenticationSettings: []
    }
    subscriptionKeyParameterNames: {
      header: 'Ocp-Apim-Subscription-Key'
      query: 'subscription-key'
    }
    isCurrent: true
  }
}

resource apimServiceName_mtt_custom 'Microsoft.ApiManagement/service/products@2023-03-01-preview' = {
  parent: apimService
  name: 'mtt-custom'
  properties: {
    displayName: 'mtt_custom'
    description: 'something custom for a demo'
    subscriptionRequired: true
    approvalRequired: false
    subscriptionsLimit: 2
    state: 'published'
  }
}

resource apimServiceName_starter 'Microsoft.ApiManagement/service/products@2023-03-01-preview' = {
  parent: apimService
  name: 'starter'
  properties: {
    displayName: 'Starter'
    description: 'Subscribers will be able to run 5 calls/minute up to a maximum of 100 calls/week.'
    subscriptionRequired: true
    approvalRequired: false
    subscriptionsLimit: 1
    state: 'published'
  }
}

resource apimServiceName_demo_conference_api_GetSession 'Microsoft.ApiManagement/service/apis/operations@2023-03-01-preview' = {
  parent: apimServiceName_demo_conference_api
  name: 'GetSession'
  properties: {
    displayName: 'GetSession'
    method: 'GET'
    urlTemplate: '/session/{id}'
    templateParameters: [
      {
        name: 'id'
        description: 'Format - int32.'
        type: 'integer'
        required: true
        values: []
      }
    ]
    description: 'Retreive a representation of a single session by Id'
    responses: [
      {
        statusCode: 200
        description: 'OK'
        representations: [
          {
            contentType: 'application/hal+json'
          }
          {
            contentType: 'text/plain'
          }
        ]
        headers: []
      }
    ]
  }

}

resource apimServiceName_demo_conference_api_GetSessions 'Microsoft.ApiManagement/service/apis/operations@2023-03-01-preview' = {
  parent: apimServiceName_demo_conference_api
  name: 'GetSessions'
  properties: {
    displayName: 'GetSessions'
    method: 'GET'
    urlTemplate: '/sessions'
    templateParameters: []
    description: 'A list of sessions.  Optional parameters work as filters to reduce the listed sessions.'
    request: {
      queryParameters: [
        {
          name: 'speakername'
          type: 'string'
          values: []
        }
        {
          name: 'dayno'
          description: 'Format - int32.'
          type: 'integer'
          values: []
        }
        {
          name: 'keyword'
          type: 'string'
          values: []
        }
      ]
      headers: []
      representations: []
    }
    responses: [
      {
        statusCode: 200
        description: 'OK'
        representations: [
          {
            contentType: 'application/vnd.collection+json'
          }
        ]
        headers: []
      }
    ]
  }

}

resource apimServiceName_demo_conference_api_GetSpeaker 'Microsoft.ApiManagement/service/apis/operations@2023-03-01-preview' = {
  parent: apimServiceName_demo_conference_api
  name: 'GetSpeaker'
  properties: {
    displayName: 'GetSpeaker'
    method: 'GET'
    urlTemplate: '/speaker/{id}'
    templateParameters: [
      {
        name: 'id'
        description: 'Format - int32.'
        type: 'integer'
        required: true
        values: []
      }
    ]
    responses: [
      {
        statusCode: 200
        description: 'OK'
        representations: [
          {
            contentType: 'application/vnd.hal+json'
          }
          {
            contentType: 'text/plain'
          }
        ]
        headers: []
      }
    ]
  }

}

resource apimServiceName_demo_conference_api_GetSpeakers 'Microsoft.ApiManagement/service/apis/operations@2023-03-01-preview' = {
  parent: apimServiceName_demo_conference_api
  name: 'GetSpeakers'
  properties: {
    displayName: 'GetSpeakers'
    method: 'GET'
    urlTemplate: '/speakers'
    templateParameters: []
    request: {
      queryParameters: [
        {
          name: 'dayno'
          description: 'Format - int32.'
          type: 'integer'
          values: []
        }
        {
          name: 'speakername'
          type: 'string'
          values: []
        }
      ]
      headers: []
      representations: []
    }
    responses: [
      {
        statusCode: 200
        description: 'OK'
        representations: [
          {
            contentType: 'application/vnd.collection+json'
          }
        ]
        headers: []
      }
    ]
  }

}



resource apimServiceName_demo_conference_api_GetTopic 'Microsoft.ApiManagement/service/apis/operations@2023-03-01-preview' = {
  parent: apimServiceName_demo_conference_api
  name: 'GetTopic'
  properties: {
    displayName: 'GetTopic'
    method: 'GET'
    urlTemplate: '/topic/{id}'
    templateParameters: [
      {
        name: 'id'
        description: 'Format - int32.'
        type: 'integer'
        required: true
        values: []
      }
    ]
    responses: [
      {
        statusCode: 200
        description: 'OK'
        representations: [
          {
            contentType: 'application/hal+json'
          }
        ]
        headers: []
      }
    ]
  }

}

resource apimServiceName_demo_conference_api_GetTopics 'Microsoft.ApiManagement/service/apis/operations@2023-03-01-preview' = {
  parent: apimServiceName_demo_conference_api
  name: 'GetTopics'
  properties: {
    displayName: 'GetTopics'
    method: 'GET'
    urlTemplate: '/topics'
    templateParameters: []
    request: {
      queryParameters: [
        {
          name: 'dayno'
          description: 'Format - int32.'
          type: 'integer'
          values: []
        }
      ]
      headers: []
      representations: []
    }
    responses: [
      {
        statusCode: 200
        description: 'OK'
        representations: [
          {
            contentType: 'application/vnd.collection+json'
          }
        ]
        headers: []
      }
    ]
  }

}


resource apimServiceName_demo_conference_api_default 'Microsoft.ApiManagement/service/apis/schemas@2023-03-01-preview' = {
  parent: apimServiceName_demo_conference_api
  name: 'default'
  properties: {
    contentType: 'application/vnd.ms-azure-apim.swagger.definitions+json'
    document: {}
  }

}

// wiki - preview feature that has been retired (removed)

// in the consumption plans, the rate limiting policy must be applied at the api level
// in the standard and developer plans, the rate limiting policy can be applied at the operation level

var policyPart1 = '''<!--    IMPORTANT:
    - Policy elements can appear only within the <inbound>, <outbound>, <backend> section elements.
    - To apply a policy to the incoming request (before it is forwarded to the backend service), place a corresponding policy element within the <inbound> section element.
    - To apply a policy to the outgoing response (before it is sent back to the caller), place a corresponding policy element within the <outbound> section element.
    - To add a policy, place the cursor at the desired insertion point and select a policy from the sidebar.
    - To remove a policy, delete the corresponding policy statement from the policy document.
    - Position the <base> element within a section element to inherit all policies from the corresponding section element in the enclosing scope.
    - Remove the <base> element to prevent inheriting policies from the corresponding section element in the enclosing scope.
    - Policies are applied in the order of their appearance, from the top down.
    - Comments within policy elements are not supported and may disappear. Place your comments between policy elements or at a higher level scope.
-->
<policies>
  <inbound>
    <base />'''

/// conditionally add the rate limiting policy based on the SKU. It is not allowed in the consumption SKU
/// and string interpolation is not supported in multi-line strings in bicep yet
var rateLimitPolicy = apimSku == 'Consumption' ? '' : '''<rate-limit-by-key calls="5" renewal-period="20" counter-key="@(context.Subscription?.Key ?? &quot;anonymous&quot;)" />''' 

var policyPart2 = '''
  </inbound>
  <backend>
    <base />
  </backend>
  <outbound>
    <base />
    <set-header name="X-Powered-By" exists-action="delete" />
    <set-header name="X-AspNet-Version" exists-action="delete" />
  </outbound>
  <on-error>
    <base />
  </on-error>
</policies>'''

var policyComplete = '${policyPart1}\n${rateLimitPolicy}\n${policyPart2}'

resource apimServiceName_demo_conference_api_GetSpeakers_policy 'Microsoft.ApiManagement/service/apis/operations/policies@2023-03-01-preview' =  {
  parent: apimServiceName_demo_conference_api_GetSpeakers
  name: 'policy'
  properties: {
    value: policyComplete
    format: 'xml'
  }

}



resource apimServiceName_mtt_custom_default 'Microsoft.ApiManagement/service/products/apiLinks@2023-03-01-preview' = {
  parent: apimServiceName_mtt_custom
  name: 'default'
  properties: {
    apiId: apimServiceName_demo_conference_api.id
  }

}
