`.text
#setup reg for address for memory stores / loads
addi $a0, $zero, 0x4000
sll $a0, $a0, 0x10 #a0 = 4000_0000

j skip_adds
addi $t0, $zero, 0xdeac
addi $t0, $t0, 0x01
skip_adds:
addi $t0, $zero, 0xaced #pass t0 regfile 8-> ffff_aced
lui $t1, 0xaced #pass -> t1 regfile 9 = aced_0000

#testing jump reg - pass->t3-regfile 11 = aced
addi $t2, $zero, 0x0b #pc: 0x07
addi $t3, $zero, 0xaced #0x08 //puts aced in t3-rf:11
jr $t2 #0x09
addi $t3, $zero, 0xdead #0x0a //trap
add $zero, $zero, $zero #0x0b //should skip here to give it an aced

#testing half word store load
lui $t4, 0xdead #t4 = dead_0000
addi $t4, $t4, 0xaced #t4 = dead_aced
sh $a0, $t4, 0x0 #store 0000_aced into m[4000_0000]
add $zero $zero $zero #buffer b/c data hazards scare me
lhu $t4, $a0, 0x0 #load 0000_aced from m[4000_0000] into t4, pass t4 rf:12 -> 0000_aced

#testing byte store / load
addi $t5, $zero, 0xddac #dd = dead, ac = aced, t5=0000_ddac
sb $a0, $t5, 0x01 #store 0000_00ac into m[4000_0000 + 1]
add $zero $zero $zero #buffer
lbu $t5, $a0, 0x01 #load 0000_00ac from m[4000_0001] into t5, pass t5 rf:13 -> 0000_00ac

#jump and link test
jal JAL_ACE #ensure that $ra rf:31 = 16 (current PC+1), and t6 rf:14 -> ffff_aced

#less than tests SLT/I/IU/U
addi $a1, $zero, -0x05 #setting up comparison variables
addi $a2, $zero, 0x05

slt $t7, $a1, $a2 # -5 < 5, so sets t7 rf:15 = 1 for pass
sltu $s0, $a2, $a1 # 5 < -5=ffff_fffb, sets s0 rf:16 = 1 for pass
slti $s1, $a1, 0x05 #-5 < 5, so sets s1 rf:17 = 1
sltiu $s2, $a2, -0x05 #5 < -5=ffff_fffb, sets s2 rf:18=1

#don't take this to heart, i'm not 100% sure how ll & sc work
ll $s3, $a0, 0x0
addi $s3, $s3, 0x01
sc $a0, $s3, 0x0 #should get s3 rf:19=1

.gap 0x3ca
JAL_ACE:
addi $t6, $t6, 0xaced #lets you know if its good
jr $ra #should put JAL pc+1 (16) into $ra rf:31 -> CURRENT_PC+1 (16) and return back to the jal instruction
jr $ra #here just in case im dumb and got off by 1`
