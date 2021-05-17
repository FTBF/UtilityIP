from uhalXMLProducerBase import UHALXMLProducerBase

# Class MUST be named UHALXMLProducer
class UHALXMLProducer(UHALXMLProducerBase):
    def __init__(self, factory):
        # Class MUST have "name" attribute defined and this must match the dtbo name of the IP it is meant to manage 
        self.name = "ipif_full"

        self.factory = factory

    # CLass MUST define produce_impl which will produce the xml map file(s) and return the top level node for the module 
    def produce_impl(self, fragment, xmlDir, address, label):

        #get target variables 
        target_name  = self.getProperty(fragment, 'target_name')
        target_intf  = self.getProperty(fragment, 'target_intf')

        # forward work to producer for target
        target_key = "_".join([target_name, target_intf])
        return self.factory[target_key](fragment, xmlDir)
