# 64-bit-signed-MAC
Pipelined 64 bit signed Integer Multiply and Accumulate(IMAC)
# Project structure
![Screenshot (11)](https://github.com/kakarlahimabindu/64-bit-signed-MAC/assets/153276932/9440e864-b444-4152-99dc-224b536d8b1c)

The above image shows the flow of our project.It contains totally three main stages.1)partial product formation 2)wallace tree structure to add partial products 3)ripple carry adder for accumulator.
## Stage 1-partial products formation using Reduced Booth Algorithm
we used radix-4 modified Booth's algorithm to calculate partial products.
The key optimization in this Algorithm is to identify and combine certain bit patterns(3 bit patterns in multiplier) to minimize the number of arithmetic operations.The below image shows the encoding rules of radix-4 algorithm.

![Screenshot (64)](https://github.com/kakarlahimabindu/64-bit-signed-MAC/assets/153276932/c5d4c4bf-e93a-4721-8a92-d818a3205cbc)

For‘n’ bit number we get ‘n/2’ partial products using this algorithm. Since, the number of partial products are reduced, speed of multiplication process increases. 
Final product of multiplication is obtained by adding partial products.

**pipelining for stage 1 results:**
Partial products obtained from the reduced booth's algorithm have been sent to next level with a pipeline stage in between.

If area is the constraint, this pipeline stage can be removed with a trade off in frequency.If frequency is the constraint, then this pipeline stage can be retained.

we developed both the versions of the code.
## Stage 2-wallace tree structure to add partial products
partial products(pp's) are added using carry save adders formed like a wallace tree.This wallace tree has splitted into two stages with a pipeline in between.

First stage contains 18 pp's addition.The results of this stage are given to next stage of 14 pp's addition using pipeline(pipeline stage 2 in above diagram).

Ripple carry adder is used to add the last pp with previous stage carry's and sums(to get the final multipiled output).

**pipelining for stage 2 results:**
The multiplied output from ripple carry adder has been pipelined(pipeline stage 3 in above diagram).
## Stage 3-Ripple carry adder for accumulator
The pipelined result from stage 2 is given to ripple carry adder to accumulate with previous results.


                                                                              

