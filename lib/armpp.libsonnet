local core = import 'arm.libsonnet';

core {
    local module = self,

    resources +: {

        Template +: {
            local template = self,

            addResource(resource):: template {
                resources +: [ resource ]
            },

            findResource(name=null, type=null)::
                local matches = [r for r in template.resources if
                                    (name == r.name || name == null) &&
                                    (type == r.type || type == null)
                                 ];
                matches[0],
        }
    },

    network +: {

        VirtualNetwork +: {
            local virtualNetwork = self,

            addSubnet(name = 'default', overrides = {}):: virtualNetwork {
                local subnet = module.network.Subnet { name: name, addressPrefix: virtualNetwork.addressPrefixes[0] },
                subnets +: [ subnet + overrides ]
            }
        }
    }
}
