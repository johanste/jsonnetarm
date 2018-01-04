local arm = import '../lib/armpp.libsonnet';
local template = arm.resources.Template;

local sharedNsg = arm.network.NetworkSecurityGroup { name: 'securit' };

template
    .addResource(sharedNsg)
    .addResource(arm.network.VirtualNetwork { name: 'default' })
    .addResource(arm.network.Subnet { name: 'default/daSubnet', addressPrefix: '10.0.0.0/24' })
    .addResource(arm.network.VirtualNetwork { name: 'custom'}
        .addSubnet('frontEnd', { addressPrefix: '10.0.0.0/24', networkSecurityGroup: sharedNsg })
        .addSubnet('backend', { addressPrefix: '10.0.1.0/24' })    
    )
