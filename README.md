# WRF-GC-GCC_ICBC
Generate the chemical initial and boundary conditons for WRF-GC model using the global GEOS-Chem output.

Step 1

Run the GEOS-Chem standard full-chemistry/tropchem simulation at a resolution of 2×2.5/4×5 degree (recommend 2×2.5 degree). The running time must cover the WRF-GC simulation period: e.g. if the simulation period of WRF-GC is from 2015-06-10 00:00:00 to 2015-06-20-00:00:00 (UTC), the time ranges for GEOS-Chem can be from 2015-06-07 00:00:00 to 2015-06-21 00:00:00 (UTC). Output the netCDF diagnostic files every 6 hours (00, 06, 12, 18), including

(a) GEOSChem.SpeciesConc.xxxxxxxxxxxxxx.nc4 (contains instantaneous "SpeciesConc_?ADV?")

(b) GEOSChem.StateMet.xxxxxxxxxxxxxx.nc4 (contains "Met_PS1DRY").

Step 2

Use the MATLAB script "convert_gcoutput_mozart_structure_new.m" to merge the GEOS-Chem output files and reconstruct the data structure so that mozbc could read it.

Run the MATLAB script in the GEOS-Chem output file directory. Modified the script before running as follow.

    (a) filename_input: set the input filename as anyone of the GEOS-Chem species concentration output files, e.g.     
        GEOSChem.SpeciesConc.20150601_0000z.nc4.

    (b) filename_output: set the output filename freely.

    (c) simulation_4_5/simulation_2/25: 
        if the resolution of global GEOS-Chem simulation is 2×2.5 degree, please set it as follow.
            simulation_4_5               = false;
            simulation_2_25              = true;
        if the resolution of global GEOS-Chem simulation is 4×5 degree, please set it as follow.
            simulation_4_5               = true;
            simulation_2_25              = false;
    (d) set the time ranges for output file
            startyr                      = 2015;        
            endyr                        = 2015;
            startmon                     = 6;
            endmon                       = 6;
            startdate                    = 7; 
            enddate                      = 21;
            
The netCDF file will be generated after running the script.

Step 3

Run mozbc using the generated file. We provide a mozbc input file "GEOSCHEMtest.inp", which contains the default advected species ('SpeciesConc_?ADV?) of GEOS-Chem v12.2.1. If you want to change the species, please modify the "spc_map" in the input file (GEOSCHEMtest.inp), e.g.
 
        'isoprene -> ISOP'

where "isoprene" is the name of WRF-GC chemical species and "ISOP" is the name of GEOS-Chem species.

If the chemical IC/BC have been successfully written into the wrfinput and wrfbdy file, "bc_wrfchem completed successfully" will appear.







