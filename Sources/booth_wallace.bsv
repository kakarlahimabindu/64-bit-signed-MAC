package booth_wallace;
import Vector::*;

interface Ifc;
  method Action send(Bit#(64) a, Bit#(64) b,Bit#(1) rst);
  method Bit#(128) receive();
endinterface

(* synthesize *)
module mkWallace_test(Ifc);
 Reg#(Bit#(18)) result_pl <- mkReg(0);
 Reg#(Bit#(128)) result_mul <- mkReg(0);
 Reg#(Bit#(128)) accum_out <- mkReg(0);
 Wire#(Bit#(64)) x<-mkBypassWire();
 Wire#(Bit#(64)) y<-mkBypassWire();
 Wire#(Bit#(64)) inv_y<-mkBypassWire();
 Wire#(Bit#(128)) result_mul_wire<-mkBypassWire();
 Wire#(Bit#(3)) temp[32];
 Wire#(Bit#(1)) accum_rst<-mkBypassWire();
 Wire#(Bit#(128)) pp[32];
 Reg#(Bit#(65)) pl1_pp[14];
 Vector#(128, Reg#(Bit#(2))) pl1<-replicateM(mkReg(0));
 
 
 
 function Bit#(2) fa (Bit#(1) a1, Bit#(1) b1, Bit#(1) c1_in);
  Bit#(1) s1 = (a1 ^ b1)^ c1_in;
  Bit#(1) c1_out = (a1 & b1) | (c1_in & (a1 ^ b1));
  return {c1_out,s1};
 endfunction

 function Bit#(2) ha (Bit#(1) a, Bit#(1) b);
  Bit#(1) s = a ^ b;
  Bit#(1) c_out = a & b;
  return {c_out,s};
 endfunction


 for(Integer i=0;i<32;i=i+1)begin
   temp[i]<-mkBypassWire();
 end
 for(Integer i=0;i<32;i=i+1)begin
    pp[i]<-mkBypassWire();
 end
 for(Integer i=0;i<14;i=i+1)begin
    pl1_pp[i]<-mkReg(0);
 end


(* descending_urgency="r1,r2,r3,r4" *)
 rule r1;
  temp[0]<={x[1],x[0],1'b0};
  for(Integer i=1;i<31;i=i+1)begin
    temp[i]<={x[(2*i)+1],x[2*i],x[(2*i)-1]};
  end
  temp[31]<={x[63],x[63],x[62]};
  inv_y<=(~y)+64'd1;
 endrule

 rule r2;
  for(Integer i=0;i<32;i=i+1)begin
    case(temp[i])
      0,7:pp[i]<=0;
      1,2:pp[i]<=(signExtend(y))<<(2*i);
      3:pp[i]<=({signExtend(y),1'b0})<<(2*i);
      4:pp[i]<=({signExtend(inv_y),1'b0})<<(2*i);
      5,6:pp[i]<=(signExtend(inv_y))<<(2*i);
    endcase
  end
 endrule

rule r3;
Vector#(128,Bit#(1)) out=replicate(0);
//stage1
Vector#(126, Bit#(2)) cs1=replicate(0);
cs1[0]=ha(pp[0][2],pp[1][2]);
cs1[1]=ha(pp[0][3],pp[1][3]);
for(Integer i=2;i<67;i=i+1)begin
  cs1[i]=fa(pp[0][i+2],pp[1][i+2],pp[2][i+2]);
end
//sign extend for stage1
for(Integer i=67;i<126;i=i+1)begin
 cs1[i][0]=cs1[66 ][0];
 cs1[i][1]=cs1[66][1];
end
out[0]=pp[0][0];
out[1]=pp[0][1];

//stage2
Vector#(128, Bit#(2)) cs2=replicate(0);
for(Integer i=0;i<3;i=i+1)begin
 cs2[i]=ha(cs1[i+1][0],cs1[i][1]);
end
for(Integer i=3;i<68;i=i+1)begin
  cs2[i]=fa(cs1[i+1][0],cs1[i][1],pp[3][i+3]);
end
//sign extend for stage2
for(Integer i=68;i<125;i=i+1)begin
 cs2[i][0]=cs2[67][0];
 cs2[i][1]=cs2[67][1];
end
out[2]=cs1[0][0];

//stage3
Vector#(128,Bit#(2)) cs3=replicate(0);
for(Integer i=0;i<4;i=i+1)begin
 cs3[i]=ha(cs2[i+1][0],cs2[i][1]);
end
for(Integer i=4;i<69;i=i+1)begin
  cs3[i]=fa(cs2[i+1][0],cs2[i][1],pp[4][i+4]);
end
//sign extend for stage3
for(Integer i=69;i<124;i=i+1)begin
 cs3[i][0]=cs3[68][0];
 cs3[i][1]=cs3[68][1];
end
out[3]=cs2[0][0];


//stage4
Vector#(128,Bit#(2)) cs4=replicate(0);
for(Integer i=0;i<5;i=i+1)begin
 cs4[i]=ha(cs3[i+1][0],cs3[i][1]);
end
for(Integer i=5;i<70;i=i+1)begin
  cs4[i]=fa(cs3[i+1][0],cs3[i][1],pp[5][i+5]);
end
//sign extend for stage4
for(Integer i=70;i<123;i=i+1)begin
 cs4[i][0]=cs4[69][0];
 cs4[i][1]=cs4[69][1];
end
out[4]=cs3[0][0];

//stage5
Vector#(128,Bit#(2)) cs5=replicate(0);
for(Integer i=0;i<6;i=i+1)begin
 cs5[i]=ha(cs4[i+1][0],cs4[i][1]);
end
for(Integer i=6;i<71;i=i+1)begin
  cs5[i]=fa(cs4[i+1][0],cs4[i][1],pp[6][i+6]);
end
//sign extend for stage5
for(Integer i=71;i<122;i=i+1)begin
 cs5[i][0]=cs5[70][0];
 cs5[i][1]=cs5[70][1];
end
out[5]=cs4[0][0];

//stage6
Vector#(128,Bit#(2)) cs6=replicate(0);
for(Integer i=0;i<7;i=i+1)begin
 cs6[i]=ha(cs5[i+1][0],cs5[i][1]);
end
for(Integer i=7;i<72;i=i+1)begin
  cs6[i]=fa(cs5[i+1][0],cs5[i][1],pp[7][i+7]);
end
//sign extend for stage6
for(Integer i=72;i<121;i=i+1)begin
 cs6[i][0]=cs6[71][0];
 cs6[i][1]=cs6[71][1];
end
out[6]=cs5[0][0];

//stage7
Vector#(128,Bit#(2)) cs7=replicate(0);
for(Integer i=0;i<8;i=i+1)begin
 cs7[i]=ha(cs6[i+1][0],cs6[i][1]);
end
for(Integer i=8;i<73;i=i+1)begin
  cs7[i]=fa(cs6[i+1][0],cs6[i][1],pp[8][i+8]);
end
//sign extend for stage7
for(Integer i=73;i<120;i=i+1)begin
 cs7[i][0]=cs7[72][0];
 cs7[i][1]=cs7[72][1];
end
out[7]=cs6[0][0];

//stage8
Vector#(128,Bit#(2)) cs8=replicate(0);
for(Integer i=0;i<9;i=i+1)begin
 cs8[i]=ha(cs7[i+1][0],cs7[i][1]);
end
for(Integer i=9;i<74;i=i+1)begin
  cs8[i]=fa(cs7[i+1][0],cs7[i][1],pp[9][i+9]);
end
//sign extend for stage8
for(Integer i=74;i<119;i=i+1)begin
 cs8[i][0]=cs8[73][0];
 cs8[i][1]=cs8[73][1];
end

out[8]=cs7[0][0];

//stage9
Vector#(128,Bit#(2)) cs9=replicate(0);
for(Integer i=0;i<10;i=i+1)begin
 cs9[i]=ha(cs8[i+1][0],cs8[i][1]);
end
for(Integer i=10;i<75;i=i+1)begin
  cs9[i]=fa(cs8[i+1][0],cs8[i][1],pp[10][i+10]);
end
//sign extend for stage9
for(Integer i=75;i<118;i=i+1)begin
 cs9[i][0]=cs9[74][0];
 cs9[i][1]=cs9[74][1];
end
out[9]=cs8[0][0];

//stage10
Vector#(128,Bit#(2)) cs10=replicate(0);
for(Integer i=0;i<11;i=i+1)begin
 cs10[i]=ha(cs9[i+1][0],cs9[i][1]);
end
for(Integer i=11;i<76;i=i+1)begin
  cs10[i]=fa(cs9[i+1][0],cs9[i][1],pp[11][i+11]);
end
//sign extend for stage10
for(Integer i=76;i<117;i=i+1)begin
 cs10[i][0]=cs10[75][0];
 cs10[i][1]=cs10[75][1];
end
out[10]=cs9[0][0];

//stage11
Vector#(128,Bit#(2)) cs11=replicate(0);
for(Integer i=0;i<12;i=i+1)begin
 cs11[i]=ha(cs10[i+1][0],cs10[i][1]);
end
for(Integer i=12;i<77;i=i+1)begin
  cs11[i]=fa(cs10[i+1][0],cs10[i][1],pp[12][i+12]);
end
//sign extend for stage11
for(Integer i=77;i<116;i=i+1)begin
 cs11[i][0]=cs11[76][0];
 cs11[i][1]=cs11[76][1];
end
out[11]=cs10[0][0];

//stage12
Vector#(128,Bit#(2)) cs12=replicate(0);
for(Integer i=0;i<13;i=i+1)begin
 cs12[i]=ha(cs11[i+1][0],cs11[i][1]);
end
for(Integer i=13;i<78;i=i+1)begin
  cs12[i]=fa(cs11[i+1][0],cs11[i][1],pp[13][i+13]);
end
//sign extend for stage12
for(Integer i=78;i<115;i=i+1)begin
 cs12[i][0]=cs12[77][0];
 cs12[i][1]=cs12[77][1];
end
out[12]=cs11[0][0];

//stage13
Vector#(128,Bit#(2)) cs13=replicate(0);
for(Integer i=0;i<14;i=i+1)begin
 cs13[i]=ha(cs12[i+1][0],cs12[i][1]);
end
for(Integer i=14;i<79;i=i+1)begin
  cs13[i]=fa(cs12[i+1][0],cs12[i][1],pp[14][i+14]);
end
//sign extend for stage13
for(Integer i=79;i<114;i=i+1)begin
 cs13[i][0]=cs13[78][0];
 cs13[i][1]=cs13[78][1];
end
out[13]=cs12[0][0];

//stage14
Vector#(128,Bit#(2)) cs14=replicate(0);
for(Integer i=0;i<15;i=i+1)begin
 cs14[i]=ha(cs13[i+1][0],cs13[i][1]);
end
for(Integer i=15;i<80;i=i+1)begin
  cs14[i]=fa(cs13[i+1][0],cs13[i][1],pp[15][i+15]);
end
//sign extend for stage14
for(Integer i=80;i<113;i=i+1)begin
 cs14[i][0]=cs14[79][0];
 cs14[i][1]=cs14[79][1];
end
out[14]=cs13[0][0];

//stage15
Vector#(128,Bit#(2)) cs15=replicate(0);
for(Integer i=0;i<16;i=i+1)begin
 cs15[i]=ha(cs14[i+1][0],cs14[i][1]);
end
for(Integer i=16;i<81;i=i+1)begin
  cs15[i]=fa(cs14[i+1][0],cs14[i][1],pp[16][i+16]);
end
//sign extend for stage15
for(Integer i=81;i<112;i=i+1)begin
 cs15[i][0]=cs15[80][0];
 cs15[i][1]=cs15[80][1];
end
out[15]=cs14[0][0];

//stage16
Vector#(128,Bit#(2)) cs16=replicate(0);
for(Integer i=0;i<17;i=i+1)begin
 cs16[i]=ha(cs15[i+1][0],cs15[i][1]);
end
for(Integer i=17;i<82;i=i+1)begin
  cs16[i]=fa(cs15[i+1][0],cs15[i][1],pp[17][i+17]);
end
//sign extend for stage16
for(Integer i=82;i<111;i=i+1)begin
 cs16[i][0]=cs16[81][0];
 cs16[i][1]=cs16[81][1];
end
out[16]=cs15[0][0];
out[17]=cs16[0][0];
result_pl<={out[17],out[16],out[15],out[14],out[13],out[12],out[11],out[10],out[9],out[8],out[7],out[6],out[5],out[4],out[3],out[2],out[1],out[0]};

//stage pipeline
for(Integer i=0;i<111;i=i+1)begin
 pl1[i]<=cs16[i];
end
for(Integer i=0;i<14;i=i+1)begin
 pl1_pp[i]<=pp[i+18][100+(2*i):36+(2*i)];
end

//stage17
Vector#(128,Bit#(2)) cs17=replicate(0);
for(Integer i=0;i<18;i=i+1)begin
 cs17[i]=ha(pl1[i+1][0],pl1[i][1]);
end
for(Integer i=18;i<83;i=i+1)begin
  cs17[i]=fa(pl1[i+1][0],pl1[i][1],pl1_pp[0][i-18]);
end
//sign extend for stage17
for(Integer i=83;i<110;i=i+1)begin
 cs17[i][0]=cs17[82][0];
 cs17[i][1]=cs17[82][1];
end
out[18]=cs17[0][0];

//stage18
Vector#(128,Bit#(2)) cs18=replicate(0);
for(Integer i=0;i<19;i=i+1)begin
 cs18[i]=ha(cs17[i+1][0],cs17[i][1]);
end
for(Integer i=19;i<84;i=i+1)begin
  cs18[i]=fa(cs17[i+1][0],cs17[i][1],pl1_pp[1][i-19]);
end
//sign extend for stage18
for(Integer i=84;i<109;i=i+1)begin
 cs18[i][0]=cs18[83][0];
 cs18[i][1]=cs18[83][1];
end
out[19]=cs18[0][0];

//stage19
Vector#(128,Bit#(2)) cs19=replicate(0);
for(Integer i=0;i<20;i=i+1)begin
 cs19[i]=ha(cs18[i+1][0],cs18[i][1]);
end
for(Integer i=20;i<85;i=i+1)begin
  cs19[i]=fa(cs18[i+1][0],cs18[i][1],pl1_pp[2][i-20]);
end
//sign extend for stage19
for(Integer i=85;i<108;i=i+1)begin
 cs19[i][0]=cs19[84][0];
 cs19[i][1]=cs19[84][1];
end
out[20]=cs19[0][0];


//stage20
Vector#(128,Bit#(2)) cs20=replicate(0);
for(Integer i=0;i<21;i=i+1)begin
 cs20[i]=ha(cs19[i+1][0],cs19[i][1]);
end
for(Integer i=21;i<86;i=i+1)begin
  cs20[i]=fa(cs19[i+1][0],cs19[i][1],pl1_pp[3][i-21]);
end
//sign extend for stage20
for(Integer i=86;i<107;i=i+1)begin
 cs20[i][0]=cs20[85][0];
 cs20[i][1]=cs20[85][1];
end
out[21]=cs20[0][0];

//stage21
Vector#(128,Bit#(2)) cs21=replicate(0);
for(Integer i=0;i<22;i=i+1)begin
 cs21[i]=ha(cs20[i+1][0],cs20[i][1]);
end
for(Integer i=22;i<87;i=i+1)begin
  cs21[i]=fa(cs20[i+1][0],cs20[i][1],pl1_pp[4][i-22]);
end
//sign extend for stage21
for(Integer i=87;i<106;i=i+1)begin
 cs21[i][0]=cs21[86][0];
 cs21[i][1]=cs21[86][1];
end
out[22]=cs21[0][0];

//stage22
Vector#(128,Bit#(2)) cs22=replicate(0);
for(Integer i=0;i<23;i=i+1)begin
 cs22[i]=ha(cs21[i+1][0],cs21[i][1]);
end
for(Integer i=23;i<88;i=i+1)begin
  cs22[i]=fa(cs21[i+1][0],cs21[i][1],pl1_pp[5][i-23]);
end
//sign extend for stage22
for(Integer i=88;i<105;i=i+1)begin
 cs22[i][0]=cs22[87][0];
 cs22[i][1]=cs22[87][1];
end
out[23]=cs22[0][0];

//stage23
Vector#(128,Bit#(2)) cs23=replicate(0);
for(Integer i=0;i<24;i=i+1)begin
 cs23[i]=ha(cs22[i+1][0],cs22[i][1]);
end
for(Integer i=24;i<89;i=i+1)begin
  cs23[i]=fa(cs22[i+1][0],cs22[i][1],pl1_pp[6][i-24]);
end
//sign extend for stage23
for(Integer i=89;i<104;i=i+1)begin
 cs23[i][0]=cs23[88][0];
 cs23[i][1]=cs23[88][1];
end
out[24]=cs23[0][0];

//stage24
Vector#(128,Bit#(2)) cs24=replicate(0);
for(Integer i=0;i<25;i=i+1)begin
 cs24[i]=ha(cs23[i+1][0],cs23[i][1]);
end
for(Integer i=25;i<90;i=i+1)begin
  cs24[i]=fa(cs23[i+1][0],cs23[i][1],pl1_pp[7][i-25]);
end
//sign extend for stage24
for(Integer i=90;i<103;i=i+1)begin
 cs24[i][0]=cs24[89][0];
 cs24[i][1]=cs24[89][1];
end
out[25]=cs24[0][0];

//stage25
Vector#(128,Bit#(2)) cs25=replicate(0);
for(Integer i=0;i<26;i=i+1)begin
 cs25[i]=ha(cs24[i+1][0],cs24[i][1]);
end
for(Integer i=26;i<91;i=i+1)begin
  cs25[i]=fa(cs24[i+1][0],cs24[i][1],pl1_pp[8][i-26]);
end
//sign extend for stage25
for(Integer i=91;i<102;i=i+1)begin
 cs25[i][0]=cs25[90][0];
 cs25[i][1]=cs25[90][1];
end
out[26]=cs25[0][0];

//stage26
Vector#(128,Bit#(2)) cs26=replicate(0);
for(Integer i=0;i<27;i=i+1)begin
 cs26[i]=ha(cs25[i+1][0],cs25[i][1]);
end
for(Integer i=27;i<92;i=i+1)begin
  cs26[i]=fa(cs25[i+1][0],cs25[i][1],pl1_pp[9][i-27]);
end
//sign extend for stage26
for(Integer i=92;i<101;i=i+1)begin
 cs26[i][0]=cs26[91][0];
 cs26[i][1]=cs26[91][1];
end
out[27]=cs26[0][0];

//stage27
Vector#(128,Bit#(2)) cs27=replicate(0);
for(Integer i=0;i<28;i=i+1)begin
 cs27[i]=ha(cs26[i+1][0],cs26[i][1]);
end
for(Integer i=28;i<93;i=i+1)begin
  cs27[i]=fa(cs26[i+1][0],cs26[i][1],pl1_pp[10][i-28]);
end
//sign extend for stage27
for(Integer i=93;i<100;i=i+1)begin
 cs27[i][0]=cs27[92][0];
 cs27[i][1]=cs27[92][1];
end
out[28]=cs27[0][0];

//stage28
Vector#(128,Bit#(2)) cs28=replicate(0);
for(Integer i=0;i<29;i=i+1)begin
 cs28[i]=ha(cs27[i+1][0],cs27[i][1]);
end
for(Integer i=29;i<94;i=i+1)begin
  cs28[i]=fa(cs27[i+1][0],cs27[i][1],pl1_pp[11][i-29]);
end
//sign extend for stage28
for(Integer i=94;i<99;i=i+1)begin
 cs28[i][0]=cs28[93][0];
 cs28[i][1]=cs28[93][1];
end
out[29]=cs28[0][0];

//stage29
Vector#(128,Bit#(2)) cs29=replicate(0);
for(Integer i=0;i<30;i=i+1)begin
 cs29[i]=ha(cs28[i+1][0],cs28[i][1]);
end
for(Integer i=30;i<95;i=i+1)begin
  cs29[i]=fa(cs28[i+1][0],cs28[i][1],pl1_pp[12][i-30]);
end
//sign extend for stage29
for(Integer i=95;i<97;i=i+1)begin
 cs29[i][0]=cs29[94][0];
 cs29[i][1]=cs29[94][1];
end
out[30]=cs29[0][0];

//stage30
Vector#(128,Bit#(2)) cs30=replicate(0);
for(Integer i=0;i<31;i=i+1)begin
 cs30[i]=ha(cs29[i+1][0],cs29[i][1]);
end
for(Integer i=31;i<96;i=i+1)begin
  cs30[i]=fa(cs29[i+1][0],cs29[i][1],pl1_pp[13][i-31]);
end
//sign extend for stage29
cs30[96][0]=cs30[95][0];
out[31]=cs30[0][0];

//Ripple carry adder stage
Vector#(128,Bit#(2)) cs31=replicate(0);
cs31[0]=ha(cs30[1][0],cs30[0][1]);
for(Integer i=1;i<96;i=i+1)begin
  cs31[i]=fa(cs30[i+1][0],cs30[i][1],cs31[i-1][1]);
end
for(Integer i=32;i<128;i=i+1)begin
  out[i]=cs31[i-32][0];
end

//output stage
result_mul<={out[127],out[126],out[125],out[124],out[123],out[122],out[121],out[120],out[119],out[118],out[117],out[116],out[115],out[114],out[113],out[112],out[111],out[110],out[109],out[108],out[107],out[106],out[105],out[104],out[103],out[102],out[101],out[100],out[99],out[98],out[97],out[96],out[95],out[94],out[93],out[92],out[91],out[90],out[89],out[88],out[87],out[86],out[85],out[84],out[83],out[82],out[81],out[80],out[79],out[78],out[77],out[76],out[75],out[74],out[73],out[72],out[71],out[70],out[69],out[68],out[67],out[66],out[65],out[64],out[63],out[62],out[61],out[60],out[59],out[58],out[57],out[56],out[55],out[54],out[53],out[52],out[51],out[50],out[49],out[48],out[47],out[46],out[45],out[44],out[43],out[42],out[41],out[40],out[39],out[38],out[37],out[36],out[35],out[34],out[33],out[32],out[31],out[30],out[29],out[28],out[27],out[26],out[25],out[24],out[23],out[22],out[21],out[20],out[19],out[18],result_pl};
result_mul_wire<=result_mul;
//$display("res_mul:%h",result_mul);
endrule

rule r4;
Vector#(128,Bit#(2)) cs_accum=replicate(0);
Bit#(128) accum_out_wire;
cs_accum[0]=ha(result_mul_wire[0],accum_out[0]);
for(Integer i=1;i<128;i=i+1)begin
  cs_accum[i]=fa(result_mul_wire[i],accum_out[i],cs_accum[i-1][1]);
end
accum_out_wire={cs_accum[127][0],cs_accum[126][0],cs_accum[125][0],cs_accum[124][0],cs_accum[123][0],cs_accum[122][0],cs_accum[121][0],cs_accum[120][0],cs_accum[119][0],cs_accum[118][0],cs_accum[117][0],cs_accum[116][0],cs_accum[115][0],cs_accum[114][0],cs_accum[113][0],cs_accum[112][0],cs_accum[111][0],cs_accum[110][0],cs_accum[109][0],cs_accum[108][0],cs_accum[107][0],cs_accum[106][0],cs_accum[105][0],cs_accum[104][0],cs_accum[103][0],cs_accum[102][0],cs_accum[101][0],cs_accum[100][0],cs_accum[99][0],cs_accum[98][0],cs_accum[97][0],cs_accum[96][0],cs_accum[95][0],cs_accum[94][0],cs_accum[93][0],cs_accum[92][0],cs_accum[91][0],cs_accum[90][0],cs_accum[89][0],cs_accum[88][0],cs_accum[87][0],cs_accum[86][0],cs_accum[85][0],cs_accum[84][0],cs_accum[83][0],cs_accum[82][0],cs_accum[81][0],cs_accum[80][0],cs_accum[79][0],cs_accum[78][0],cs_accum[77][0],cs_accum[76][0],cs_accum[75][0],cs_accum[74][0],cs_accum[73][0],cs_accum[72][0],cs_accum[71][0],cs_accum[70][0],cs_accum[69][0],cs_accum[68][0],cs_accum[67][0],cs_accum[66][0],cs_accum[65][0],cs_accum[64][0],cs_accum[63][0],cs_accum[62][0],cs_accum[61][0],cs_accum[60][0],cs_accum[59][0],cs_accum[58][0],cs_accum[57][0],cs_accum[56][0],cs_accum[55][0],cs_accum[54][0],cs_accum[53][0],cs_accum[52][0],cs_accum[51][0],cs_accum[50][0],cs_accum[49][0],cs_accum[48][0],cs_accum[47][0],cs_accum[46][0],cs_accum[45][0],cs_accum[44][0],cs_accum[43][0],cs_accum[42][0],cs_accum[41][0],cs_accum[40][0],cs_accum[39][0],cs_accum[38][0],cs_accum[37][0],cs_accum[36][0],cs_accum[35][0],cs_accum[34][0],cs_accum[33][0],cs_accum[32][0],cs_accum[31][0],cs_accum[30][0],cs_accum[29][0],cs_accum[28][0],cs_accum[27][0],cs_accum[26][0],cs_accum[25][0],cs_accum[24][0],cs_accum[23][0],cs_accum[22][0],cs_accum[21][0],cs_accum[20][0],cs_accum[19][0],cs_accum[18][0],cs_accum[17][0],cs_accum[16][0],cs_accum[15][0],cs_accum[14][0],cs_accum[13][0],cs_accum[12][0],cs_accum[11][0],cs_accum[10][0],cs_accum[9][0],cs_accum[8][0],cs_accum[7][0],cs_accum[6][0],cs_accum[5][0],cs_accum[4][0],cs_accum[3][0],cs_accum[2][0],cs_accum[1][0],cs_accum[0][0]};
accum_out<=unpack(accum_rst)? 0:accum_out_wire;
endrule

method Action send(Bit#(64) a, Bit#(64) b,Bit#(1) rst);
  x<=a;
  y<=b;
 accum_rst<=rst;
endmethod
method Bit#(128) receive();
  return accum_out;
endmethod
endmodule
endpackage
