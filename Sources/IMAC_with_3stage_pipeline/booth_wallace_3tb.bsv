package booth_wallace_3tb;
import booth_wallace_3::*;
module mkBooth_wallace_3tb(Empty);
 Reg#(Bit#(64)) p <- mkReg(0);
 Reg#(Bit#(64)) q <- mkReg(0);
 Reg#(Bit#(5)) i <- mkReg(0);
 Reg#(Bit#(1)) rst<-mkReg(0);
 Ifc obj <- mkBooth_wallace_3;
 Bit#(64) arr[8];
  arr[0]=64'd5;
  arr[1]=64'd4;
  //2^40-1
  arr[2]=64'd1099511627775;
  //2^50-1
  arr[3]=64'd1125899906842623;
  arr[4]=64'd8;
  arr[5]=64'd9;
  arr[6]=-64'd1099511627775;
  arr[7]=64'd1125899906842623;

 rule in(i<8);
   p <=arr[i];
   q <=arr[i+1];
   i<=i+2;
   rst<=1'b0;
   obj.send(p,q,rst);
 endrule
 rule out;
  let o= obj.receive();
  $display("accum output is:%h",o);
 endrule
endmodule
endpackage
