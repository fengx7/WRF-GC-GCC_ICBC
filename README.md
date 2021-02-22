# WRF-GC-GCC_ICBC
Generate the chemical initial and boundary conditons for WRF-GC model using the global GEOS-Chem output.

Step 1

Run the GEOS-Chem standard full-chemistry/tropchem simulation at a resolution of 2×2.5/4×5 degree (recommend 2×2.5 degree). The running time must cover the WRF-GC simulation period: e.g. if the simulation period of WRF-GC is from 2015-06-10 00:00:00 to 2015-06-20-00:00:00 (UTC), the time ranges for GEOS-Chem can be from 2015-06-07 00:00:00 to 2015-06-21 00:00:00 (UTC). Output the netCDF diagnostic files every 6 hours (00, 06, 12, 18), including

    (a) GEOSChem.SpeciesConc.xxxxxxxxxxxxxx.nc4 (contains instantaneous "SpeciesConc_?ADV?")

    (b) GEOSChem.StateMet.xxxxxxxxxxxxxx.nc4 (contains "Met_PS1DRY").

Step 2

Use the MATLAB script "convert_gcoutput_mozart_structure_selected_domain.m" to merge the GEOS-Chem output files and reconstruct the data structure so that mozbc could read it.

Run the MATLAB script in the GEOS-Chem output file directory. Modified the script before running as follow.

    (a) filename_input: set the input filename as anyone of the GEOS-Chem species concentration output files, e.g.     
        GEOSChem.SpeciesConc.20150601_0000z.nc4.

    (b) filename_output: set the output filename freely.

    (c) simulation_4_5/simulation_2/25: 
        If the resolution of global GEOS-Chem simulation is 2×2.5 degree, please set it as follow.
            simulation_4_5               = false;
            simulation_2_25              = true;
        If the resolution of global GEOS-Chem simulation is 4×5 degree, please set it as follow.
            simulation_4_5               = true;
            simulation_2_25              = false;
    (d) Set the time ranges for output file
            startyr                      = 2015;        
            endyr                        = 2015;
            startmon                     = 6;
            endmon                       = 6;
            startdate                    = 7; 
            enddate                      = 21;
     (e) Set the domain for output file (need to be larger than your WRF-GC domain)
         If the resolution of global GEOS-Chem simulation is 2x2.5
         longitude: 0 (index 1):2.5:357.5 (index 144)
         latitude : -90 (index 1):2:90 (index 91)
         Here is an example. 
            lon_left                     = 1;  % longitude of western lateral condition
            lon_right                    = 73; % longitude of eastern lateral condition
            lat_bottom                   = 46; % latitude of southern lateral condition
            lat_upper                    = 91; % latitude of northern lateral condition
            
The netCDF file will be generated after running the script.

Step 3

Run mozbc using the generated file. We provide mozbc input files "GEOSCHEM_v12_2_1.inp" and "GEOSCHEM_v12_8_1.inp", which contain the default advected species ('SpeciesConc_?ADV?) of GEOS-Chem v12.2.1 or GEOS-Chem v12.8.1. If you want to change the species, please modify the "spc_map" in the input file, e.g.
 
        'isoprene -> ISOP'

where "isoprene" is the name of WRF-GC chemical species and "ISOP" is the name of GEOS-Chem species.

If the chemical IC/BC have been successfully written into the wrfinput and wrfbdy file, "bc_wrfchem completed successfully" will appear.







