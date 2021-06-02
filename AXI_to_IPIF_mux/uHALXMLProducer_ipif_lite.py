from uhalXMLProducerBase import UHALXMLProducerBase

import os
import distutils.util

mux_my_ip_template = """<node>
%(ips)s
</node>
"""

top_level_node_template = '<node id="%(label)s"	    module="file://modules/%(xml)s"	          address="%(addr)s"/>'

# Class MUST be named UHALXMLProducer
class UHALXMLProducer(UHALXMLProducerBase):
    def __init__(self, factory):
        # Class MUST have "name" attribute defined and this must match the dtbo name of the IP it is meant to manage 
        self.name = "ipif_lite"

        self.factory = factory

    # CLass MUST define produce_impl which will produce the xml map file(s) and return the top level node for the module 
    def produce_impl(self, fragment, xmlDir, address, label):

        #get target variables 
        target_names  = self.getProperty(fragment, 'target_names', slice(1, None))
        target_intfs  = self.getProperty(fragment, 'target_intfs', slice(1, None))
        target_labels = self.getProperty(fragment, 'target_labels', slice(1, None))

        #get setup variables
        n_reg  = int(self.getProperty(fragment, 'n_target_regs', 1), 0)
        n_chip = int(self.getProperty(fragment, 'n_target', 1), 0)
        mux    = distutils.util.strtobool(self.getProperty(fragment, 'mux_by_chip', 1))

        if not mux:
            targetFragment = self.getModule(target_labels[0])

            #local label
            try:
                new_label = self.getProperty(fragment, 'label')
            except(KeyError):
                new_label = target_labels[0]
                
            # forward work to producer for target
            target_key = "_".join([target_names[0], target_intfs[0]])
            if targetFragment == None:
                return self.factory.getImpl(target_key)(fragment, xmlDir, address, new_label)
            else:
                return self.factory.getImpl(target_key)(targetFragment, xmlDir, address, new_label)

        else:
            ip_xmls = []
            
            #Messy ... find the target module with "label" target_lable
            for iTarget, (target_label, target_name, target_intf) in enumerate(zip(target_labels, target_names, target_intfs)):
                targetFragment = self.getModule(target_label)

                #local label
                try:
                    new_label = self.getProperty(fragment, 'label')
                except(KeyError):
                    new_label = target_label

                # forward work to producer for target
                target_key = "_".join([target_name, target_intf])
                if targetFragment == None:
                    ip_xmls.append(self.factory.getImpl(target_key)(fragment, xmlDir, n_reg*iTarget, (iTarget, new_label)))
                else:
                    ip_xmls.append(self.factory.getImpl(target_key)(targetFragment, xmlDir, n_reg*iTarget, (iTarget, new_label)))

            xmlName = "%s.xml"%label
            with open(os.path.join(xmlDir, "modules", xmlName), "w") as f:
                f.write(mux_my_ip_template%{"ips":"\n".join(ip_xmls)})

            return top_level_node_template%{"label":label, "addr":address, "xml":xmlName}
