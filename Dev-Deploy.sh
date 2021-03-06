# USAGE:
# bash deploy_all.sh

az login

resourceGroupName='WTS-dev'
campaignStorageAccountName='welltoldstory123storage'
location=westeurope
subscription=03d4bf58-7450-4634-983c-1f65e400e2ae

# Change this to the subscription that you want to use, required to avoid using the 'default' one if you have access to 
# multiple subscription with your user
az account set --subscription $subscription

# Create a resource group if it does not exists
rgExists=(as group exists -n $resourceGroupName)
if [ $rgExists != 'true' ]
then
    az group create --name $resourceGroupName --location $location
fi

# Deploy ServiceBus
validTemplate=(az group deployment validate --resource-group $resourceGroupName --template-file Deploy-ServiceBus.json --parameters @Deploy-ServiceBus.parameters.json --verbose)
if [ $validTemplate != 'true' ]
then
    az group deployment create --name Deploy-ServiceBus --resource-group $resourceGroupName --template-file Deploy-ServiceBus.json --parameters @Deploy-ServiceBus.parameters.json --verbose
fi

# Deploy CosmosDB
#


# Deploy WTS-Functions
validTemplate=(az group deployment validate --resource-group $resourceGroupName --template-file Deploy-WTS-Functions.json --parameters @Deploy-WTS-Functions.parameters.json --verbose)
if [ $validTemplate != 'true' ]
then
    az group deployment create --name Deploy-WTS-Functions --resource-group $resourceGroupName --template-file Deploy-WTS-Functions.json --parameters @Deploy-WTS-Functions.parameters.json --verbose

    # Retrieve the Storage Account connection string 
    connectionString=$(az storage account show-connection-string --name $campaignStorageAccountName --resource-group $resourceGroupName --query connectionString --output tsv)
    # Create the Campaign table
    az storage table create --name 'Campaigns' --connection-string $connectionString
fi

# Deploy WTS-Webhook-Functions
validTemplate=(az group deployment validate --resource-group $resourceGroupName --template-file Deploy-WTS-Webhook-Functions.json --parameters @Deploy-WTS-Webhook-Functions.parameters.json --verbose)
if [ $validTemplate != 'true' ]
then
    az group deployment create --name Deploy-WTS-WebHook-Functions --resource-group $resourceGroupName --template-file Deploy-WTS-Webhook-Functions.json --parameters @Deploy-WTS-Webhook-Functions.parameters.json --verbose
fi

# Deploy WTS-SMSPoll-Functions
validTemplate=(az group deployment validate --resource-group $resourceGroupName --template-file Deploy-WTS-SMSPoll-Functions.json --parameters @Deploy-WTS-SMSPoll-Functions.parameters.json --verbose)
if [ $validTemplate != 'true' ]
then
    az group deployment create --name WTS-SMSPoll-Functions --resource-group $resourceGroupName --template-file Deploy-WTS-SMSPoll-Functions.json --parameters @Deploy-WTS-SMSPoll-Functions.parameters.json --verbose
fi

