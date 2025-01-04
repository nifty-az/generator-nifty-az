metadata name = '<%- solutionSlug %>'
metadata description = 'Deploys the infrastructure for <%- solutionName %>'
metadata author = '<%- authorContact %>'

/* -------------------------------------------------------------------------- */
/*                                 PARAMETERS                                 */
/* -------------------------------------------------------------------------- */

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@description('Principal ID of the user runing the deployment')
param azurePrincipalId string

@description('Extra tags to be applied to provisioned resources')
param extraTags object = {}

@description('Location for all resources')
param location string = resourceGroup().location

/* ---------------------------- Shared Resources ---------------------------- */

@maxLength(63)
@description('Name of the log analytics workspace to deploy. If not specified, a name will be generated. The maximum length is 63 characters.')
param logAnalyticsWorkspaceName string = ''

@maxLength(255)
@description('Name of the application insights to deploy. If not specified, a name will be generated. The maximum length is 255 characters.')
param applicationInsightsName string = ''

/* -------------------------------------------------------------------------- */
/*                                  VARIABLES                                 */
/* -------------------------------------------------------------------------- */

@description('Abbreviations to be used in resource names loaded from a JSON file')
var abbreviations = loadJsonContent('./abbreviations.json')

@description('Generate a unique token to make global resource names unique')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))

@description('Name of the environment with only alphanumeric characters. Used for resource names that require alphanumeric characters only')
var alphaNumericEnvironmentName = replace(replace(environmentName, '-', ''), ' ', '')

@description('Tags to be applied to all provisioned resources')
var tags = union(
  {
    'azd-env-name': environmentName
    solution: '<%= solutionSlug %>'
  },
  extraTags
)

/* --------------------- Globally Unique Resource Names --------------------- */

/****************************** NiftyAZ Tip ***********************************
 * Define here all the globally unique resources names. They should
 * always include resourceToken to ensure uniqueness.
 ******************************************************************************/

/* ----------------------------- Resource Names ----------------------------- */

/****************************** NiftyAZ Tip ***********************************
 * Define here all the all other resource names. Use
 * variable alphaNumericEnvironmentName for names that should not
 * contain non-alphanumeric characters. We use the take() function
 * to shorten the names to the maximum length allowed by Azure.
 ******************************************************************************/

var _applicationInsightsName = !empty(applicationInsightsName)
  ? applicationInsightsName
  : take('${abbreviations.insightsComponents}${environmentName}', 255)
var _logAnalyticsWorkspaceName = !empty(logAnalyticsWorkspaceName)
  ? logAnalyticsWorkspaceName
  : take('${abbreviations.operationalInsightsWorkspaces}${environmentName}', 63)

/* -------------------------------------------------------------------------- */
/*                                  RESOURCES                                 */
/* -------------------------------------------------------------------------- */

/****************************** NiftyAZ Tip ***********************************
 * Favor using Azure Verified Modules over custom Bicep modules
 * see https://aka.ms/bicep/aztip/azure-verified-modules for more
 * information on Azure Verified Modules
 ******************************************************************************/

module logAnalyticsWorkspace 'br/public:avm/res/operational-insights/workspace:0.9.1' = {
  name: 'workspaceDeployment'
  params: {
    name: _logAnalyticsWorkspaceName
    location: location
    tags: tags
    dataRetention: 30
  }
}

module appInsightsComponent 'br/public:avm/res/insights/component:0.4.2' = {
  name: _applicationInsightsName
  params: {
    name: _applicationInsightsName
    location: location
    workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
  }
}

/* -------------------------------------------------------------------------- */
/*                                   OUTPUTS                                  */
/* -------------------------------------------------------------------------- */

/****************************** NiftyAZ Tip ***********************************
 * Outputs are automatically saved in the local azd environment
 * To see these outputs, run `azd env get-values`,  or
 * `azd env get-values --output json` for json output.
 * To generate your own `.env` file run `azd env get-values > .env`
 ******************************************************************************/

@description('Principal ID of the user runing the deployment')
output AZURE_PRINCIPAL_ID string = azurePrincipalId
