# USAGE:
# bash deploy_all.sh

az login

resourceGroupName='WTS-dev'
location=westeurope
subscription=64622283-fc87-4edf-900d-f0ee873b3d88

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
fi

# Deploy WTS-SMSPoll-Functions
validTemplate=(az group deployment validate --resource-group $resourceGroupName --template-file Deploy-WTS-SMSPoll-Functions.json --parameters @Deploy-WTS-SMSPoll-Functions.parameters.json --verbose)
if [ $validTemplate != 'true' ]
then
    az group deployment create --name WTS-SMSPoll-Functions --resource-group $resourceGroupName --template-file Deploy-WTS-SMSPoll-Functions.json --parameters @Deploy-WTS-SMSPoll-Functions.parameters.json --verbose
fi

