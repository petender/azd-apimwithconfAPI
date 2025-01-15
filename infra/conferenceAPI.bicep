@description('The location used for all deployed resources')
param location string = resourceGroup().location

@description('Tags that will be applied to all resources')
param tags object = {}



@description('Id of the user or app to assign application roles')
param principalId string = ''

var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = uniqueString(subscription().id, resourceGroup().id, location)

// Monitor application with Azure Monitor
module monitoring 'br/public:avm/ptn/azd/monitoring:0.1.0' = {
  name: 'monitoring'
  params: {
    logAnalyticsName: '${abbrs.operationalInsightsWorkspaces}${resourceToken}'
    applicationInsightsName: '${abbrs.insightsComponents}${resourceToken}'
    applicationInsightsDashboardName: '${abbrs.portalDashboards}${resourceToken}'
    location: location
    tags: tags
  }
}


module conferenceApiIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.2.1' = {
  name: 'conferenceApiidentity'
  params: {
    name: '${abbrs.managedIdentityUserAssignedIdentities}conferenceApi-${resourceToken}'
    location: location
  }
}

module serverfarm 'br/public:avm/res/web/serverfarm:0.4.0' = {
  name: 'serverfarmDeployment'
  params: {
    name: '${abbrs.webServerFarms}WebApp${resourceToken}'
    location: location
    tags: tags
    kind: 'windows'
    skuName: 'B1'
    skuCapacity: 1
    diagnosticSettings: [
      {
        name: 'basicSetting'
        workspaceResourceId: monitoring.outputs.logAnalyticsWorkspaceResourceId
      }
    ]
  }
}

module conferenceAPI 'br/public:avm/res/web/site:0.12.0' = {
  name: 'conferenceAPIDeployment'
  params: {
    kind: 'app'
    tags: union(tags, {
      'azd-service-name': 'conferenceAPI'
    })
    name: '${abbrs.webSitesAppService}conferenceAPI${resourceToken}'
    serverFarmResourceId: serverfarm.outputs.resourceId
    
    httpsOnly: true
    location: location
    managedIdentities: {
      systemAssigned: true
    }

    publicNetworkAccess: 'Enabled'

    siteConfig: {
      alwaysOn: true
      metadata: [
        {
          name: 'CURRENT_STACK'
          value: 'dotnetcore'
        }
      ]
    }
    
  }
}


// Create a keyvault to store secrets
module keyVault 'br/public:avm/res/key-vault/vault:0.6.1' = {
  name: 'keyvault'
  params: {
    name: '${abbrs.keyVaultVaults}${resourceToken}'
    location: location
    tags: tags
    enableRbacAuthorization: false
    accessPolicies: [
      {
        objectId: principalId
        permissions: {
          secrets: [ 'get', 'list' ]
        }
      }
      {
        objectId: conferenceApiIdentity.outputs.principalId
        permissions: {
          secrets: [ 'get', 'list' ]
        }
      }
    ]
    secrets: [
    ]
  }
}

output AZURE_RESOURCE_CONFERENCE_API_ID string = conferenceAPI.outputs.resourceId
output WebAppURL string = conferenceAPI.outputs.defaultHostname

