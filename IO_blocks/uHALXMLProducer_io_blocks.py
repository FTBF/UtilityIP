from uhalXMLProducerBase import UHALXMLProducerBase

import os
import shutil

IO_blocks_channel_template = '    <node id="link%(iLink)i"   address="0x%(addr)x" module="file://IO_blocks_channel.xml" description="link %(iLink)i IO control"/>'

IO_blocks_template = """<node>
    <node id="global"   address="0x0" module="file://IO_blocks_global.xml" description="Global registers for IO control" />
%(links)s
</node>
"""

top_level_node_template = '<node id="%(label)s"	    module="file://modules/%(xml)s"	          address="%(addr)s"/>'

# Class MUST be named UHALXMLProducer
class UHALXMLProducer(UHALXMLProducerBase):
    def __init__(self, factory):
        # Class MUST have "name" attribute defined and this must match the dtbo name of the IP it is meant to manage 
        self.name = "IO_blocks_IPIF"

    # Class MUST define produce_impl which will produce the xml map file(s) and return the top level node for the module 
    def produce_impl(self, fragment, xmlDir, address, label):

        local_dir = os.path.dirname(os.path.realpath(__file__))

        nreg = int(self.getProperty(fragment, "n_target_regs"), 0)
        nchip = int(self.getProperty(fragment, "n_target"), 0)
        
        shutil.copyfile(os.path.join(local_dir, "IO_blocks_global.xml"), os.path.join(xmlDir, "modules", "IO_blocks_global.xml"))

        shutil.copyfile(os.path.join(local_dir, "IO_blocks_channel.xml"), os.path.join(xmlDir, "modules", "IO_blocks_channel.xml"))

        topXML = "%s.xml"%label
        with open(os.path.join(xmlDir, "modules", topXML), "w") as f:
            channels = [IO_blocks_channel_template%{"iLink":iLink, "addr":(iLink+1)*nreg} for iLink in range(nchip-1)]
            f.write(IO_blocks_template%{"links": "\n".join(channels)})

        return top_level_node_template%{"label": label, "xml": topXML, "addr": address}
