from uhalXMLProducerBase import UHALXMLProducerBase

import os
import shutil

top_level_node_template = '<node id="%(label)s"	    module="file://modules/%(xml)s"	          address="%(addr)s"/>'

# Class MUST be named UHALXMLProducer
class UHALXMLProducer(UHALXMLProducerBase):
    def __init__(self, factory):
        # Class MUST have "name" attribute defined and this must match the dtbo name of the IP it is meant to manage 
        self.name = "static_pin_tester"

    # Class MUST define produce_impl which will produce the xml map file(s) and return the top level node for the module 
    def produce_impl(self, fragment, xmlDir, address, label):

        local_dir = os.path.dirname(os.path.realpath(__file__))
        
        topXML = "%s.xml"%label

        shutil.copyfile(os.path.join(local_dir, "static_pin_tester.xml"), os.path.join(xmlDir, "modules", topXML))

        return top_level_node_template%{"label": label, "xml": topXML, "addr": address}
