{
    local arm = self,

    resources:: {

        Resource: {
            local resource = self,

            type: error "'type' is a required property of resource",
            name: error "'name' is a required property of resource",
            location: "[resourceGroup().location]",
            apiVersion: error "'apiVersion' is a requried property of resource",

            dependsOn: [],

            id():: 
                "[resourceId('%s', '%s')]" % [ resource.type, resource.name ],
        },

        Template: {
            "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
            "contentVersion": "1.0.0.0",
            resources: [],
        },
    },

    network:: {

        NetworkResource: arm.resources.Resource {
            apiVersion: '2017-10-01'    
        },

        Subnet: arm.network.NetworkResource {
            local subnet = self,

            type: 'Microsoft.Network/virtualNetwork/subnets',

            addressPrefix:: error "'addressPrefix' is a required property for subnets",
            networkSecurityGroup:: null,
            serviceEndpoints:: [],
            routeTable:: null,
            
            properties: {
                addressPrefix: subnet.addressPrefix,
                [if subnet.networkSecurityGroup != null then 'networkSecurityGroup']: {
                    id: subnet.networkSecurityGroup.id()
                },
                [if subnet.routeTable != null then 'routeTable']: subnet.routeTable,
            },
        },

        NetworkSecurityGroup: arm.network.NetworkResource {
            local networkSecurityGroup = self,

            type: 'Microsoft.Network/networkSecurityGroups',

            securityRules:: [],

            properties: {
                securityRules: [
                    {
                        name: s.name
                    }
                    for s in networkSecurityGroup.securityRules
                ],
            }
        },

        VirtualNetwork: arm.network.NetworkResource {
            local virtualNetwork = self,

            type: 'Microsoft.Network/virtualNetworks',
            addressPrefixes:: [ "10.0.0.0/16" ],
            networkSecurityGroup:: null,
            serviceEndpoints:: [],
            subnets:: [ arm.network.Subnet { name: 'default', addressPrefix:: virtualNetwork.addressPrefixes[0] } ],

            properties: {
                addressSpace: {
                    addressPrefixes: virtualNetwork.addressPrefixes
                },
                subnets: [
                    {
                        name: s.name,
                        properties: s.properties {
                            serviceEndpoints +: [
                                {service: se }
                                for se in virtualNetwork.serviceEndpoints + s.serviceEndpoints
                            ]
                        },
                    }
                    for s in virtualNetwork.subnets
                ],
            },
        },
    },

    compute:: {

        ComputeResource: arm.resources.Resource {
            apiVersion: '2017-10-01'
        },

        VirtualMachine: arm.compute.ComputeResource {
            type: 'Microsoft.Compute/virtualMachines'
        },
    },
}
