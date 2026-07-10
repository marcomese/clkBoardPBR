##############################################################################
# EXTTRG - Connettore JTRG
##############################################################################
set_property PACKAGE_PIN M19 [get_ports {EXT_TRIG_IN_P[1]}]
set_property PACKAGE_PIN M20 [get_ports {EXT_TRIG_IN_N[1]}]
set_property IOSTANDARD LVDS_25 [get_ports {EXT_TRIG_IN_P[1]}]
set_property IOSTANDARD LVDS_25 [get_ports {EXT_TRIG_IN_N[1]}]


##############################################################################
# GPS1 - Connettore JGPS1&2B
##############################################################################

set_property PACKAGE_PIN A21 [get_ports {GPS_EN[0]}]
set_property PACKAGE_PIN B19 [get_ports {gps_rxd[0]}]
set_property PACKAGE_PIN A22 [get_ports {gps_txd[0]}]
set_property PACKAGE_PIN H22 [get_ports {gps_1pps_ext[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {GPS_EN[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gps_rxd[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gps_txd[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gps_1pps_ext[0]}]

##############################################################################
# GPS2 - Connettore JGPS1&2A
##############################################################################

set_property PACKAGE_PIN B20 [get_ports {GPS_EN[1]}]
set_property PACKAGE_PIN G16 [get_ports {gps_rxd[1]}]
set_property PACKAGE_PIN G15 [get_ports {gps_txd[1]}]
set_property PACKAGE_PIN G22 [get_ports {gps_1pps_ext[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {GPS_EN[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gps_rxd[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gps_txd[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gps_1pps_ext[1]}]

##############################################################################
# JLVDS0&1A - Connettore 0 (Bank 35)
##############################################################################

# SPB_GTU_CLK_OUT0 [OUTPUT] B35_L18
set_property PACKAGE_PIN B21 [get_ports GTU_CLK_OUT_P[0]]
set_property PACKAGE_PIN B22 [get_ports GTU_CLK_OUT_N[0]]
set_property IOSTANDARD LVDS_25 [get_ports GTU_CLK_OUT_P[0]]
set_property IOSTANDARD LVDS_25 [get_ports GTU_CLK_OUT_N[0]]

# 1PPS_OUT0 [OUTPUT] B35_L17
set_property PACKAGE_PIN E21 [get_ports PPS_OUT_P[0]]
set_property PACKAGE_PIN D21 [get_ports PPS_OUT_N[0]]
set_property IOSTANDARD LVDS_25 [get_ports PPS_OUT_P[0]]
set_property IOSTANDARD LVDS_25 [get_ports PPS_OUT_N[0]]

# TRIG_L1_IN0 [INPUT] B35_L6
set_property PACKAGE_PIN G17 [get_ports TRIG_L1_IN_P[0]]
set_property PACKAGE_PIN F17 [get_ports TRIG_L1_IN_N[0]]
set_property IOSTANDARD LVDS_25 [get_ports TRIG_L1_IN_P[0]]
set_property IOSTANDARD LVDS_25 [get_ports TRIG_L1_IN_N[0]]

# BUSY_IN0 [INPUT] B35_L14
set_property PACKAGE_PIN D20 [get_ports BUSY_IN_P[0]]
set_property PACKAGE_PIN C20 [get_ports BUSY_IN_N[0]]
set_property IOSTANDARD LVDS_25 [get_ports BUSY_IN_P[0]]
set_property IOSTANDARD LVDS_25 [get_ports BUSY_IN_N[0]]

# EXT_TRIG_OUT0 [OUTPUT] B35_L22
set_property PACKAGE_PIN G20 [get_ports EXT_TRIG_OUT_P[0]]
set_property PACKAGE_PIN G21 [get_ports EXT_TRIG_OUT_N[0]]
set_property IOSTANDARD LVDS_25 [get_ports EXT_TRIG_OUT_P[0]]
set_property IOSTANDARD LVDS_25 [get_ports EXT_TRIG_OUT_N[0]]

# CLK40_OUT0 [OUTPUT] B35_L1
set_property PACKAGE_PIN F16 [get_ports CLK40_OUT0_P[0]]
set_property PACKAGE_PIN E16 [get_ports CLK40_OUT0_N[0]]
set_property IOSTANDARD LVDS_25 [get_ports CLK40_OUT0_P[0]]
set_property IOSTANDARD LVDS_25 [get_ports CLK40_OUT0_N[0]]

##############################################################################
# JLVDS0&1B - Connettore 1 (Bank 35)
##############################################################################

# GTU_CLK_OUT1 [OUTPUT] B35_L8
set_property PACKAGE_PIN B16 [get_ports GTU_CLK_OUT_P[1]]
set_property PACKAGE_PIN B17 [get_ports GTU_CLK_OUT_N[1]]
set_property IOSTANDARD LVDS_25 [get_ports GTU_CLK_OUT_P[1]]
set_property IOSTANDARD LVDS_25 [get_ports GTU_CLK_OUT_N[1]]

# 1PPS_OUT1 [OUTPUT] B35_L20
set_property PACKAGE_PIN G19 [get_ports PPS_OUT_P[1]]
set_property PACKAGE_PIN F19 [get_ports PPS_OUT_N[1]]
set_property IOSTANDARD LVDS_25 [get_ports PPS_OUT_P[1]]
set_property IOSTANDARD LVDS_25 [get_ports PPS_OUT_N[1]]

# TRIG_L1_IN1 [INPUT] B35_L11 (SRCC)
set_property PACKAGE_PIN C17 [get_ports TRIG_L1_IN_P[1]]
set_property PACKAGE_PIN C18 [get_ports TRIG_L1_IN_N[1]]
set_property IOSTANDARD LVDS_25 [get_ports TRIG_L1_IN_P[1]]
set_property IOSTANDARD LVDS_25 [get_ports TRIG_L1_IN_N[1]]

# BUSY_IN1 [INPUT] B35_L5
set_property PACKAGE_PIN F18 [get_ports BUSY_IN_P[1]]
set_property PACKAGE_PIN E18 [get_ports BUSY_IN_N[1]]
set_property IOSTANDARD LVDS_25 [get_ports BUSY_IN_P[1]]
set_property IOSTANDARD LVDS_25 [get_ports BUSY_IN_N[1]]

# EXT_TRIG_OUT[1] [OUTPUT] B35_L3 (DQS)
set_property PACKAGE_PIN E15 [get_ports EXT_TRIG_OUT_P[1]]
set_property PACKAGE_PIN D15 [get_ports EXT_TRIG_OUT_N[1]]
set_property IOSTANDARD LVDS_25 [get_ports EXT_TRIG_OUT_P[1]]
set_property IOSTANDARD LVDS_25 [get_ports EXT_TRIG_OUT_N[1]]

# CLK40_OUT[1] [OUTPUT] B35_L7
set_property PACKAGE_PIN C15 [get_ports CLK40_OUT1_P[0]]
set_property PACKAGE_PIN B15 [get_ports CLK40_OUT1_N[0]]
set_property IOSTANDARD LVDS_25 [get_ports CLK40_OUT1_P[0]]
set_property IOSTANDARD LVDS_25 [get_ports CLK40_OUT1_N[0]]

##############################################################################
# JLVDS2&3A - Connettore 2 (Bank 35 + Bank 34)
##############################################################################

# GTU_CLK_OUT[2] [OUTPUT] B35_L9 (DQS)
set_property PACKAGE_PIN A16 [get_ports GTU_CLK_OUT_P[2]]
set_property PACKAGE_PIN A17 [get_ports GTU_CLK_OUT_N[2]]
set_property IOSTANDARD LVDS_25 [get_ports GTU_CLK_OUT_P[2]]
set_property IOSTANDARD LVDS_25 [get_ports GTU_CLK_OUT_N[2]]

# 1PPS_OUT[2] [OUTPUT] B34_L4
set_property PACKAGE_PIN L17 [get_ports PPS_OUT_P[2]]
set_property PACKAGE_PIN M17 [get_ports PPS_OUT_N[2]]
set_property IOSTANDARD LVDS_25 [get_ports PPS_OUT_P[2]]
set_property IOSTANDARD LVDS_25 [get_ports PPS_OUT_N[2]]

# TRIG_L1_IN2 [INPUT] B34_L2
set_property PACKAGE_PIN J16 [get_ports TRIG_L1_IN_P[2]]
set_property PACKAGE_PIN J17 [get_ports TRIG_L1_IN_N[2]]
set_property IOSTANDARD LVDS_25 [get_ports TRIG_L1_IN_P[2]]
set_property IOSTANDARD LVDS_25 [get_ports TRIG_L1_IN_N[2]]

# BUSY_IN2 [INPUT] B34_L5
set_property PACKAGE_PIN N17 [get_ports BUSY_IN_P[2]]
set_property PACKAGE_PIN N18 [get_ports BUSY_IN_N[2]]
set_property IOSTANDARD LVDS_25 [get_ports BUSY_IN_P[2]]
set_property IOSTANDARD LVDS_25 [get_ports BUSY_IN_N[2]]

# EXT_TRIG_OUT[2] [OUTPUT] B35_L2
set_property PACKAGE_PIN D16 [get_ports EXT_TRIG_OUT_P[2]]
set_property PACKAGE_PIN D17 [get_ports EXT_TRIG_OUT_N[2]]
set_property IOSTANDARD LVDS_25 [get_ports EXT_TRIG_OUT_P[2]]
set_property IOSTANDARD LVDS_25 [get_ports EXT_TRIG_OUT_N[2]]

# CLK40_OUT[2] [OUTPUT] B34_L7
set_property PACKAGE_PIN J18 [get_ports CLK40_OUT2_P[0]]
set_property PACKAGE_PIN K18 [get_ports CLK40_OUT2_N[0]]
set_property IOSTANDARD LVDS_25 [get_ports CLK40_OUT2_P[0]]
set_property IOSTANDARD LVDS_25 [get_ports CLK40_OUT2_N[0]]

##############################################################################
# JLVDS2&3B - Connettore 3 (Bank 33 + Bank 34 + Bank 13)
##############################################################################

# GTU_CLK_OUT[3] [OUTPUT] B33_L17
set_property PACKAGE_PIN AA17 [get_ports GTU_CLK_OUT_P[3]]
set_property PACKAGE_PIN AB17 [get_ports GTU_CLK_OUT_N[3]]
set_property IOSTANDARD LVDS_25 [get_ports GTU_CLK_OUT_P[3]]
set_property IOSTANDARD LVDS_25 [get_ports GTU_CLK_OUT_N[3]]

# 1PPS_OUT[3] [OUTPUT] B33_L18
set_property PACKAGE_PIN AA16 [get_ports PPS_OUT_P[3]]
set_property PACKAGE_PIN AB16 [get_ports PPS_OUT_N[3]]
set_property IOSTANDARD LVDS_25 [get_ports PPS_OUT_P[3]]
set_property IOSTANDARD LVDS_25 [get_ports PPS_OUT_N[3]]

# TRIG_L1_IN3 [INPUT] B33_L11 (SRCC)
set_property PACKAGE_PIN Y19  [get_ports TRIG_L1_IN_P[3]]
set_property PACKAGE_PIN AA19 [get_ports TRIG_L1_IN_N[3]]
set_property IOSTANDARD LVDS_25 [get_ports TRIG_L1_IN_P[3]]
set_property IOSTANDARD LVDS_25 [get_ports TRIG_L1_IN_N[3]]

# BUSY_IN3 [INPUT] B34_L12 (MRCC)
set_property PACKAGE_PIN L18 [get_ports BUSY_IN_P[3]]
set_property PACKAGE_PIN L19 [get_ports BUSY_IN_N[3]]
set_property IOSTANDARD LVDS_25 [get_ports BUSY_IN_P[3]]
set_property IOSTANDARD LVDS_25 [get_ports BUSY_IN_N[3]]

# EXT_TRIG_OUT[3] [OUTPUT] B13_L8
set_property PACKAGE_PIN AA11 [get_ports EXT_TRIG_OUT_P[3]]
set_property PACKAGE_PIN AB11 [get_ports EXT_TRIG_OUT_N[3]]
set_property IOSTANDARD LVDS_25 [get_ports EXT_TRIG_OUT_P[3]]
set_property IOSTANDARD LVDS_25 [get_ports EXT_TRIG_OUT_N[3]]

# CLK40_OUT[3] [OUTPUT] B13_L7
set_property PACKAGE_PIN AA12 [get_ports CLK40_OUT3_P[0]]
set_property PACKAGE_PIN AB12 [get_ports CLK40_OUT3_N[0]]
set_property IOSTANDARD LVDS_25 [get_ports CLK40_OUT3_P[0]]
set_property IOSTANDARD LVDS_25 [get_ports CLK40_OUT3_N[0]]

###############################################################################
## JLVDS4&5A - Connettore 4 (Bank 13)
###############################################################################

## GTU_CLK_OUT[4] [OUTPUT] B13_L15 (DQS)
#set_property PACKAGE_PIN AB2 [get_ports GTU_CLK_OUT_P[4]]
#set_property PACKAGE_PIN AB1 [get_ports GTU_CLK_OUT_N[4]]
#set_property IOSTANDARD LVDS_25 [get_ports GTU_CLK_OUT_P[4]]
#set_property IOSTANDARD LVDS_25 [get_ports GTU_CLK_OUT_N[4]]

## 1PPS_OUT[4] [OUTPUT] B13_L22
#set_property PACKAGE_PIN U6 [get_ports PPS_OUT_P[4]]
#set_property PACKAGE_PIN U5 [get_ports PPS_OUT_N[4]]
#set_property IOSTANDARD LVDS_25 [get_ports PPS_OUT_P[4]]
#set_property IOSTANDARD LVDS_25 [get_ports PPS_OUT_N[4]]

## TRIG_L1_IN4 [INPUT] B13_L21 (DQS)
#set_property PACKAGE_PIN V5 [get_ports TRIG_L1_IN_P[4]]
#set_property PACKAGE_PIN V4 [get_ports TRIG_L1_IN_N[4]]
#set_property IOSTANDARD LVDS_25 [get_ports TRIG_L1_IN_P[4]]
#set_property IOSTANDARD LVDS_25 [get_ports TRIG_L1_IN_N[4]]

## BUSY_IN4 [INPUT] B13_L23
#set_property PACKAGE_PIN V7 [get_ports BUSY_IN_P[4]]
#set_property PACKAGE_PIN W7 [get_ports BUSY_IN_N[4]]
#set_property IOSTANDARD LVDS_25 [get_ports BUSY_IN_P[4]]
#set_property IOSTANDARD LVDS_25 [get_ports BUSY_IN_N[4]]

## EXT_TRIG_OUT[4] [OUTPUT] B13_L16
#set_property PACKAGE_PIN AB5 [get_ports EXT_TRIG_OUT_P[4]]
#set_property PACKAGE_PIN AB4 [get_ports EXT_TRIG_OUT_N[4]]
#set_property IOSTANDARD LVDS_25 [get_ports EXT_TRIG_OUT_P[4]]
#set_property IOSTANDARD LVDS_25 [get_ports EXT_TRIG_OUT_N[4]]

## CLK40_OUT[4] [OUTPUT] B13_L17
#set_property PACKAGE_PIN AB7 [get_ports CLK40_OUT_P[4]]
#set_property PACKAGE_PIN AB6 [get_ports CLK40_OUT_N[4]]
#set_property IOSTANDARD LVDS_25 [get_ports CLK40_OUT_P[4]]
#set_property IOSTANDARD LVDS_25 [get_ports CLK40_OUT_N[4]]

###############################################################################
## JLVDS4&5B - Connettore 5 (Bank 13)
###############################################################################

## GTU_CLK_OUT[5] [OUTPUT] B13_L24
#set_property PACKAGE_PIN W6 [get_ports GTU_CLK_OUT_P[5]]
#set_property PACKAGE_PIN W5 [get_ports GTU_CLK_OUT_N[5]]
#set_property IOSTANDARD LVDS_25 [get_ports GTU_CLK_OUT_P[5]]
#set_property IOSTANDARD LVDS_25 [get_ports GTU_CLK_OUT_N[5]]

## 1PPS_OUT[5] [OUTPUT] B13_L4
#set_property PACKAGE_PIN V12 [get_ports PPS_OUT_P[5]]
#set_property PACKAGE_PIN W12 [get_ports PPS_OUT_N[5]]
#set_property IOSTANDARD LVDS_25 [get_ports PPS_OUT_P[5]]
#set_property IOSTANDARD LVDS_25 [get_ports PPS_OUT_N[5]]

## TRIG_L1_IN5 [INPUT] B13_L19
#set_property PACKAGE_PIN R6 [get_ports TRIG_L1_IN_P[5]]
#set_property PACKAGE_PIN T6 [get_ports TRIG_L1_IN_N[5]]
#set_property IOSTANDARD LVDS_25 [get_ports TRIG_L1_IN_P[5]]
#set_property IOSTANDARD LVDS_25 [get_ports TRIG_L1_IN_N[5]]

## BUSY_IN5 [INPUT] B13_L18
#set_property PACKAGE_PIN Y4  [get_ports BUSY_IN_P[5]]
#set_property PACKAGE_PIN AA4 [get_ports BUSY_IN_N[5]]
#set_property IOSTANDARD LVDS_25 [get_ports BUSY_IN_P[5]]
#set_property IOSTANDARD LVDS_25 [get_ports BUSY_IN_N[5]]

## EXT_TRIG_OUT[5] [OUTPUT] B13_L13 (MRCC)
#set_property PACKAGE_PIN Y6 [get_ports EXT_TRIG_OUT_P[5]]
#set_property PACKAGE_PIN Y5 [get_ports EXT_TRIG_OUT_N[5]]
#set_property IOSTANDARD LVDS_25 [get_ports EXT_TRIG_OUT_P[5]]
#set_property IOSTANDARD LVDS_25 [get_ports EXT_TRIG_OUT_N[5]]

## CLK40_OUT[5] [OUTPUT] B13_L3 (DQS)
#set_property PACKAGE_PIN W11 [get_ports CLK40_OUT_P[5]]
#set_property PACKAGE_PIN W10 [get_ports CLK40_OUT_N[5]]
#set_property IOSTANDARD LVDS_25 [get_ports CLK40_OUT_P[5]]
#set_property IOSTANDARD LVDS_25 [get_ports CLK40_OUT_N[5]]

###############################################################################
## JLVDS6&7A - Connettore 6 (Bank 34 + Bank 33 + Bank 13)
###############################################################################

## GTU_CLK_OUT[6] [OUTPUT] B34_L9 (DQS)
#set_property PACKAGE_PIN J20 [get_ports GTU_CLK_OUT_P[6]]
#set_property PACKAGE_PIN K21 [get_ports GTU_CLK_OUT_N[6]]
#set_property IOSTANDARD LVDS_25 [get_ports GTU_CLK_OUT_P[6]]
#set_property IOSTANDARD LVDS_25 [get_ports GTU_CLK_OUT_N[6]]

## 1PPS_OUT[6] [OUTPUT] B34_L22
#set_property PACKAGE_PIN R19 [get_ports PPS_OUT_P[6]]
#set_property PACKAGE_PIN T19 [get_ports PPS_OUT_N[6]]
#set_property IOSTANDARD LVDS_25 [get_ports PPS_OUT_P[6]]
#set_property IOSTANDARD LVDS_25 [get_ports PPS_OUT_N[6]]

## TRIG_L1_IN6 [INPUT] B33_L13 (MRCC)
#set_property PACKAGE_PIN W17 [get_ports TRIG_L1_IN_P[6]]
#set_property PACKAGE_PIN W18 [get_ports TRIG_L1_IN_N[6]]
#set_property IOSTANDARD LVDS_25 [get_ports TRIG_L1_IN_P[6]]
#set_property IOSTANDARD LVDS_25 [get_ports TRIG_L1_IN_N[6]]

## BUSY_IN6 [INPUT] B34_L14 (SRCC)
#set_property PACKAGE_PIN N19 [get_ports BUSY_IN_P[6]]
#set_property PACKAGE_PIN N20 [get_ports BUSY_IN_N[6]]
#set_property IOSTANDARD LVDS_25 [get_ports BUSY_IN_P[6]]
#set_property IOSTANDARD LVDS_25 [get_ports BUSY_IN_N[6]]

## EXT_TRIG_OUT[6] [OUTPUT] B34_L8
#set_property PACKAGE_PIN J21 [get_ports EXT_TRIG_OUT_P[6]]
#set_property PACKAGE_PIN J22 [get_ports EXT_TRIG_OUT_N[6]]
#set_property IOSTANDARD LVDS_25 [get_ports EXT_TRIG_OUT_P[6]]
#set_property IOSTANDARD LVDS_25 [get_ports EXT_TRIG_OUT_N[6]]

## CLK40_OUT[6] [OUTPUT] B13_L5
#set_property PACKAGE_PIN U12 [get_ports CLK40_OUT_P[6]]
#set_property PACKAGE_PIN U11 [get_ports CLK40_OUT_N[6]]
#set_property IOSTANDARD LVDS_25 [get_ports CLK40_OUT_P[6]]
#set_property IOSTANDARD LVDS_25 [get_ports CLK40_OUT_N[6]]

##############################################################################
# JLVDS6&7B - Connettore 7 (Bank 33 + Bank 34) - DIREZIONE INVERTITA
# Questo connettore e' lo slave: riceve clock/trigger e trasmette busy/trig
##############################################################################

# GTU_CLK_IN7 [INPUT] B33_L8
set_property PACKAGE_PIN AA21 [get_ports GTU_CLK_IN_P]
set_property PACKAGE_PIN AB21 [get_ports GTU_CLK_IN_N]
set_property IOSTANDARD LVDS_25 [get_ports GTU_CLK_IN_P]
set_property IOSTANDARD LVDS_25 [get_ports GTU_CLK_IN_N]

# 1PPS_IN7 [INPUT] B34_L17 ok
set_property PACKAGE_PIN R20 [get_ports PPS_IN_P]
set_property PACKAGE_PIN R21 [get_ports PPS_IN_N]
set_property IOSTANDARD LVDS_25 [get_ports PPS_IN_P]
set_property IOSTANDARD LVDS_25 [get_ports PPS_IN_N]

# TRIG_L1_OUT[7] [OUTPUT] B33_L4 ok
set_property PACKAGE_PIN W20 [get_ports TRIG_L1_OUT_P[0]]
set_property PACKAGE_PIN W21 [get_ports TRIG_L1_OUT_N[0]]
set_property IOSTANDARD LVDS_25 [get_ports TRIG_L1_OUT_P[0]]
set_property IOSTANDARD LVDS_25 [get_ports TRIG_L1_OUT_N[0]]

# BUSY_OUT[7] [OUTPUT] B33_L14 (SRCC) ok
set_property PACKAGE_PIN W16 [get_ports BUSY_OUT_P[0]]
set_property PACKAGE_PIN Y16 [get_ports BUSY_OUT_N[0]]
set_property IOSTANDARD LVDS_25 [get_ports BUSY_OUT_P[0]]
set_property IOSTANDARD LVDS_25 [get_ports BUSY_OUT_N[0]]

# EXT_TRIG_IN7 [INPUT] B34_L15 (DQS) ok
set_property PACKAGE_PIN M21 [get_ports EXT_TRIG_IN_P[0]]
set_property PACKAGE_PIN M22 [get_ports EXT_TRIG_IN_N[0]]
set_property IOSTANDARD LVDS_25 [get_ports EXT_TRIG_IN_P[0]]
set_property IOSTANDARD LVDS_25 [get_ports EXT_TRIG_IN_N[0]]

# CLK40_IN7 [INPUT] B33_L7
#set_property PACKAGE_PIN AA22 [get_ports CLK40_IN_P]
#set_property PACKAGE_PIN AB22 [get_ports CLK40_IN_N]
#set_property IOSTANDARD LVDS_25 [get_ports CLK40_IN_P]
#set_property IOSTANDARD LVDS_25 [get_ports CLK40_IN_N]

set_property BITSTREAM.CONFIG.UNUSEDPIN PULLUP [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]