@description('Environment of the web app')
param environment string = 'dev'

@description('Location of services')
param location string = resourceGroup().location

var webAppName = '${uniqueString(resourceGroup().id)}-${environment}'
var appServicePlanName = '${uniqueString(resourceGroup().id)}-mpnp-asp'
var logAnalyticsName = '${uniqueString(resourceGroup().id)}-mpnp-la'
var appInsightsName = '${uniqueString(resourceGroup().id)}-mpnp-ai'
var sku = 'S1'
var registryName = '${uniqueString(resourceGroup().id)}mpnpreg'
var registrySku = 'Standard'
var imageName = 'techexcel/dotnetcoreapp'
var startupCommand = ''

// TODO: complete this script
resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
    name: appServicePlanName
    location: location
    sku: {
        name: sku
        tier: 'Standard'
        size: 'S1'
    }
}

resource webApp 'Microsoft.Web/sites@2021-02-01' = {
    name: webAppName
    location: location
    properties: {
        serverFarmId: appServicePlan.id
    }
}

resource appInsights 'Microsoft.Insights/components@2021-02-01' = {
    name: appInsightsName
    location: location
    properties: {
        Application_Type: 'web'
    }
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
    name: registryName
    location: location
    sku: {
        name: registrySku
    }
}

resource containerRegistryWebApp 'Microsoft.Web/sites@2021-02-01' = {
    name: '${webAppName}-acr'
    location: location
    properties: {
        serverFarmId: appServicePlan.id
        siteConfig: {
            appSettings: [
                {
                    name: 'DOCKER_REGISTRY_SERVER_URL'
                    value: containerRegistry.loginServerUrl
                },
                {
                    name: 'DOCKER_REGISTRY_SERVER_USERNAME'
                    value: containerRegistry.adminUsername
                },
                {
                    name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
                    value: containerRegistry.adminPassword
                },
                {
                    name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
                    value: 'false'
                }
            ]
        }
    }
}