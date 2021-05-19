from uhalXMLProducerBase import UHALXMLProducerBase

import os

clk_mon_template = """<node>
%(clocks)s
</node>
"""

clk_mon_clock_template = """    <node id="rate%(iClk)i"              address="0x%(addr)x" permission="r"  description="Clock rate of clock %(iClk)i in kHz"/>
    <node id="pllunlock%(iClk)i"         address="0x%(addr2)x" permission="rw" description="Number of PLL unlocks for clock %(iClk)i, write 1 to reset"/>"""

top_level_node_template = '<node id="%(label)s"	    module="file://modules/%(xml)s"	          address="%(addr)s"/>'

# Class MUST be named UHALXMLProducer
class UHALXMLProducer(UHALXMLProducerBase):
    def __init__(self, factory):
        self.name = "clk_mon_IPIF"

    def produce_impl(self, fragment, xmlDir, address, label):

        n_chip = int(self.getProperty(fragment, 'n_target', 1), 0)

        xmlFile = "%s.xml"%label

        with open(os.path.join(xmlDir, "modules", xmlFile), "w") as f:
            f.write(clk_mon_template%{"clocks":"\n".join([clk_mon_clock_template%{"iClk":iClk, "addr":2*iClk, "addr2":2*iClk + 1} for iClk in range(n_chip)])})

        return top_level_node_template%{"label":label, "addr":address, "xml":xmlFile}
