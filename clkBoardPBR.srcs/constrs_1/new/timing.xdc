# All PS7 FCLKs are derived from the same IO PLL, but the PS7 timing model
# exposes each of them as an independent primary clock. Paths between them are
# reported as "related with no common primary clock" and the resulting slack is
# meaningless, because no clock pessimism removal is possible.
#
# The crossings between these two domains are:
#   - the clk40MCounter asynchronous clear, driven by enable
#   - the clear pulse, transferred by an XPM CDC macro
#   - the clock mux select, asynchronous by construction and changed only
#     while the run is stopped
#
# This file is only meaningful during implementation: clk_fpga_1 does not exist
# yet at synthesis time. Set used_in_synthesis to false on this file, otherwise
# the constraint silently applies to an empty set of objects.
set_clock_groups -asynchronous \
    -group [get_clocks clk_fpga_0] \
    -group [get_clocks clk_fpga_1]

# CLK40_IN sits on IO_L7P_T1_33, which is not a clock-capable pin, and the
# connector wiring does not allow moving it to an MRCC/SRCC pair. The signal
# must still reach the BUFGCTRL because it is forwarded to the front-end
# boards, so the dedicated clock route check is waived deliberately.
# The net is looked up rather than named: it crosses three hierarchy levels and
# is renamed during flattening. The lookup finds nothing at synthesis time and
# reports [Vivado 12-4739]; that message is expected here. A real miss cannot go
# unnoticed either, because placement then stops with [Place 30-574].
set_property CLOCK_DEDICATED_ROUTE FALSE \
    [get_nets -of_objects [get_pins -hier -filter {NAME =~ *clk40MCtrlInst/I0}]]
