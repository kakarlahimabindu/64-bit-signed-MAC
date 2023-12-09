# Pipelined 64 bit signed Integer Multiply and Accumulate(IMAC)

# Project structure
![Screenshot (11)](https://github.com/kakarlahimabindu/64-bit-signed-MAC/assets/153276932/9440e864-b444-4152-99dc-224b536d8b1c)

The above image shows the flow of our project.It contains totally three main stages.1)partial product formation 2)wallace tree structure to add partial products 3)ripple carry adder for accumulator.
## Stage 1-partial products formation using Reduced Booth Algorithm
we used radix-4 modified Booth's algorithm to calculate partial products.
The key optimization in this Algorithm is to identify and combine certain bit patterns(3 bit patterns in multiplier) to minimize the number of arithmetic operations.The below image shows the encoding rules of radix-4 algorithm.

![Screenshot (64)](https://github.com/kakarlahimabindu/64-bit-signed-MAC/assets/153276932/c5d4c4bf-e93a-4721-8a92-d818a3205cbc)

For‘n’ bit number we get ‘n/2’ partial products using this algorithm. Since, the number of partial products are reduced, speed of multiplication process increases. 
Final product of multiplication is obtained by adding partial products.

* **pipelining for stage 1 results:**
Partial products obtained from the reduced booth's algorithm have been sent to next level with a pipeline stage in between.

If area is the constraint, this pipeline stage can be removed with a trade off in frequency.If frequency is the constraint, then this pipeline stage can be retained.

we developed both the versions of the code.
## Stage 2-wallace tree structure to add partial products
partial products(pp's) are added using carry save adders formed like a wallace tree.This wallace tree has splitted into two stages with a pipeline in between.

First stage contains 18 pp's addition.The results of this stage are given to next stage of 14 pp's addition using pipeline(pipeline stage 2 in above diagram).

Ripple carry adder is used to add the last pp with previous stage carry's and sums(to get the final multipiled output).

* **pipelining for stage 2 results:**
The multiplied output from ripple carry adder has been pipelined(pipeline stage 3 in above diagram).
## Stage 3-Ripple carry adder for accumulator
The pipelined result from stage 2 is given to ripple carry adder to accumulate with previous results.
# Design Decisions
- Decision of choosing modified booth's algorithm is based on its advantage over other algorithms(ie basic booth's algorithm) in terms of number of partial products.

+ Radix-4 booth algorithm takes less area than other radix-n booth algorithms for higher bit inputs.

* For addition of partial products, wallace tree structure(using carry save adders) gives best results in terms of frequency and area when compared to others.

* Since each partial product has only 64 data bits and remaining are sign-extension bits. While doing addition, first sign extension bit of partial products are added and that value is assigned to remaining sign bits of the corresponding result.This decision helps in reducing the area by eliminating full adders for sign extension bit addition in all pp's.

* In radix-4 modified booth's algorithm each partial product is shifted to left by 2bits.This property helps in making use of half-adders in place of some full-adders which again reduces the area.

* The last pp addition is done using ripple carry adder, because it takes less area when compared to others.

  ## How to run the code:
  * **Simulation:**
  * clone this repository.
  * cd Pipelined-64-bit-signed-IMAC/Sources/IMAC_with_3stage_pipeline
  * Run the following commands:
  * bsc -u -verilog -g $ (TopModule) $ (TopFile)
    
        for 3 stage pipeline IMAC:bsc -u -verilog -g mkBooth_wallace_3tb booth_wallace_3tb.bsv
    
        for 4 stage pipeline IMAC:bsc -u -verilog -g mkBooth_wallace_4tb booth_wallace_4tb.bsv
  * bsc -e $ (TopModule) -verilog -vsim iverilog $ (TopModule).v
    
        for 3 stage pipeline IMAC:bsc -e mkBooth_wallace_3tb -verilog -vsim iverilog mkBooth_wallace_3tb.v
    
        for 4 stage pipeline IMAC:bsc -e mkBooth_wallace_4tb -verilog -vsim iverilog mkBooth_wallace_4tb.v
  * Run the following command to get the output values and dump the results in dump.vcd:
  * ./a.out +bscvcd
  * To visualize the waveforms and latency,use the following command:
  * gtkwave dump.vcd &
    
  * **Synthesis**
  1. For Synthesis, We dont have to use Test bench file.
  2. clone this repository.
  3. cd Pipelined-64-bit-signed-IMAC/Sources/IMAC_with_3stage_pipeline
  4. Run the following commands:
  5. bsc -u -verilog -g $ (TopModule) $ (TopFile)
    
        'for 3 stage pipeline IMAC:bsc -u -verilog -g mkBooth_wallace_3 booth_wallace_3.bsv'
    
        for 4 stage pipeline IMAC:bsc -u -verilog -g mkBooth_wallace_4 booth_wallace_4.bsv
  6. cd ~/Openlane
  7. make mount
  8. To add design into openlane for 3 stage pipeline IMAC:

     ./flow.tcl -design mkBooth_wallace_3 -init_design_config -add_to_designs -src "$ (verilog file path generated in step V)"
     
     To add design into openlane for 4 stage pipeline IMAC:

     ./flow.tcl -design mkBooth_wallace_4 -init_design_config -add_to_designs -src "$ (verilog file path generated in step V)"
  9. To run flow in a interactive mode :

       for 3 stage pipeline IMAC: ./flow.tcl -design mkBooth_wallace_3 -interactive
     
       for 4 stage pipeline IMAC: ./flow.tcl -design mkBooth_wallace_4 -interactive
  10. To run synthesis,type folowing commands:
       run_synthesis
  11. Exit from the flow as we need only synthesis:
       exit
  12. Area reports will shown at following path:
       less desings/mkBooth_wallace_3/runs/$ (run_time_stamp)/reports/synthesis/$ (synthesis.area.stat.rpt)
     
       
     


                                                                              

