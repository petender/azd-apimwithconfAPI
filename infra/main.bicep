targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

param apimServiceName string = ''

@minLength(1)
@description('Primary location for all resources')
param location string

@description('Id of the user or app to assign application roles')
param principalId string

@description('The SKU of the APIM instance')
@allowed([
  'Developer'
  'Consumption'
  'Standard'
])
param apimSku string

// Tags that should be applied to all resources.
// 
// Note that 'azd-service-name' tags should be applied separately to service host resources.
// Example usage:
//   tags: union(tags, { 'azd-service-name': <service name in azure.yaml> })
var tags = {
  'azd-env-name': environmentName
  'SecurityControl': 'Ignore'
}

var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${environmentName}'
  location: location
  tags: tags
}

// deploy the conferenceAPI app first, as it is required for the APIM deployment
module conferenceAPI 'conferenceAPI.bicep' = {
  scope: rg
  name: 'conferenceAPI'
  params: {
    location: location
    tags: tags
    principalId: principalId

  }
}

module apim 'apimdeploy.bicep' = {
  name: 'apim'
  scope: rg
  params: {
    apimServiceName: environmentName
    name: !empty(apimServiceName) ? apimServiceName : '${abbrs.apiManagementService}${resourceToken}'
    location: location
    tags: tags
    apimSku: apimSku
    WebAppURL: conferenceAPI.outputs.WebAppURL
  }

}

output AZURE_RESOURCE_CONFERENCE_API_URL string = conferenceAPI.outputs.WebAppURL

