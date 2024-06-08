;;       File:           cb13l6_10_tsmc_ant.cmd
;;       Author:         Xuan Leng
;;       @(#) Apollo command file for antenna rule setting for TSMC 0.13U 6LM Ver 1.0
;;       @(#) Revision 1.0.1.0
;;       @(#) Date     14-Nov-01
;; #############################################################################
;; Copyright Avant! Corp. 2000 2001
;; technology: cb13l6_10_tsmc
;; Revision history:
;; rev            date     who  what
;; ------------  --------- ---- ------------------------------------------------
;; Rev. 1.0.1.0  14-Nov-01 XL   Initial version based on TSMC 0.13 DRM Ver 1.0 TA-10B2-4001(T-013-LO-D;;                              R-001)
;; #############################################################################
;; 
;; dbDefineAntennaRule libId mode diodeMode defaultMetalRatio defaultCutRatio [protectedMetalScale protectedCutScale]
;;      libId : the id of an opened library, e.g. (dbGetCurrentLibId)
;; 	mode
;; 	  1 : top area based, ignore all lower-layer segments
;; 	  2 : top area based, include lower-layer segments to the input pins
;; 	  3 : top area based, include all lower-layer segments
;; 	  4 : sidewall area based, ignore all lower-layer segments
;; 	  5 : sidewall area based, include lower-layer segments to the input 
;;            pins
;; 	  6 : sidewall area based, include all lower-layer segments
;; 	diodeMode (outputPin)
;; 	  0 : output pin cannot protect antenna
;; 	  1 : output pin can provide unlimited protection
;; 	  2 : output pin protection is limited and defined 
;;            by dbAddAntennaLayerRule & dbDefineDiodeProtection (CLF)
;;	      If more than 1 diode are connected, the largest value of 
;;            max-antenna-ratio of all diodes will be used.
;;        3 : output pin protection is limited and defined
;;            by dbAddAntennaLayerRule & dbDefineDiodeProtection (CLF)
;;	      If more than 1 diode are connected, the sum of 
;;            max-antenna-ratio of all diodes will be used.
;;        4 : output pin protection is limited and defined
;;            by dbAddAntennaLayerRule & dbDefineDiodeProtection (CLF)
;;	      If more than 1 diode are connected, the sum of all  
;;            diode-protection value of all dioeds will be used 
;;            to compute max-antenna-ratio.
;;	defaultMetalRatio : 
;;            maximum antenna ratio for metal layers if the metal layer 
;;            is not defined with 'dbAddAntennaLayerRule'.
;;	defaultCutRatio : 
;;            maximum antenna ratio for cut layers if the cut layer
;;	      is not defined with 'dbAddAntennaLayerRule'.
;;	protectedMetalScale (optioal, default = 1.0): 
;;            used when mode is 2 or 5 only. The area of the metal layer 
;;            that is protected by diode will be scaled by this value.
;;	protectedCutScale (optional, default = 1.0): 
;;            used when mode is 2 or 5 only. The area of the cut layer 
;;            that is protected by diode will be scaled by this value.
;; 
;; dbAddAntennaLayerRule libId mode "layer" layerMaxRatio '(v0 v1 v2 v3)
;;      layerMaxRatio
;;          max. antenna ratio with no diode protection
;;
;;      (dp > v0) ? ((dp + v1 ) * v2 + v3) : layerMaxRatio 
;;          max. antenna ratio with (diode protection == dp)
;; 
;; 

define _libId (dbGetCurrentLibId)
dbClearLibAntennaRules _libId

dbDefineAntennaRule _libId 1 2 125 20

dbAddAntennaLayerRule _libId 1 "METAL" 125 '( 0.203 0 400 3700) 
dbAddAntennaLayerRule _libId 1 "METAL2" 125 '( 0.203 0 400 3700) 
dbAddAntennaLayerRule _libId 1 "METAL3" 125 '( 0.203 0 400 3700) 
dbAddAntennaLayerRule _libId 1 "METAL4" 125 '( 0.203 0 400 3700) 
dbAddAntennaLayerRule _libId 1 "METAL5" 125 '( 0.203 0 400 3700) 
dbAddAntennaLayerRule _libId 1 "METAL6" 125 '( 0.203 0 8000 50000) 

dbAddAntennaLayerRule _libId 1 "VIA"  20 '( 0.203 0 83.33 75)
dbAddAntennaLayerRule _libId 1 "VIA2" 20 '( 0.203 0 83.33 75)
dbAddAntennaLayerRule _libId 1 "VIA3" 20 '( 0.203 0 83.33 75)
dbAddAntennaLayerRule _libId 1 "VIA4" 20 '( 0.203 0 83.33 75)
dbAddAntennaLayerRule _libId 1 "VIA5" 20 '( 0.203 0 83.33 75)

