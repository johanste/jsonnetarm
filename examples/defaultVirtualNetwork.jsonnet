local arm = import '../lib/arm.libsonnet';

local frontendNsg = arm.network.NetworkSecurityGroup { name: 'frontend' };


arm.resources.Template {
    resources +: [
        // Simplest form of virtual network
        // TODO: should you have to specify name? Probably not. Should
        // we have a DefaultVirtualNetwork template that extends the VirtualNetwork template. 
        // Possibly :)
        arm.network.VirtualNetwork {
            name: 'default'
        },
        frontendNsg,
        // Virtual network with two subnets. TODO: if we create a function off the vnet
        // instance to create the subnet, we could default/simplify address space splits
        // and prefixes
        arm.network.VirtualNetwork {
            name: 'customSubnets',
            addressPrefixes: [ '10.0.0.0/16' ],
            serviceEndpoints: [ 'Microsoft.Storage' ],
            subnets: [
                arm.network.Subnet {
                    name: 'frontend', 
                    addressPrefix: '10.0.0.0/24',
                    networkSecurityGroup: frontendNsg,
                },
                arm.network.Subnet {
                    name: 'backend',
                    addressPrefix: '10.0.1.0/24',
                    serviceEndpoints: [ 'Microsoft.Sql' ],
                   },
            ],
            dependsOn +: [ frontendNsg.name ],
        },
    ]  
}