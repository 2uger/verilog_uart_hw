set PROJECT_NAME uart_test
set PROJECT_CONSTRAINT_FILE ./constraints.xdc

set DIR_OUTPUT ../build
file mkdir ${DIR_OUTPUT}

create_project -force ${PROJECT_NAME} ${DIR_OUTPUT}/${PROJECT_NAME} -part xc7z020clg484-1

add_files {../rtl/ }
import_files -force
import_files -fileset constrs_1 -force -norecurse ${PROJECT_CONSTRAINT_FILE}

# Mimic GUI behavior of automatically setting top and file compile order
update_compile_order -fileset sources_1

# Launch Synthesis and wait on completion
launch_runs synth_1
wait_on_run synth_1
open_run synth_1 -name netlist_1

# Generate a timing and power reports and write to disk
report_timing_summary -delay_type max -report_unconstrained -check_timing_verbose -max_paths 10 -input_pins -file ${DIR_OUTPUT}/syn_timing.rpt
report_power -file ${DIR_OUTPUT}/syn_power.rpt

# Launch Implementation
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1

# Generate a timing and power reports and write to disk
# comment out the open_run for batch mode
open_run impl_1
report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose -max_paths 10 -input_pins -file ${DIR_OUTPUT}/imp_timing.rpt
report_power -file ${DIR_OUTPUT}/imp_power.rpt

# Output hardware description and bitsream file.
file mkdir ${DIR_OUTPUT}/products
write_hw_platform -fixed -force -file ${DIR_OUTPUT}/products/system_top.xsa
write_bitstream -force ${DIR_OUTPUT}/products/bit.bit

