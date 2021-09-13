from uhalXMLProducerBase import UHALXMLProducerBase

# Class MUST be named UHALXMLProducer
class UHALXMLProducer(UHALXMLProducerBase):
    def __init__(self, factory):
        # Class MUST have "name" attribute defined and this must match the dtbo name of the IP it is meant to manage 
        self.name = "ipif_full"

        self.factory = factory

    # Class MUST define produce_impl which will produce the xml map file(s) and return the top level node for the module 
    def produce_impl(self, fragment, xmlDir, address, label):

        #get target variables 
        target_name  = self.getProperty(fragment, 'target_name')
        target_intf  = self.getProperty(fragment, 'target_intf')
        target_label = self.getProperty(fragment, 'target_label')

        #local label
        try:
            new_label = self.getProperty(fragment, 'label')
        except(KeyError):
            new_label = "_".join([target_label, target_intf])

        targetFragment = self.getModule(target_label)
        
        target_key = "_".join([target_name, target_intf])
        if targetFragment == None:
            return self.factory.getImpl(target_key)(fragment, xmlDir, address, new_label)
        else:
            # forward work to producer for target
            return self.factory.getImpl(target_key)(targetFragment, xmlDir, address, new_label)

