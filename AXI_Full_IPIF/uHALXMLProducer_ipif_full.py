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
        target_label = self.getProperty(fragment, 'target_label')

        #Messy ... find the target module with "label" target_lable
        targetFragment = None
        for key, frag in self.factory._fullFragment.items():
            try:
                if self.getProperty(frag, "label") == target_label:
                    targetFragment = frag
                    break
            except(KeyError, TypeError):
                pass

        if targetFragment == None:
            raise KeyError(f"'{target_label}' not found in fragement")

        # forward work to producer for target
        target_key = "_".join([target_name, target_intf])
        return self.factory.getImpl(target_key)(targetFragment, xmlDir, address, target_label)
